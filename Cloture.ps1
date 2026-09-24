# =====================================================================
#  Cloture.ps1 - واجهة رسومية لإقفال السنة المالية (برنامج gamadev)
#  الإصدار 1.0
#
#  تُشغَّل بالنقر المزدوج على Cloture.bat الموجود بجانب هذا الملف.
#  الإعدادات تُحفظ في Cloture.settings.xml (نفس المجلد).
#
#  ملاحظة مهمة: يجب أن يبقى هذا الملف بترميز UTF-8 مع BOM،
#  وإلا لن يقرأ PowerShell النصوص العربية.
# =====================================================================

$ErrorActionPreference = 'Continue'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[void][System.Windows.Forms.Application]::EnableVisualStyles()

# ---------------------------------------------------------------------
#  المسارات والحالة العامة
# ---------------------------------------------------------------------
$Script:ScriptDir = $PSScriptRoot
if (-not $Script:ScriptDir) { $Script:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition }
if (-not $Script:ScriptDir) { $Script:ScriptDir = (Get-Location).Path }
$Script:CfgPath     = Join-Path $Script:ScriptDir 'Cloture.settings.xml'
$Script:CurrentProc = $null
$Script:CancelFlag  = $false
$Script:Running     = $false
$Script:LogPath     = ''
$Script:Cfg         = $null
$Script:LogBox      = $null
$Script:LblStatus   = $null
$Script:PwWarned    = $false

# الجداول السبعة التي ينسخها السكربت الأصلي (نفس الأمر حرفياً)
$Script:Tables = @('articlesliste','codbar','personnez','fav','favliste','userz','dosse')

# ---------------------------------------------------------------------
#  أدوات مساعدة
# ---------------------------------------------------------------------

# كتابة سطر في نافذة السجل وفي ملف السجل معاً
function Add-Log {
    param([string]$Text)
    if ($Text -eq $null) { $Text = '' }
    if ($Script:LogBox -ne $null) {
        $Script:LogBox.AppendText($Text + "`r`n")
        $Script:LogBox.SelectionStart = $Script:LogBox.TextLength
        $Script:LogBox.ScrollToCaret()
    }
    if ($Script:LogPath -ne '') {
        try { [System.IO.File]::AppendAllText($Script:LogPath, $Text + "`r`n", [System.Text.Encoding]::UTF8) } catch { }
    }
}

function Set-Status {
    param([string]$Text)
    if ($Script:LblStatus -ne $null) { $Script:LblStatus.Text = $Text }
}

function Show-Error {
    param([string]$Text)
    [void][System.Windows.Forms.MessageBox]::Show($Text, 'خطأ', 'OK', 'Error')
}

function Show-Info {
    param([string]$Text)
    [void][System.Windows.Forms.MessageBox]::Show($Text, 'معلومة', 'OK', 'Information')
}

# قراءة ملف نصي كاملاً دون إظهار أخطاء
function Get-FileText {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return '' }
    try { return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::Default) } catch { return '' }
}

# إحاطة الوسيط بعلامات اقتباس عند الحاجة
function Quote-Arg {
    param([string]$Value)
    if ($null -eq $Value -or $Value -eq '') { return '""' }
    if ($Value -match '^[A-Za-z0-9_\.:\-\\/]+$') { return $Value }
    return ('"' + $Value + '"')
}

# التأكد من أن القيمة آمنة للتمرير عبر cmd.exe
function Test-SafeValue {
    param([string]$Value, [string]$What)
    if ($Value -match '[%&|<>\^"]') {
        Show-Error ('قيمة ' + $What + ' تحتوي على رمز غير مسموح به ( % & | < > ^ " ).')
        return $false
    }
    return $true
}

# التحقق من اسم قاعدة بيانات
function Test-DbName {
    param([string]$Value, [string]$What)
    if ($Value -eq '') { Show-Error ('الرجاء كتابة ' + $What + '.'); return $false }
    if ($Value -notmatch '^[A-Za-z0-9_]+$') {
        Show-Error ('اسم ' + $What + ' غير صحيح.' + "`r`n" +
                    'المسموح: حروف لاتينية وأرقام وخط سفلي _ فقط، بدون مسافات أو رموز.')
        return $false
    }
    return $true
}

# التحقق من وجود البرنامج التنفيذي
function Test-Executable {
    param([string]$Value, [string]$What)
    if ($Value -eq '') { Show-Error ('لم يتم تحديد ' + $What + '.'); return $false }
    if ($Value -match '[\\/]' -or $Value -match '^[A-Za-z]:') {
        if (-not (Test-Path -LiteralPath $Value)) {
            Show-Error ('الملف غير موجود: ' + $Value + "`r`n`r`n" +
                        'صحّح ' + $What + ' في تبويب الإعدادات.')
            return $false
        }
    }
    return $true
}

# قراءة ما أُضيف حديثاً إلى ملف (لمتابعة المخرجات أثناء التنفيذ)
function Read-NewText {
    param([string]$Path, [int]$From)
    $result = @{ Text = ''; Pos = $From }
    if (-not (Test-Path -LiteralPath $Path)) { return $result }
    try {
        $fs = New-Object System.IO.FileStream -ArgumentList @(
            $Path,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::ReadWrite)
        try {
            $len = $fs.Length
            if ($len -gt $From) {
                [void]$fs.Seek($From, [System.IO.SeekOrigin]::Begin)
                $count = [int]($len - $From)
                $buf = [System.Array]::CreateInstance([System.Byte], $count)
                $read = $fs.Read($buf, 0, $count)
                $result.Text = [System.Text.Encoding]::Default.GetString($buf, 0, $read)
                $result.Pos  = $From + $read
            }
        } finally { $fs.Close() }
    } catch { }
    return $result
}

