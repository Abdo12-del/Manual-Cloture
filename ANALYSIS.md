# تحليل مشروع Manual-Cloture

> **نطاق التحليل:** كامل محتوى المستودع (3 ملفات) عند الـ commit `bbae78c`.
> **المنهجية:** قراءة الملفات سطراً بسطر، مع سكربتات Python لمقارنة بنية الجداول والتحقق من الأرقام.
> لم يكن ممكناً تشغيل خادم MySQL داخل بيئة التحليل لأن الوصول إلى الشبكة مقيّد، لذلك كل ملاحظة هنا مرفقة برقم السطر الذي يثبتها.

---

## 1. الخلاصة

**ما هو المشروع؟**
سكربت Windows Batch لتنفيذ **الإقفال السنوي اليدوي** (*Clôture de l'exercice*) لقاعدة بيانات MySQL.
القاعدة تابعة لبرنامج تسيير تجاري من تطوير **gamadev** (الوادي، الجزائر)، يغطي المخزون والمشتريات والمبيعات ونقطة البيع والخزينة والموظفين.
فكرة السكربت:
1. إنشاء قاعدة بيانات جديدة للسنة المالية الجديدة.
2. نقل البيانات الأساسية إليها: المنتجات، الزبائن والموردون، المستخدمون، ملف الشركة.
3. تحويل الأرصدة الختامية إلى أرصدة افتتاحية.

**التقييم العام:**

| المحور | التقييم |
|---|---|
| هل يعمل كما هو؟ | ❌ **لا.** خطأ إملائي في السطر 6 يمنع نقل أي بيانات، فتخرج القاعدة الجديدة شبه فارغة. |
| اكتمال منطق الإقفال | ⚠️ **ناقص.** لا يُرحَّل المخزون ولا رصيد الخزينة، ولا ينسخ نحو 26 جدولاً مرجعياً. |
| الأمان | 🔴 **خطير.** كلمة مرور `root` مكتوبة بوضوح في مستودع **عام**. |
| قابلية النقل | ⚠️ يعمل على MySQL 5.x / Windows فقط، ويفشل على MySQL 8+ وعلى Linux. |
| الصيانة | ⚠️ بلا توثيق، بلا معالجة للأخطاء، والسجلات لا تلتقط الأخطاء. |

---

## 2. محتوى المستودع

| الملف | الحجم | الدور |
|---|---|---|
| `Manual Cloture.bat` | 10 أسطر | سكربت التنفيذ. |
| `Schema16102016.sql` | 3148 سطراً (138 KB) | بنية القاعدة بدون بيانات، أُخذت في 16/10/2016 من قاعدة `ftecstockdb`. تحتوي 77 جدولاً و8 عروض (Views) ناقصة و14 دالة و21 إجراءً مخزّناً. |
| `PrimaryData20150428.sql` | 140 سطراً | بيانات أولية مصدّرة من MySQL 5.1.68 (Win32)، قاعدة `ss2015`، بتاريخ 17/11/2015. تنشئ جداول `userz` و`categoris` و`dosse` وتملؤها. |

لا يوجد في المستودع كود التطبيق نفسه، ولا README، ولا اختبارات.
أسماء مستعارة مثل `Expr1` و`personnez_1` في الاستعلامات توحي بأن التطبيق بُني ببيئة Visual Studio/.NET.

---

## 3. آلية العمل خطوة بخطوة

```
  ssSourceDB  (السنة المنتهية)               ssDesticationDB  (السنة الجديدة)
  ────────────────────────────               ─────────────────────────────────
  [1] mysqldump: 7 جداول + كل الروتينات ──►  DBCloture.sql
                                             [2] DROP DATABASE
                                             [3] CREATE DATABASE
                                             [4] ◄── Schema16102016.sql
                                             [5] ◄── PrimaryData20150428.sql
                        DBCloture.sql ──►    [6] ✗  sssDesticationDB   (خطأ إملائي)
                                             [7] UPDATE personnez  SET CreditInitial=solde, DetteInitial=soldefx
                                             [8] SET GLOBAL FOREIGN_KEY_CHECKS=1
```

| السطر | الأمر | الغرض | ملاحظة |
|---|---|---|---|
| 1 | `mysqldump --skip-triggers --routines … ssSourceDB articlesliste codbar personnez fav favliste userz dosse` | تصدير البيانات الأساسية. | يصدّر أيضاً أوامر `CREATE TABLE` الخاصة بالمصدر وكل روتيناته. علامة الاقتباس غير مغلقة. |
| 2 | `DROP DATABASE ssDesticationDB` | حذف قاعدة الوجهة. | بلا `IF EXISTS`، بلا تأكيد، بلا نسخة احتياطية. |
| 3 | `CREATE DATABASE ssDesticationDB` | إنشاء قاعدة الوجهة. | بلا تحديد `CHARACTER SET`. |
| 4 | `< Schema16102016.sql` | إنشاء البنية. | لقطة ثابتة من 2016. |
| 5 | `< PrimaryData20150428.sql` | إدخال بيانات افتراضية. | يعيد إنشاء `userz` و`dosse` ببنية 2015 الأقدم. |
| 6 | `mysql … sssDesticationDB < DBCloture.sql` | استيراد البيانات. | ❌ **ثلاثة حروف s**، فتكون النتيجة `ERROR 1049 Unknown database`. |
| 7 | `UPDATE … personnez SET CreditInitial = Solde, DetteInitial = Soldefx` | ترحيل الأرصدة. | يعمل على جدول فارغ بسبب السطر 6. |
| 8 | `SET GLOBAL FOREIGN_KEY_CHECKS=1` | — | بلا فائدة، فالمخطط لا يحتوي أي مفتاح أجنبي. |
| 9–10 | `pause` / `exit` | | |

**ما ينتج فعلاً عند تشغيل السكربت كما هو:**
- قاعدة جديدة فيها البنية فقط، ومعها بيانات `PrimaryData` الافتراضية:
  - مستخدمان: `Administrateur` بكلمة المرور `0000`، و`Utilisareur 1` بكلمة المرور `1111`.
  - تصنيف واحد اسمه `Toute`.
  - ملف شركة واحد: `gamadev inc.`.
- **لا منتجات، ولا زبائن، ولا موردون، ولا أرصدة.**
- جدولا `userz` و`dosse` ببنية قديمة ينقصها 5 أعمدة.

---

## 4. نموذج البيانات

### 4.1 أرقام
- **77 جدولاً حقيقياً:** 75 منها InnoDB، واثنان MyISAM هما `trushes` و`tsession`.
- **8 عروض:** `etatachat`، `etatstock`، `etatvente`، `listeachat`، `listebonachat`، `listebonvent`، `soliste`، `ventedetail`. تعريفاتها غير موجودة في الملف (انظر S1).
- **35 روتيناً:** 14 دالة و21 إجراءً مخزّناً.
- **صفر مفاتيح أجنبية، وصفر فهارس عادية.** لا يوجد سوى المفاتيح الأساسية و3 قيود `UNIQUE`.

### 4.2 الوحدات الوظيفية

| الوحدة | الجداول |
|---|---|
| المنتجات والمخزون | `articlesliste`, `categoris`, `models`, `typee`, `unites`, `unitconverter`, `codbar`, `articlesphotos`, `depots`, `depotproduit`, `stockes`, `stockreal`, `journentree`, `journsortie`, `journsortiefifo`, `trushes` (التالف)، والتحويل بين المخازن: `bontransfer`, `depotbontrans`, `journtransfert` |
| المشتريات | `bonachats`, `boncommand`, `bonretachat`, `journretacha` |
| المبيعات | `bonsliv` (وصل التسليم)، `boncont` (بيع الكونتوار/نقطة البيع)، `factures`/`factudetail`، `factpro` (فاتورة شكلية)، `devis`، مرتجعات البيع `bonretvent`/`journretvente`/`ventretdetail`، `taksitdetail` (البيع بالتقسيط) |
| الأطراف | `personnez` (نوع الشخص `idType`: ‏1 زبون، 2 مورد، 3 كلاهما)، `perstype`, `classification`, `wilaya`، المندوبون `commercial`/`commbon`/`commdetail`، `transporter`, `consom`, `registrecommerce` |
| الولاء والتسويق | `ccc`, `cccdetail`, `cccgame`, `cccgtrace`, `discountgame`, `promotion`، و`fav`/`favliste` (أزرار المفضلة في نقطة البيع) |
| الخزينة | `comptes`, `journcaisse`, `dailycaisse`, `tsession`, `payements`, `chequepaiement`, `modepayment`, `depancetype` (أنواع المصاريف)، `bonservice`/`servicesupplier`/`services`, `projects` |
| الموارد البشرية | `employer`, `employercomp`, `employerpaytyp`, `pointage`, `job` |
| الإدارة | `userz` (المستخدمون والصلاحيات)، `usersdoss`, `usersdepots`، `dosse` (الشركات/الملفات)، `yearz`, `appoption`، `iknowwtudid` (سجل التدقيق)، `activitys` |

### 4.3 خصائص التصميم
- **متعدد الشركات:** كل جدول تقريباً يضم `idDoss` في مفتاحه الأساسي.
- **متعدد السنوات بطريقتين معاً:** عمود `idyears` في جداول الحركات، **وأيضاً** قاعدة بيانات مستقلة لكل سنة (`ss2015`، … `ss2018`). القواعد المستقلة هي سبب وجود سكربت الإقفال أصلاً.
- **لا سلامة مرجعية على مستوى القاعدة.** كل الروابط بين الجداول يديرها التطبيق.
- **الأرصدة مخزّنة مسبقاً (cached)** في أعمدة مثل `personnez.solde/soldefx` و`employer.solde` و`commercial.solde`. تحدّثها إجراءات مثل `SetSolde` و`SetSoldeAll`.
- **تسميات مختلطة:** فرنسية وإنجليزية وعربية بحروف لاتينية، مع أخطاء إملائية مثل `adrese` و`depance` و`trushes` و`Desctication` و`Utilisareur`.

---

## 5. المشاكل المكتشفة

مستويات الخطورة: 🔴 حرج، 🟠 عالٍ، 🟡 متوسط، ⚪ منخفض.

### 5.1 السكربت `Manual Cloture.bat`

| # | الخطورة | المشكلة | الموضع | الأثر |
|---|---|---|---|---|
| B1 | 🔴 | اسم القاعدة مكتوب `sssDesticationDB` بثلاثة حروف s. | سطر 6 | يظهر `ERROR 1049 Unknown database` ولا تُنقل أي بيانات. أمر `UPDATE` في السطر 7 يعمل حينها على جدول فارغ. |
| B2 | 🔴 | لا توجد أي معالجة للأخطاء (لا `IF ERRORLEVEL` ولا `\|\| goto :error`). | كل الأسطر | إذا فشل التصدير في السطر 1 يكمل السكربت ويحذف الوجهة، وتمر الأخطاء بصمت. |
| B3 | 🔴 | `DROP DATABASE` يُنفَّذ دون شرط أو تأكيد أو نسخة احتياطية. | سطر 2 | إعادة تشغيل السكربت بعد بدء العمل على السنة الجديدة **تمسح كل حركاتها**. |
| B4 | 🟠 | المسارات نسبية (`.\…`) ولا يوجد `cd /d "%~dp0"`. | الأسطر 1، 4–8 | عند اختيار «تشغيل كمسؤول» يصبح المجلد الحالي `C:\Windows\System32`، فلا تُعثر على ملفات SQL. ويحدث ذلك بعد أن تكون الوجهة قد حُذفت. |
| B5 | 🟠 | تعارض في ترتيب الاستيراد: `PrimaryData` (2015) يعيد إنشاء `userz` و`dosse` ببنية أقدم من بنية `Schema` (2016). | سطر 5 | تضيع الأعمدة `canArchive` و`passDeleteComp` و`canDepance` و`canEditProductName` و`HeaderPath`، فتظهر أخطاء «Unknown column» في التطبيق. |
| B6 | 🟠 | `mysqldump` يُستدعى بدون `--no-create-info`. | سطر 1 | الجداول السبعة يُعاد إنشاؤها **ببنية المصدر** لا ببنية `Schema`، فتختلط نسختان من المخطط. |
| B7 | 🟠 | الخيار `--routines` يصدّر **كل** روتينات المصدر. | سطر 1 | تحل محل روتينات `Schema16102016.sql`، وإذا كان المصدر أقدم تعود نسخ قديمة. |
| B8 | 🟡 | علامات اقتباس غير مغلقة (`".\\DBCloture.sql`) مع شرطتين مائلتين. | الأسطر 1، 6 | يعمل في cmd بالصدفة، لكنه هشّ. |
| B9 | 🟡 | السجلات بلا فائدة: `>` يستبدل الملف بدل `>>`، ولا يُلتقط `stderr` (`2>&1`)، وأسماء الملفات متضاربة (`ss2017.txt`/`ss2018.txt`). | الأسطر 2، 3، 7، 8 | الأخطاء لا تُسجَّل إطلاقاً. |
| B10 | ⚪ | `SET GLOBAL FOREIGN_KEY_CHECKS=1`. | سطر 8 | لا معنى له لغياب المفاتيح الأجنبية، ويتطلب صلاحية SUPER. |
| B11 | ⚪ | عدة نقاط صغيرة:<br>• أسماء القواعد مكتوبة يدوياً في 6 مواضع.<br>• `-P3306` غائب عن `mysqldump`.<br>• `DROP` بلا `IF EXISTS`.<br>• `CREATE DATABASE` بلا charset.<br>• السكربت يفترض أن `mysql` موجود في PATH. | — | أخطاء بشرية متوقعة عند التعديل اليدوي كل سنة. |

### 5.2 نواقص منطق الإقفال (تبقى حتى بعد إصلاح B1)

| # | الخطورة | ما لا يُرحَّل | التفصيل |
|---|---|---|---|
| F1 | 🔴 | **المخزون** | `articlesliste.QTE` يمثل الكمية **الابتدائية**. الدالة `GetQteState` (سطر 2315) تحسب المخزون هكذا: `QTE + المدخلات − المخرجات`.<br>السكربت ينسخ `QTE` كما هو دون تحديثه بالمخزون الختامي، وجداول الحركات تبدأ فارغة.<br>النتيجة: **مخزون السنة الجديدة = مخزون بداية السنة السابقة.** |
| F2 | 🔴 | **الخزينة والحسابات** | جدول `comptes` (ومعه `MontantInitial`) لا يُنسخ أصلاً، فيبدأ رصيد الصندوق والبنك من صفر.<br>الدالة `GetInitialMontant` موجودة ويمكن استعمالها لحساب الرصيد الختامي. |
| F3 | 🟠 | الجداول المرجعية (نحو 26 جدولاً) | `categoris` (يبقى فيه «Toute» فقط)، `models`, `typee`, `unites`, `unitconverter`, `perstype`, `classification`, `wilaya`, `job`, `modepayment`, `depots`, `stockes`, `depancetype`, `transporter`, `projects`, `registrecommerce`, `appoption`, `usersdoss`, `usersdepots`, `articlesphotos`…<br>النتيجة: المنتجات والأشخاص المنسوخون يشيرون إلى معرّفات **غير موجودة**. |
| F4 | 🟠 | أرصدة الأطراف الأخرى | لا يُرحَّل أي مما يلي:<br>• `commercial.solde`<br>• `employer.solde`<br>• `servicesupplier.solde`<br>• نقاط الولاء في `ccc`<br>• الأقساط غير المدفوعة في `taksitdetail`<br>• المخزون لكل مستودع في `depotproduit` |
| F5 | 🟠 | الاعتماد على رصيد مخزَّن قد يكون قديماً | السطر 7 ينسخ `solde` و`soldefx` دون استدعاء `SetSoldeAll()` قبل التصدير.<br>ويوجد **صيغتان مختلفتان** لحساب الرصيد:<br>• `SetSolde` (سطر 2754): تحسب كل الوصولات وتطرح الأقساط **المدفوعة**.<br>• `SetSoldeAll` (سطر 2834): تستثني الوصولات `VAC%` وتضيف الأقساط **غير المدفوعة**. |
| F6 | 🟡 | بيانات السنة الجديدة | لا يُحدَّث `yearz` ولا `dosse.idyears` ولا `userz.dbname` بالسنة الجديدة. يجب التحقق من طريقة استخدام التطبيق لها. |

### 5.3 ملف المخطط `Schema16102016.sql`

| # | الخطورة | المشكلة | الموضع |
|---|---|---|---|
| S1 | 🟠 | **العروض الثمانية ناقصة.** الملف مقطوع بعد الروتينات، فلا يبقى من كل عرض إلا «الجدول المؤقت» `/*!50001 CREATE TABLE … ENGINE=MyISAM */` بأعمدة `tinyint`، بدلاً من `CREATE VIEW`.<br>أي تقرير في التطبيق يعتمد على `etatstock` أو `etatvente` أو `listebonvent` أو `ventedetail`… سيعيد نتائج فارغة. | الأسطر 815، 833، 865، 1276، 1296، 1317، 1568، 1833 |
| S2 | 🟠 | لقطة ثابتة من أكتوبر 2016، بينما تشير أسماء ملفات السجل إلى استخدام السكربت في 2017/2018. أي عمود أُضيف إلى التطبيق بعد ذلك التاريخ سيغيب عن القاعدة الجديدة. | — |
| S3 | 🟠 | **غير متوافق مع MySQL 8+:**<br>• الوضع `NO_AUTO_CREATE_USER` (مكرر 35 مرة) أُزيل في 8.0، فيظهر `ERROR 1231`.<br>• 9 دوال بلا `DETERMINISTIC` أو `READS SQL DATA`، فيظهر `ERROR 1418` لأن binlog مفعّل افتراضياً في 8.0.<br>وبما أن `mysql` يتوقف عند أول خطأ، **لن يُنشأ أي روتين**. | من السطر 1909 |
| S4 | 🟡 | **غير متوافق مع Linux:** داخل الروتينات أسماء جداول بحالة أحرف مختلفة عن التعريف (`BonAchats`, `bonRetVent`, `CCC`, `CCCdetail`). تفشل عند `lower_case_table_names=0`. | 2011، 2035، 2064، 2098، 2736، 2738 |
| S5 | 🟠 | **تقريب إلى أعداد صحيحة:**<br>• **30 متغيراً** مُعرَّفاً بـ `DECIMAL` دون دقة، أي `DECIMAL(10,0)`، في `SetSolde` و`SetSoldeAll` و`SetTotals` و`SetTotalAchat` و`EmployerSolde` وغيرها.<br>• `GetPrixAchat` و`GetQteState` تُرجعان `decimal(10,0)`.<br>النتيجة: الأرصدة والمجاميع وأسعار الشراء **تفقد الكسور**، والكميات الموزونة تُقرَّب (2.5 كغ تصبح 3). | 2157–3080 |
| S6 | 🟡 | **أخطاء منطقية في `GetCaisse` و`MoneyMovement`:**<br>• الشرط `boncont.iddoss = 1` مكتوب حرفياً بدل المعامل `idos`.<br>• أولوية `AND/OR` خاطئة (`… AND MEntre = 0 OR MEntre is null`)، فتدخل سطور من كل الشركات ومن سطور الموظفين.<br>• السطور المحذوفة (`deleted`) غير مستبعدة في فرعي المصاريف والمداخيل الأخرى. | 1934–1939، 2544–2549 |
| S7 | 🟡 | **ثلاث صيغ مختلفة لحساب المخزون:**<br>• `GetQteState`: تتجاهل المرتجعات والتالف.<br>• `GetQteByDates`: لا تضم الكمية الابتدائية `QTE`.<br>• `UpdateQteInDepot`: تحسب لكل مستودع على حدة. | 2214، 2315، 3100 |
| S8 | 🟡 | **لا فهارس** غير المفاتيح الأساسية.<br>كل الدوال التي تبحث بـ `RefArt` أو `idBL` أو `idbonCont` أو `DateSortie` تمسح الجداول بالكامل.<br>`SetTotals` و`PoidsParCategorie` ستبطئان كثيراً مع نمو البيانات. | — |
| S9 | ⚪ | نقاط ثانوية:<br>• الملف منزوع الترويسة (`SET NAMES` و`FOREIGN_KEY_CHECKS=0` و`SQL_MODE`…).<br>• خلط بين محركين: `trushes` و`tsession` على MyISAM غير المعاملاتي.<br>• قيود `UNIQUE` عامة لا تشمل `idDoss` (`Ninven`, `cccNom`, `codBar`)، فتتعارض بين الشركات. | — |
| S10 | 🟡 | **7 روتينات تستقبل `RefArt` بطول أقصر من العمود** (`varchar(50)`):<br>• `varchar(20)` في `FIFOMovement` و`GetMovement` و`ProductMovement` و`ProductMovementDates`.<br>• `varchar(22)` في `GetQteState`.<br>• `nvarchar(30)` في `GetPrixAchat` و`GetPAchFromLastVent`.<br>الروتينات تعمل بوضع `STRICT_TRANS_TABLES`، لذلك أي مرجع منتج أطول يسبب `ERROR 1406 Data too long`. | 2155، 2186، 2315، 2475، 2492، 2654، 2699 |

### 5.4 الأمان

| # | الخطورة | المشكلة |
|---|---|---|
| X1 | 🔴 | كلمة مرور `root` لـ MySQL مكتوبة بوضوح **8 مرات** في `Manual Cloture.bat`، والمستودع **عام** على GitHub.<br>(حُجبت القيمة من هذا التقرير عمداً، وهي ظاهرة في الملف الأصلي وفي تاريخ المستودع.)<br>إذا كانت هي نفسها المستعملة لدى الزبائن، فأي جهاز يصل إلى المنفذ 3306 يستطيع الدخول بصلاحيات كاملة. |
| X2 | 🟠 | تمرير كلمة المرور في سطر الأوامر (`-p…`) يجعلها ظاهرة في قائمة العمليات. |
| X3 | 🟠 | كلمات مرور التطبيق مخزّنة كنص صريح في `userz.passWord`، والافتراضية منها ضعيفة (`0000`, `1111`). |
| X4 | 🟡 | استعمال `root` في عملية لا تحتاج كل صلاحياته. |

---

## 6. التوصيات حسب الأولوية

### P0 — فوراً
1. **تغيير كلمة مرور root** في كل مكان تُستعمل فيه.
   - حذفها من تاريخ Git (`git filter-repo` أو BFG)، أو تحويل المستودع إلى خاص.
   - استعمال ملف إعدادات (`--defaults-extra-file`) أو `mysql_config_editor` بدل `-p`.
   - إنشاء مستخدم MySQL مخصص للإقفال بصلاحيات محدودة.
2. **تصحيح السطر 6:** `sssDesticationDB` ← `ssDesticationDB`. هذا هو الحد الأدنى ليعمل السكربت.
3. إضافة `cd /d "%~dp0"` في بداية السكربت، و`|| goto :error` بعد كل أمر، وإعادة توجيه المخرجات إلى السجل بصيغة `>>log 2>&1`.
4. أخذ نسخة احتياطية كاملة من المصدر **ومن الوجهة إن وُجدت** قبل أي `DROP`، ورفض المتابعة إذا كانت الوجهة موجودة.

### P1 — صحة الإقفال
5. توليد البنية **من قاعدة المصدر نفسها** (`mysqldump --no-data --routines`) بدل الملف الثابت. هذا يعالج S1 وS2 وB5 إلى B7 دفعة واحدة، ويُغني عن `PrimaryData20150428.sql`.
6. نسخ البيانات بالخيارات `--no-create-info --complete-insert --hex-blob`، مع توسيع قائمة الجداول لتشمل الجداول المرجعية (F3).
7. استدعاء `CALL SetSoldeAll();` على المصدر قبل التصدير (F5)، بعد توحيد صيغة الرصيد مع `SetSolde`.
8. ترحيل المخزون الختامي إلى `articlesliste.QTE`، والكميات إلى `depotproduit` (F1). يجب اعتماد **صيغة المخزون نفسها التي يعرضها التطبيق** (S7).
9. ترحيل رصيد الحسابات إلى `comptes.MontantInitial` عبر `GetInitialMontant` (F2)، وكذلك أرصدة المندوبين والموظفين ومزودي الخدمات ونقاط الولاء (F4).
10. تحديث `yearz` و`dosse.idyears`، والتحقق من دور `userz.dbname` (F6).

### P2 — المتانة والأداء
11. إصلاح الروتينات:
    - استبدال `DECIMAL` بـ `DECIMAL(18,6)`.
    - وضع أقواس صحيحة حول شروط `AND/OR`.
    - استبدال `iddoss = 1` بالمعامل `idos`.
    - استبعاد السطور المحذوفة `deleted`.
    - توسيع معاملات `RefArt` إلى `varchar(50)` (S10).
12. إضافة فهارس، مثل:
    - `(idDoss, RefArt)` على جداول الحركات.
    - `(idDoss, idBL)` و`(idDoss, idbonCont)` على `journsortie`.
    - `(idDoss, Client)` على `bonsliv`.
    - `(idDoss, Fournisseur)` على `bonachats`.
13. التوافق مع MySQL 8:
    - حذف `NO_AUTO_CREATE_USER`.
    - إضافة `READS SQL DATA` للدوال.
    - توحيد حالة الأحرف في أسماء الجداول.

### P3 — الصيانة
14. تمرير أسماء القواعد كمعاملات (`Cloture.bat ss2025 ss2026 2026-01-01`)، وجعل مسار `mysql` متغيراً.
15. كتابة README يشرح المتطلبات والخطوات.
16. إضافة تقرير تحقق بعد الإقفال: عدد المنتجات والأشخاص، ومجموع الأرصدة في المصدر مقارنةً بالوجهة.

---

## 7. هيكل مقترح لسكربت محسَّن

> **للتوضيح فقط، ولم يُختبر.** يُظهر البنية التي تعالج المشاكل أعلاه.
> تعليقات الكود بالإنجليزية عمداً، لأن cmd لا يعرض العربية بشكل سليم افتراضياً.

```bat
@echo off
setlocal
cd /d "%~dp0"
if "%~3"=="" (echo Usage: %~nx0 SOURCE_DB DEST_DB NEW_YEAR_START_DATE & exit /b 1)
set "SRC=%~1"
set "DST=%~2"
set "D0=%~3"
set "OPT=--defaults-extra-file=cloture.cnf"
set "LOG=cloture_%DST%.log"
set "TABLES=articlesliste codbar personnez fav favliste userz dosse categoris models typee unites unitconverter perstype classification wilaya job modepayment comptes depots stockes depancetype transporter projects registrecommerce appoption usersdoss usersdepots employer employerpaytyp commercial servicesupplier ccc"

rem --- 0) Never overwrite an existing destination database
mysql %OPT% -N -e "SHOW DATABASES LIKE '%DST%'" | findstr /x /i "%DST%" >nul && (echo %DST% already exists - aborting & exit /b 1)

rem --- 1) Refresh cached balances, then take a full backup of the source
mysql %OPT% %SRC% -e "CALL SetSoldeAll();" >>"%LOG%" 2>&1 || goto :error
mysqldump %OPT% --single-transaction --routines --hex-blob %SRC% > "backup_%SRC%.sql" 2>>"%LOG%" || goto :error

rem --- 2) Schema taken from the source itself (tables + views + routines), data without CREATE TABLE
mysqldump %OPT% --no-data --routines --skip-triggers %SRC% > "schema_%SRC%.sql" 2>>"%LOG%" || goto :error
mysqldump %OPT% --no-create-info --complete-insert --hex-blob --skip-triggers %SRC% %TABLES% > "data_%SRC%.sql" 2>>"%LOG%" || goto :error

rem --- 3) Create and load the destination
mysql %OPT% -e "CREATE DATABASE %DST% CHARACTER SET utf8 COLLATE utf8_general_ci;" >>"%LOG%" 2>&1 || goto :error
mysql %OPT% %DST% < "schema_%SRC%.sql" >>"%LOG%" 2>&1 || goto :error
mysql %OPT% %DST% < "data_%SRC%.sql"   >>"%LOG%" 2>&1 || goto :error

rem --- 4) Opening balances (stock formula must match the one used by the application - see S7;
rem        note GetQteState takes varchar(22) and rounds to integers - see S5/S10)
mysql %OPT% %DST% -e "UPDATE personnez SET CreditInitial=IFNULL(solde,0), DetteInitial=IFNULL(soldefx,0);" >>"%LOG%" 2>&1 || goto :error
mysql %OPT% %DST% -e "UPDATE comptes SET MontantInitial=%SRC%.GetInitialMontant(idDoss,'%D0%',idCompte);" >>"%LOG%" 2>&1 || goto :error
mysql %OPT% %DST% -e "UPDATE articlesliste SET QTE=%SRC%.GetQteState(RefArt,idDoss);" >>"%LOG%" 2>&1 || goto :error

echo Cloture %SRC% -^> %DST% OK
exit /b 0

:error
echo Cloture FAILED - see %LOG%
exit /b 1
```

محتوى `cloture.cnf` (يُحفظ خارج Git):

```ini
[client]
user=cloture
password=********
port=3306
```

---

## 8. الواجهة الرسومية الجديدة

أُضيف برنامج بواجهة رسومية يحل محل تعديل الأمر يدوياً كل سنة:

| الملف | الدور |
|---|---|
| `Cloture.bat` | مشغّل النقر المزدوج. |
| `Cloture.ps1` | البرنامج (PowerShell + Windows Forms). |
| `README.md` | دليل الاستعمال. |
| `Cloture.settings.xml` | يُنشأ عند أول حفظ للإعدادات، ومستثنى من Git. |

**المبدأ:** حقلان لاسمَي القاعدتين وزر واحد للتنفيذ، والإعدادات (الخادم، المستخدم، كلمة المرور،
المسارات) تُدخل مرة واحدة وتُحفظ. كلمة المرور لم تعد مكتوبة في أي سكربت.

**المنطق الداخلي:** نفس عملية السكربت القديم بالترتيب نفسه، مع التصحيحات التالية:

| المشكلة في التحليل | الحالة في البرنامج الجديد |
|---|---|
| B1 — الخطأ الإملائي في السطر 6 | ✅ مصحَّح: الاسم يُؤخذ من حقل موحّد. |
| B2 — لا معالجة للأخطاء | ✅ يتوقف عند أول خطوة فاشلة ويعرض رمز الخطأ. |
| B3 — حذف بلا حماية | ✅ يفحص وجود قاعدة الوجهة أولاً ويرفض التنفيذ، ويأخذ نسخة احتياطية عند السماح. |
| B4 — مجلد `System32` | ✅ المشغّل ينفّذ `cd /d "%~dp0"`. |
| B9 — سجلات لا تلتقط الأخطاء | ✅ كل عملية لها ملف سجل يجمع المخرجات والأخطاء. |
| X1/X2 — كلمة المرور في المستودع | ✅ لم تعد في السكربت، وتُحفظ مشفّرة مرتبطة بالجهاز. |
| — | ➕ خيار معاينة يعرض الأوامر الثمانية دون تنفيذ. |
| B5، B6، B7، F1، F2، F3، F4، F6 | ❌ **لم تُعالَج بعد** (القسم 5.2). البرنامج ينقل نفس البيانات السبعة فقط. |

---

## 9. أسئلة تحتاج تأكيداً من صاحب التطبيق
1. ما صيغة المخزون المعتمدة في شاشة التطبيق؟ هل هي `GetQteState` أم العرض `etatstock` أم غيرهما؟
2. هل ينشئ التطبيق العروض (Views) بنفسه عند التشغيل؟ هذا يحدد خطورة S1.
3. ما دور `userz.dbname` و`yearz`؟ وكيف يختار التطبيق قاعدة السنة التي يعمل عليها؟
4. هل تُسجَّل الدفعات في جدول `payements` أم كوصولات `REGL%` في `bonsliv`؟ `SetSolde` لا يقرأ `payements` إطلاقاً.
5. ما إصدار MySQL المستعمل حالياً لدى الزبائن؟ الملفات تشير إلى 5.1.68، وقد انتهى دعمه منذ 2013.