# إيقاف العملية وكل العمليات التابعة لها
function Stop-ProcessTree {
    param([int]$ProcessId)
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName        = 'taskkill.exe'
        $psi.Arguments       = '/T /F /PID ' + $ProcessId
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow  = $true
        $p = [System.Diagnostics.Process]::Start($psi)
        [void]$p.WaitForExit(5000)
    } catch { }
}

# تنفيذ سطر أوامر عبر cmd.exe مع توجيه المخرجات والأخطاء إلى ملفين،
# مع تحديث الواجهة أثناء الانتظار حتى لا تتجمد النافذة.
function Invoke-External {
    param(
        [string]$CmdLine,
        [string]$OutFile,
        [string]$ErrFile,
        # إن كان false لا تُقرأ مخرجات stdout إلى السجل (تُستعمل عند كتابة ملف كبير)
        [bool]$CaptureOutput = $true
    )

    # التوجيه يُضاف هنا لا في الأمر، حتى لا يتعارض مع أوامر فيها توجيه مسبق
    $fullCmd = $CmdLine + ' > ' + (Quote-Arg $OutFile) + ' 2> ' + (Quote-Arg $ErrFile)

    # ملاحظة: cmd /c ينزع أول وآخر علامة اقتباس،
    # لذلك نضيف علامتين حول الأمر كله للحفاظ على علامات المسارات.
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName        = $env:ComSpec
    $psi.Arguments       = '/c "' + $fullCmd + '"'
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow  = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    [void]$proc.Start()
    $Script:CurrentProc = $proc

    $posOut = 0
    $posErr = 0
    while (-not $proc.HasExited) {
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 120
        if ($CaptureOutput) {
            $chunk  = Read-NewText -Path $OutFile -From $posOut
            $posOut = $chunk.Pos
            if ($chunk.Text -ne '') { Add-Log $chunk.Text.TrimEnd() }
        }
        $chunk  = Read-NewText -Path $ErrFile -From $posErr
        $posErr = $chunk.Pos
        if ($chunk.Text -ne '') { Add-Log $chunk.Text.TrimEnd() }
        if ($Script:CancelFlag) {
            Add-Log '>> تم طلب الإلغاء، جارٍ إيقاف العملية...'
            Stop-ProcessTree -ProcessId $proc.Id
            break
        }
    }
    try { [void]$proc.WaitForExit(15000) } catch { }

    if ($CaptureOutput) {
        $chunk  = Read-NewText -Path $OutFile -From $posOut
        if ($chunk.Text -ne '') { Add-Log $chunk.Text.TrimEnd() }
    }
    $chunk  = Read-NewText -Path $ErrFile -From $posErr
    if ($chunk.Text -ne '') { Add-Log $chunk.Text.TrimEnd() }

    $code = -1
    try { if ($proc.HasExited) { $code = $proc.ExitCode } } catch { }
    $Script:CurrentProc = $null
    return $code
}

# ---------------------------------------------------------------------
#  الإعدادات
# ---------------------------------------------------------------------

# البحث عن mysql.exe / mysqldump.exe في المواضع المعتادة
function Find-Tool {
    param([string]$ExeName)

    try {
        $cmd = Get-Command $ExeName -ErrorAction SilentlyContinue
        if ($cmd -ne $null) { return $cmd.Definition }
    } catch { }

    $roots = @(
        'C:\xampp\mysql\bin',
        'C:\wamp\bin\mysql',
        'C:\wamp64\bin\mysql',
        'C:\Program Files\MySQL',
        'C:\Program Files (x86)\MySQL',
        'C:\Program Files\MariaDB 10.4\bin',
        'C:\Program Files\MariaDB 10.5\bin',
        'C:\Program Files\MariaDB 10.6\bin',
        'C:\Program Files\MariaDB 10.11\bin',
        'C:\laragon\bin\mysql'
    )
    foreach ($root in $roots) {
        if (-not (Test-Path -LiteralPath $root)) { continue }
        try {
            $found = Get-ChildItem -LiteralPath $root -Filter $ExeName -Recurse -File -ErrorAction SilentlyContinue |
                     Select-Object -First 1
            if ($found -ne $null) { return $found.FullName }
        } catch { }
    }
    return $ExeName
}

function New-DefaultConfig {
    $cfg = @{}
    $cfg['Host']        = 'localhost'
    $cfg['Port']        = '3306'
    $cfg['User']        = 'root'
    $cfg['PasswordEnc'] = ''
    $cfg['MysqlExe']    = Find-Tool 'mysql.exe'
    $cfg['DumpExe']     = Find-Tool 'mysqldump.exe'
    $cfg['SchemaFile']  = (Join-Path $Script:ScriptDir 'Schema16102016.sql')
    $cfg['PrimaryFile'] = (Join-Path $Script:ScriptDir 'PrimaryData20150428.sql')
    $cfg['WorkDir']     = $Script:ScriptDir
    $cfg['SrcDb']       = 'ssSourceDB'
    $cfg['DstDb']       = 'ssDesticationDB'
    return $cfg
}

function Load-Config {
    if (Test-Path -LiteralPath $Script:CfgPath) {
        try {
            $loaded = Import-Clixml -Path $Script:CfgPath
            $cfg = New-DefaultConfig
            foreach ($key in @($loaded.Keys)) {
                if ($loaded[$key] -ne $null -and $loaded[$key] -ne '') { $cfg[$key] = $loaded[$key] }
            }
            return $cfg
        } catch {
            Show-Info 'تعذّر قراءة ملف الإعدادات، سيتم استعمال الإعدادات الافتراضية.'
        }
    }
    return (New-DefaultConfig)
}

function Save-Config {
    param([hashtable]$Cfg)
    try {
        $Cfg | Export-Clixml -Path $Script:CfgPath
        return $true
    } catch {
        Show-Error ('تعذّر حفظ الإعدادات: ' + $_.Exception.Message)
        return $false
    }
}

# فك تشفير كلمة المرور (الترميز مرتبط بهذا المستخدم وهذا الجهاز)
function Get-PlainPassword {
    param([string]$Enc)
    if ($Enc -eq '' -or $null -eq $Enc) { return '' }
    try {
        $sec  = ConvertTo-SecureString $Enc
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
        try { return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
        finally { [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
    } catch {
        if (-not $Script:PwWarned) {
            $Script:PwWarned = $true
            Show-Info ('تعذّر فك تشفير كلمة المرور المخزّنة.' + "`r`n`r`n" +
                       'يحدث هذا إذا نُسخ ملف الإعدادات إلى جهاز أو مستخدم آخر.' + "`r`n" +
                       'أعد كتابة كلمة المرور في تبويب الإعدادات ثم اضغط "حفظ الإعدادات".')
        }
        return ''
    }
}

function Set-Password {
    param([string]$Plain)
    if ($Plain -eq '') { return '' }
    $sec = ConvertTo-SecureString -String $Plain -AsPlainText -Force
    return (ConvertFrom-SecureString $sec)
}

# ---------------------------------------------------------------------
#  بناء أوامر MySQL
# ---------------------------------------------------------------------

function Build-ClientArgs {
    $c = $Script:Cfg
    $parts = @('--host=' + $c.Host, '--port=' + $c.Port, '--user=' + $c.User)
    $plain = Get-PlainPassword $c.PasswordEnc
    if ($plain -ne '') {
        if ($plain -match '["%]') {
            Show-Error ('كلمة المرور تحتوي على علامة اقتباس أو الرمز % وهذا لا يعمل في سطر الأوامر.' + "`r`n" +
                        'غيّرها مؤقتاً أو اكتبها بدون هذه الرموز.')
            return $null
        }
        if ($plain -match '^[A-Za-z0-9_\.\-@!#$\*+=:,]+$') { $parts += ('--password=' + $plain) }
        else { $parts += ('--password="' + $plain + '"') }
    }
    return ($parts -join ' ')
}

# ---------------------------------------------------------------------
#  الواجهة الرسومية
# ---------------------------------------------------------------------

$form = New-Object System.Windows.Forms.Form
$form.Text            = 'إقفال السنة المالية - قاعدة بيانات gamadev'
$form.ClientSize      = New-Object System.Drawing.Size(760, 620)
$form.StartPosition   = 'CenterScreen'
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox     = $false
$form.RightToLeft     = 'Yes'
$form.Font            = New-Object System.Drawing.Font('Tahoma', 9)

function New-FormLabel {
    param([string]$Text, [int]$X, [int]$Y, [int]$W, [int]$H = 20)
    $l = New-Object System.Windows.Forms.Label
    $l.Text      = $Text
    $l.Location  = New-Object System.Drawing.Point($X, $Y)
    $l.Size      = New-Object System.Drawing.Size($W, $H)
    $l.TextAlign = 'MiddleRight'
    return $l
}

function New-FormText {
    param([int]$X, [int]$Y, [int]$W)
    $t = New-Object System.Windows.Forms.TextBox
    $t.Location    = New-Object System.Drawing.Point($X, $Y)
    $t.Size        = New-Object System.Drawing.Size($W, 22)
    $t.RightToLeft = 'No'
    return $t
}

function New-FormButton {
    param([string]$Text, [int]$X, [int]$Y, [int]$W, [int]$H = 28)
    $b = New-Object System.Windows.Forms.Button
    $b.Text     = $Text
    $b.Location = New-Object System.Drawing.Point($X, $Y)
    $b.Size     = New-Object System.Drawing.Size($W, $H)
    return $b
}

$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Location = New-Object System.Drawing.Point(10, 10)
$tabs.Size     = New-Object System.Drawing.Size(740, 600)

$tabRun = New-Object System.Windows.Forms.TabPage
$tabRun.Text = '   الإقفال   '
$tabCfg = New-Object System.Windows.Forms.TabPage
$tabCfg.Text = '   الإعدادات   '
[void]$tabs.Controls.Add($tabRun)
[void]$tabs.Controls.Add($tabCfg)

# ---------------- تبويب الإقفال ----------------
$tabRun.Controls.Add((New-FormLabel 'قاعدة السنة المنتهية (المصدر)' 430 20 290))
$txtSrc = New-FormText 20 20 400
$tabRun.Controls.Add($txtSrc)

$tabRun.Controls.Add((New-FormLabel 'قاعدة السنة الجديدة (الوجهة)' 430 55 290))
$txtDst = New-FormText 20 55 400
$tabRun.Controls.Add($txtDst)

$chkBackup = New-Object System.Windows.Forms.CheckBox
$chkBackup.Text     = 'اسمح بحذف قاعدة الوجهة إن كانت موجودة مسبقاً، بعد أخذ نسخة احتياطية منها'
$chkBackup.Location = New-Object System.Drawing.Point(20, 90)
$chkBackup.Size     = New-Object System.Drawing.Size(700, 24)
$chkBackup.Checked  = $false
$tabRun.Controls.Add($chkBackup)

$chkDry = New-Object System.Windows.Forms.CheckBox
$chkDry.Text     = 'عرض الأوامر فقط دون تنفيذ (للمعاينة)'
$chkDry.Location = New-Object System.Drawing.Point(20, 115)
$chkDry.Size     = New-Object System.Drawing.Size(700, 24)
$tabRun.Controls.Add($chkDry)

$btnRun = New-FormButton '▶   تنفيذ الإقفال' 20 148 400 40
$btnRun.Font = New-Object System.Drawing.Font('Tahoma', 11, [System.Drawing.FontStyle]::Bold)
$tabRun.Controls.Add($btnRun)

$btnCancel = New-FormButton 'إلغاء' 20 195 140
$btnCancel.Enabled = $false
$tabRun.Controls.Add($btnCancel)

$Script:LblStatus = New-FormLabel 'جاهز.' 170 195 550
$Script:LblStatus.TextAlign = 'MiddleLeft'
$tabRun.Controls.Add($Script:LblStatus)

$bar = New-Object System.Windows.Forms.ProgressBar
$bar.Location = New-Object System.Drawing.Point(20, 228)
$bar.Size     = New-Object System.Drawing.Size(700, 16)
$bar.Minimum  = 0
$bar.Maximum  = 8
$tabRun.Controls.Add($bar)

$Script:LogBox = New-Object System.Windows.Forms.TextBox
$Script:LogBox.Multiline   = $true
$Script:LogBox.ReadOnly    = $true
$Script:LogBox.ScrollBars  = 'Vertical'
$Script:LogBox.WordWrap    = $false
$Script:LogBox.Location    = New-Object System.Drawing.Point(20, 252)
$Script:LogBox.Size        = New-Object System.Drawing.Size(700, 300)
$Script:LogBox.BackColor   = [System.Drawing.Color]::FromArgb(250, 250, 250)
$Script:LogBox.Font        = New-Object System.Drawing.Font('Consolas', 8.5)
$Script:LogBox.RightToLeft = 'No'
$tabRun.Controls.Add($Script:LogBox)

# ---------------- تبويب الإعدادات ----------------
$Y = 18
$tabCfg.Controls.Add((New-FormLabel 'الخادم (Host)' 430 $Y 290))
$txtHost = New-FormText 105 $Y 320
$tabCfg.Controls.Add($txtHost)
$Y += 35
$tabCfg.Controls.Add((New-FormLabel 'المنفذ (Port)' 430 $Y 290))
$txtPort = New-FormText 105 $Y 320
$tabCfg.Controls.Add($txtPort)
$Y += 35
$tabCfg.Controls.Add((New-FormLabel 'المستخدم' 430 $Y 290))
$txtUser = New-FormText 105 $Y 320
$tabCfg.Controls.Add($txtUser)
$Y += 35
$tabCfg.Controls.Add((New-FormLabel 'كلمة المرور' 430 $Y 290))
$txtPass = New-FormText 105 $Y 320
$txtPass.UseSystemPasswordChar = $true
$tabCfg.Controls.Add($txtPass)
$Y += 45

function New-FileRow {
    param([string]$Label, [int]$RowY)
    $tabCfg.Controls.Add((New-FormLabel $Label 430 $RowY 290))
    $browse = New-FormButton 'استعراض...' 20 ($RowY - 2) 80
    $tabCfg.Controls.Add($browse)
    $box = New-FormText 105 $RowY 320
    $tabCfg.Controls.Add($box)
    return @{ Browse = $browse; Box = $box }
}

$rowMysql = New-FileRow 'مسار mysql.exe' $Y
$btnBrowseMysql = $rowMysql.Browse; $txtMysql = $rowMysql.Box
$Y += 35
$rowDump = New-FileRow 'مسار mysqldump.exe' $Y
$btnBrowseDump = $rowDump.Browse; $txtDump = $rowDump.Box
$Y += 35
$rowSchema = New-FileRow 'ملف بنية القاعدة (Schema)' $Y
$btnBrowseSchema = $rowSchema.Browse; $txtSchema = $rowSchema.Box
$Y += 35
$rowPrimary = New-FileRow 'ملف البيانات الأولية (PrimaryData)' $Y
$btnBrowsePrimary = $rowPrimary.Browse; $txtPrimary = $rowPrimary.Box
$Y += 35
$rowWork = New-FileRow 'مجلد العمل (تُكتب فيه النسخ والسجلات)' $Y
$btnBrowseWork = $rowWork.Browse; $txtWork = $rowWork.Box
$Y += 45

$btnSaveCfg = New-FormButton 'حفظ الإعدادات' 20 $Y 150
$tabCfg.Controls.Add($btnSaveCfg)
$btnTest = New-FormButton 'اختبار الاتصال' 180 $Y 150
$tabCfg.Controls.Add($btnTest)

$lblCfgMsg = New-FormLabel 'كلمة المرور تُحفظ مشفّرة، ولا تصلح إلا على هذا الجهاز وهذا المستخدم.' 340 $Y 380
$tabCfg.Controls.Add($lblCfgMsg)

# ---------------------------------------------------------------------
#  تعبئة الحقول من الإعدادات
# ---------------------------------------------------------------------
function Fill-FormFromConfig {
    $c = $Script:Cfg
    $txtHost.Text    = $c.Host
    $txtPort.Text    = $c.Port
    $txtUser.Text    = $c.User
    $txtPass.Text    = Get-PlainPassword $c.PasswordEnc
    $txtMysql.Text   = $c.MysqlExe
    $txtDump.Text    = $c.DumpExe
    $txtSchema.Text  = $c.SchemaFile
    $txtPrimary.Text = $c.PrimaryFile
    $txtWork.Text    = $c.WorkDir
    $txtSrc.Text     = $c.SrcDb
    $txtDst.Text     = $c.DstDb
}

function Read-FormIntoConfig {
    $c = $Script:Cfg
    $c.Host        = $txtHost.Text.Trim()
    $c.Port        = $txtPort.Text.Trim()
    $c.User        = $txtUser.Text.Trim()
    $c.MysqlExe    = $txtMysql.Text.Trim()
    $c.DumpExe     = $txtDump.Text.Trim()
    $c.SchemaFile  = $txtSchema.Text.Trim()
    $c.PrimaryFile = $txtPrimary.Text.Trim()
    $c.WorkDir     = $txtWork.Text.Trim()
    $c.SrcDb       = $txtSrc.Text.Trim()
    $c.DstDb       = $txtDst.Text.Trim()
    if ($txtPass.Text -ne (Get-PlainPassword $c.PasswordEnc)) {
        $c.PasswordEnc = Set-Password $txtPass.Text
    }
    return $c
}

# ---------------------------------------------------------------------
#  اختبار الاتصال
# ---------------------------------------------------------------------
function Test-ConnectionClicked {
    Read-FormIntoConfig | Out-Null
    if (-not (Test-SafeValue $Script:Cfg.Host 'الخادم')) { return }
    if ($Script:Cfg.Port -notmatch '^[0-9]{1,5}$') {
        Show-Error 'المنفذ يجب أن يكون رقماً، مثلاً 3306.'
        return
    }
    $cliArgs = Build-ClientArgs
    if ($null -eq $cliArgs) { return }

    $tmp    = Join-Path $env:TEMP ('cloture_test_' + (Get-Date -Format 'HHmmss') + '.txt')
    $tmpErr = $tmp + '.err'
    $line = (Quote-Arg $Script:Cfg.MysqlExe) + ' ' + $cliArgs +
            ' --execute="SELECT VERSION() AS version_serveur, CURRENT_USER() AS utilisateur"'

    Add-Log ''
    Add-Log '> اختبار الاتصال بالخادم...'
    $code = Invoke-External -CmdLine $line -OutFile $tmp -ErrFile $tmpErr
    if ($code -eq 0) {
        Show-Info ('نجح الاتصال بالخادم.' + "`r`n`r`n" + (Get-FileText $tmp))
    } else {
        Show-Error ('فشل الاتصال بخادم MySQL (رمز الخروج ' + $code + ').' + "`r`n`r`n" +
                    (Get-FileText $tmp) + (Get-FileText $tmpErr) + "`r`n" +
                    'تحقق من: تشغيل خدمة MySQL، صحة المستخدم وكلمة المرور، ومسار mysql.exe في الإعدادات.')
    }
}

# ---------------------------------------------------------------------
#  تنفيذ الإقفال
# ---------------------------------------------------------------------
function Start-Cloture {
    $Script:CancelFlag = $false

    Read-FormIntoConfig | Out-Null
    $c = $Script:Cfg

    $src = $c.SrcDb
    $dst = $c.DstDb

    if (-not (Test-DbName $src 'قاعدة المصدر')) { return }
    if (-not (Test-DbName $dst 'قاعدة الوجهة')) { return }
    if ($src -eq $dst) { Show-Error 'اسم قاعدة المصدر واسم قاعدة الوجهة متطابقان. صحّح أحدهما.'; return }
    if (-not (Test-SafeValue $c.User 'المستخدم')) { return }
    if (-not (Test-SafeValue $c.Host 'الخادم')) { return }
    if ($c.Port -notmatch '^[0-9]{1,5}$') { Show-Error 'المنفذ يجب أن يكون رقماً، مثلاً 3306.'; return }
    if (-not (Test-Executable $c.MysqlExe 'مسار mysql.exe')) { return }
    if (-not (Test-Executable $c.DumpExe 'مسار mysqldump.exe')) { return }

    # الرمز % بين علامتين يفسّره cmd كمتغير، فتفشل عمليات التوجيه
    foreach ($p in @($c.WorkDir, $c.SchemaFile, $c.PrimaryFile, $c.MysqlExe, $c.DumpExe)) {
        if ($p -match '%[^%]+%') {
            Show-Error ('هذا المسار يحتوي على الرمز % بين علامتين، وهذا لا يعمل مع cmd:' + "`r`n`r`n" + $p +
                        "`r`n`r`n" + 'انقل الملفات أو البرنامج إلى مسار بدون هذا الرمز.')
            return
        }
    }

    if (-not (Test-Path -LiteralPath $c.WorkDir)) { Show-Error ('مجلد العمل غير موجود: ' + $c.WorkDir); return }
    if (-not (Test-Path -LiteralPath $c.SchemaFile)) { Show-Error ('ملف البنية غير موجود: ' + $c.SchemaFile); return }
    if (-not (Test-Path -LiteralPath $c.PrimaryFile)) { Show-Error ('ملف البيانات الأولية غير موجود: ' + $c.PrimaryFile); return }

    $mysql   = Quote-Arg $c.MysqlExe
    $dump    = Quote-Arg $c.DumpExe
    $cliArgs = Build-ClientArgs
    if ($null -eq $cliArgs) { return }

    $stamp          = Get-Date -Format 'yyyyMMdd_HHmmss'
    $dumpFile       = Join-Path $c.WorkDir ('DBCloture_' + $dst + '_' + $stamp + '.sql')
    $Script:LogPath = Join-Path $c.WorkDir ('cloture_' + $dst + '_' + $stamp + '.log')
    $tmpDir         = Join-Path $env:TEMP ('cloture_' + $stamp)
    [void](New-Item -ItemType Directory -Path $tmpDir -Force)

    function New-Step {
        param(
            [string]$Title, [string]$Cmd, [string]$Name, [bool]$Fatal,
            [string]$OutPath = '', [bool]$Capture = $true
        )
        if ($OutPath -eq '') { $OutPath = Join-Path $tmpDir ($Name + '.out') }
        return @{
            Title   = $Title
            Cmd     = $Cmd
            Out     = $OutPath
            Err     = (Join-Path $tmpDir ($Name + '.err'))
            Fatal   = $Fatal
            Capture = $Capture
        }
    }

    $tableList = ($Script:Tables -join ' ')
    $steps = @()

    # 1) تصدير بيانات الجداول السبعة (نفس أمر السكربت الأصلي)
    #    المخرجات تذهب مباشرة إلى ملف .sql، لذا لا تُقرأ في السجل
    $cmd1 = $dump + ' --skip-triggers --routines ' + $cliArgs + ' ' + $src + ' ' + $tableList
    $steps += New-Step -Title 'تصدير بيانات الجداول السبعة من القاعدة المصدر' -Cmd $cmd1 -Name 'step1' -Fatal $true -OutPath $dumpFile -Capture $false

    # 2) حذف قاعدة الوجهة إن كانت موجودة
    $cmd2 = $mysql + ' ' + $cliArgs + ' --execute="DROP DATABASE IF EXISTS ' + $dst + '"'
    $steps += New-Step -Title ('حذف قاعدة الوجهة إن كانت موجودة (' + $dst + ')') -Cmd $cmd2 -Name 'step2' -Fatal $true

    # 3) إنشاء قاعدة الوجهة
    $cmd3 = $mysql + ' ' + $cliArgs + ' --execute="CREATE DATABASE ' + $dst + '"'
    $steps += New-Step -Title ('إنشاء قاعدة الوجهة (' + $dst + ')') -Cmd $cmd3 -Name 'step3' -Fatal $true

    # 4) استيراد البنية
    $cmd4 = $mysql + ' ' + $cliArgs + ' ' + $dst + ' < ' + (Quote-Arg $c.SchemaFile)
    $steps += New-Step -Title 'استيراد بنية القاعدة (Schema)' -Cmd $cmd4 -Name 'step4' -Fatal $true

    # 5) استيراد البيانات الأولية
    $cmd5 = $mysql + ' ' + $cliArgs + ' ' + $dst + ' < ' + (Quote-Arg $c.PrimaryFile)
    $steps += New-Step -Title 'استيراد البيانات الأولية (PrimaryData)' -Cmd $cmd5 -Name 'step5' -Fatal $true

    # 6) استيراد بيانات المصدر (هنا كان الخطأ الإملائي في السكربت الأصلي)
    $cmd6 = $mysql + ' ' + $cliArgs + ' ' + $dst + ' < ' + (Quote-Arg $dumpFile)
    $steps += New-Step -Title 'استيراد بيانات المصدر إلى قاعدة الوجهة' -Cmd $cmd6 -Name 'step6' -Fatal $true

    # 7) ترحيل الأرصدة
    $cmd7 = $mysql + ' ' + $cliArgs + ' ' + $dst +
            ' --execute="UPDATE personnez SET CreditInitial = Solde, DetteInitial = Soldefx"'
    $steps += New-Step -Title 'ترحيل أرصدة الزبائن والموردين إلى الأرصدة الافتتاحية' -Cmd $cmd7 -Name 'step7' -Fatal $true

    # 8) إعادة تفعيل القيود
    $cmd8 = $mysql + ' ' + $cliArgs + ' --execute="SET GLOBAL FOREIGN_KEY_CHECKS=1"'
    $steps += New-Step -Title 'إعادة تفعيل قيود المفاتيح الأجنبية' -Cmd $cmd8 -Name 'step8' -Fatal $false

    # ----- معاينة بدون تنفيذ -----
    if ($chkDry.Checked) {
        Add-Log ''
        Add-Log '===== معاينة الأوامر (لم يُنفَّذ أي شيء) ====='
        $i = 0
        foreach ($st in $steps) {
            $i++
            Add-Log ''
            Add-Log ('[' + $i + '/8] ' + $st.Title)
            Add-Log ('    ' + $st.Cmd)
            Add-Log ('      stdout -> ' + $st.Out)
            Add-Log ('      stderr -> ' + $st.Err)
        }
        Add-Log ''
        Add-Log ('ملف السجل: ' + $Script:LogPath)
        Set-Status 'معاينة فقط، لم يُنفَّذ شيء.'
        return
    }

    # ----- فحص وجود قاعدة الوجهة -----
    Set-Status 'جارٍ فحص القواعد الموجودة...'
    Add-Log ''
    Add-Log '===== بدء الإقفال ====='
    Add-Log ('المصدر: ' + $src + '    ->    الوجهة: ' + $dst)
    Add-Log ('السجل: ' + $Script:LogPath)

    $listOut = Join-Path $tmpDir 'dbs.out'
    $listErr = Join-Path $tmpDir 'dbs.err'
    $listLine = $mysql + ' ' + $cliArgs + ' --batch --skip-column-names --execute="SHOW DATABASES"'
    $listCode = Invoke-External -CmdLine $listLine -OutFile $listOut -ErrFile $listErr

    if ($listCode -ne 0) {
        Set-Status 'متوقف.'
        Add-Log '>> فشل الاتصال بالخادم.'
        Show-Error ('تعذّر الاتصال بخادم MySQL (رمز الخروج ' + $listCode + ').' + "`r`n`r`n" +
                    (Get-FileText $listOut) + (Get-FileText $listErr) + "`r`n" +
                    'افتح تبويب الإعدادات واضغط "اختبار الاتصال".')
        return
    }

    $dstExists = $false
    foreach ($row in ((Get-FileText $listOut) -split "`r?`n")) {
        if ($row.Trim() -ieq $dst) { $dstExists = $true }
    }

    if ($dstExists -and -not $chkBackup.Checked) {
        Set-Status 'متوقف.'
        Add-Log '>> توقّف: قاعدة الوجهة موجودة، والخيار غير مفعّل. لم يُنفَّذ أي أمر.'
        Show-Error ('قاعدة الوجهة "' + $dst + '" موجودة مسبقاً.' + "`r`n`r`n" +
                    'لحمايتها من الحذف لم يُنفَّذ أي شيء.' + "`r`n" +
                    'إذا كنت متأكداً، فعّل الخيار الموجود تحت الحقلين ثم أعد المحاولة.')
        return
    }

    if ($dstExists) {
        Set-Status 'جارٍ أخذ نسخة احتياطية من قاعدة الوجهة...'
        $backupFile = Join-Path $c.WorkDir ('backup_' + $dst + '_' + $stamp + '.sql')
        Add-Log ''
        Add-Log ('>> قاعدة الوجهة موجودة. تُؤخذ نسخة احتياطية إلى:' + "`r`n   " + $backupFile)
        $bkCmd  = $dump + ' --skip-triggers --routines ' + $cliArgs + ' ' + $dst
        $bkErr  = Join-Path $tmpDir 'backup.err'
        $bkCode = Invoke-External -CmdLine $bkCmd -OutFile $backupFile -ErrFile $bkErr -CaptureOutput $false
        if ($bkCode -ne 0) {
            Set-Status 'متوقف.'
            Add-Log '>> توقّف: فشلت النسخة الاحتياطية، لم تُحذف قاعدة الوجهة.'
            Show-Error ('فشلت النسخة الاحتياطية لقاعدة الوجهة (رمز الخروج ' + $bkCode + ').' + "`r`n" +
                        'لن يُحذف شيء. راجع السجل.')
            return
        }
        Add-Log '>> تمّت النسخة الاحتياطية بنجاح.'
    }

    # ----- التنفيذ -----
    $bar.Value = 0
    $failed = $false
    $i = 0
    foreach ($st in $steps) {
        $i++
        $started = Get-Date
        Set-Status ('الخطوة ' + $i + ' من 8: ' + $st.Title)
        Add-Log ''
        Add-Log ('[' + $i + '/8] ' + $st.Title + '   (' + $started.ToString('HH:mm:ss') + ')')
        $code     = Invoke-External -CmdLine $st.Cmd -OutFile $st.Out -ErrFile $st.Err -CaptureOutput $st.Capture
        $elapsed  = [int]((Get-Date) - $started).TotalSeconds

        if ($Script:CancelFlag) { Add-Log '>> أُلغي التنفيذ بناءً على طلبك.'; $failed = $true; break }

        if ($code -eq 0) {
            Add-Log ('     [نجح - ' + $elapsed + ' ثانية]')
        } elseif ($st.Fatal) {
            Add-Log ('     [فشل - رمز الخروج ' + $code + ' بعد ' + $elapsed + ' ثانية]')
            $failed = $true
            break
        } else {
            Add-Log ('     [تحذير: رمز الخروج ' + $code + ' - تُوبع العمل]')
        }
        $bar.Value = $i
    }

    # ----- الخلاصة -----
    Add-Log ''
    if ($failed) {
        Add-Log '===== توقّف الإقفال قبل إكمال كل الخطوات ====='
        Set-Status 'فشل. راجع السجل.'
        Show-Error ('لم تكتمل عملية الإقفال.' + "`r`n`r`n" +
                    'تفاصيل الخطأ في ملف السجل:' + "`r`n" + $Script:LogPath)
    } else {
        Add-Log '===== اكتمل الإقفال ====='
        Add-Log ('ملف بيانات المصدر: ' + $dumpFile)
        Add-Log ('ملف السجل: '        + $Script:LogPath)
        Add-Log ''
        Add-Log 'تنبيه: هذه العملية تنقل المنتجات والأشخاص والمستخدمين فقط.'
        Add-Log '      لا تُرحَّل كميات المخزون، ولا أرصدة الصندوق والبنك، ولا الجداول المرجعية.'
        Add-Log '      راجع القسم 5.2 في ملف ANALYSIS.md قبل استعمال القاعدة الجديدة.'
        Set-Status 'اكتمل الإقفال بنجاح.'
        Show-Info ('اكتمل الإقفال.' + "`r`n" + 'القاعدة الجديدة: ' + $dst + "`r`n`r`n" +
                   'تنبيه: لم تُرحَّل كميات المخزون ولا أرصدة الصندوق والبنك.' + "`r`n" +
                   'راجع ملف السجل ثم ANALYSIS.md.')
    }
}

# ---------------------------------------------------------------------
#  ربط الأزرار
# ---------------------------------------------------------------------

function Set-RunningState {
    param([bool]$IsRunning)
    $Script:Running    = $IsRunning
    $btnRun.Enabled    = -not $IsRunning
    $btnCancel.Enabled = $IsRunning
}

$btnRun.Add_Click({
    if ($Script:Running) { return }
    Set-RunningState $true
    try { Start-Cloture }
    catch { Add-Log ('>> خطأ غير متوقّع: ' + $_.Exception.Message); Show-Error $_.Exception.Message }
    finally { Set-RunningState $false }
})

$btnCancel.Add_Click({
    $Script:CancelFlag = $true
    Set-Status 'جارٍ الإلغاء...'
})

$btnSaveCfg.Add_Click({
    Read-FormIntoConfig | Out-Null
    if (Save-Config $Script:Cfg) { Show-Info 'تم حفظ الإعدادات.' }
})

$btnTest.Add_Click({
    try { Test-ConnectionClicked }
    catch { Show-Error $_.Exception.Message }
})

$btnBrowseMysql.Add_Click({
    $d = New-Object System.Windows.Forms.OpenFileDialog
    $d.Filter = 'mysql.exe|mysql.exe|كل الملفات|*.*'
    if ($d.ShowDialog() -eq 'OK') { $txtMysql.Text = $d.FileName }
})
$btnBrowseDump.Add_Click({
    $d = New-Object System.Windows.Forms.OpenFileDialog
    $d.Filter = 'mysqldump.exe|mysqldump.exe|كل الملفات|*.*'
    if ($d.ShowDialog() -eq 'OK') { $txtDump.Text = $d.FileName }
})
$btnBrowseSchema.Add_Click({
    $d = New-Object System.Windows.Forms.OpenFileDialog
    $d.Filter = 'ملفات SQL|*.sql|كل الملفات|*.*'
    if ($d.ShowDialog() -eq 'OK') { $txtSchema.Text = $d.FileName }
})
$btnBrowsePrimary.Add_Click({
    $d = New-Object System.Windows.Forms.OpenFileDialog
    $d.Filter = 'ملفات SQL|*.sql|كل الملفات|*.*'
    if ($d.ShowDialog() -eq 'OK') { $txtPrimary.Text = $d.FileName }
})
$btnBrowseWork.Add_Click({
    $d = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($d.ShowDialog() -eq 'OK') { $txtWork.Text = $d.SelectedPath }
})

$form.Add_FormClosing({
    param($sender, $e)
    if ($Script:Running) {
        $answer = [System.Windows.Forms.MessageBox]::Show(
            'هناك عملية قيد التنفيذ. هل تريد إيقافها والخروج؟',
            'تأكيد الخروج', 'YesNo', 'Question')
        if ($answer -ne 'Yes') { $e.Cancel = $true; return }
        $Script:CancelFlag = $true
        if ($Script:CurrentProc -ne $null) { Stop-ProcessTree -ProcessId $Script:CurrentProc.Id }
    }
})

# ---------------------------------------------------------------------
#  الإقلاع
# ---------------------------------------------------------------------
$Script:Cfg = Load-Config
Fill-FormFromConfig

$Script:LogPath = Join-Path $Script:Cfg.WorkDir ('cloture_session_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')
Add-Log 'برنامج الإقفال السنوي - الإصدار 1.0'
Add-Log ('التاريخ: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm'))
Add-Log ''
Add-Log 'الخطوات:'
Add-Log '  1. تصدير بيانات المنتجات والأشخاص والمستخدمين من القاعدة المصدر'
Add-Log '  2. حذف قاعدة الوجهة إن كانت موجودة'
Add-Log '  3. إنشاء قاعدة الوجهة'
Add-Log '  4. استيراد بنية القاعدة'
Add-Log '  5. استيراد البيانات الأولية'
Add-Log '  6. استيراد بيانات المصدر'
Add-Log '  7. ترحيل أرصدة الزبائن والموردين'
Add-Log '  8. إعادة تفعيل قيود المفاتيح الأجنبية'
Add-Log ''
Add-Log 'اكتب اسمَي القاعدتين في تبويب "الإقفال" ثم اضغط زر التنفيذ.'

[void]$form.ShowDialog()
$form.Dispose()
