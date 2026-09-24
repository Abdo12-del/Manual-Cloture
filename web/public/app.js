'use strict';
// =====================================================================
//  app.js - منطق الواجهة: SSE للحالة/السجل + استدعاءات API
// =====================================================================
const $ = (id) => document.getElementById(id);
const logEl = $('log');
const statusEl = $('status');
const stepTitle = $('stepTitle');
const progressFill = $('progressFill');
const badge = $('serverBadge');
const btnRun = $('btnRun');
const btnCancel = $('btnCancel');

// ---------------- التبويبات ----------------
document.querySelectorAll('.tab').forEach(t => {
  t.addEventListener('click', () => {
    document.querySelectorAll('.tab').forEach(x => x.classList.remove('active'));
    document.querySelectorAll('.tabpane').forEach(x => x.classList.remove('active'));
    t.classList.add('active');
    $('tab-' + t.dataset.tab).classList.add('active');
  });
});

// ---------------- السجل ----------------
function appendLog(line) {
  const d = new Date().toTimeString().slice(0, 8);
  logEl.textContent += '[' + d + '] ' + line + '\n';
  logEl.scrollTop = logEl.scrollHeight;
}

// ---------------- حالة عامة ----------------
let state = null;
function applyState(s) {
  state = s;
  statusEl.textContent = s.status;
  statusEl.className = 'status' + (s.error ? ' err' : (s.running ? '' : (String(s.status).includes('اكتمل') ? ' ok' : '')));
  if (s.step > 0) progressFill.style.width = Math.min(100, (s.step / s.total) * 100) + '%';
  stepTitle.textContent = s.step ? ('الخطوة ' + s.step + ' من ' + s.total) : '';
  btnRun.disabled = s.running;
  btnCancel.disabled = !s.running;
  // الشارة
  if (s.databases && s.databases.length) {
    badge.textContent = 'الخادم التجريبي: ' + s.databases.length + ' قاعدة';
    badge.className = 'badge ok';
  } else {
    badge.textContent = 'لا توجد قواعد بعد';
    badge.className = 'badge';
  }
  renderDemoStatus();
}
async function refreshState() {
  try {
    const r = await fetch('/api/state');
    applyState(await r.json());
  } catch {}
}

// ---------------- SSE ----------------
function connectSSE() {
  const es = new EventSource('/api/stream');
  es.addEventListener('log', (e) => appendLog(JSON.parse(e.data)));
  es.addEventListener('progress', (e) => {
    const p = JSON.parse(e.data);
    progressFill.style.width = Math.min(100, (p.step / p.total) * 100) + '%';
    stepTitle.textContent = p.title || ('الخطوة ' + p.step + ' من ' + p.total);
  });
  es.addEventListener('state', () => refreshState());
  es.addEventListener('finished', () => refreshState());
  es.onerror = () => {};
}

// ---------------- تنفيذ ----------------
btnRun.addEventListener('click', async () => {
  const src = $('srcDb').value.trim();
  const dst = $('dstDb').value.trim();
  if (!src || !dst) { alert('الرجاء كتابة اسمَي القاعدتين.'); return; }
  appendLog('');
  appendLog('>> بدء الطلب: ' + src + ' -> ' + dst);
  btnRun.disabled = true;
  try {
    const r = await fetch('/api/run', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        srcDb: src, dstDb: dst,
        allowDelete: $('allowDelete').checked,
        dryRun: $('dryRun').checked,
      }),
    });
    const j = await r.json();
    if (!j.ok) { appendLog('>> خطأ: ' + j.error); btnRun.disabled = false; }
  } catch (e) {
    appendLog('>> خطأ في الاتصال بالخادم: ' + e.message);
    btnRun.disabled = false;
  }
});
btnCancel.addEventListener('click', async () => {
  try { await fetch('/api/cancel', { method: 'POST' }); } catch {}
});

// ---------------- الإعدادات ----------------
let savedSettings = null;
function fillSettings(s) {
  savedSettings = s;
  $('cHost').value = s.host;
  $('cPort').value = s.port;
  $('cUser').value = s.user;
  $('cPass').value = s.password || '';
  $('cSchema').value = s.schemaFile;
  $('cPrimary').value = s.primaryFile;
  $('cWork').value = s.workDir;
  // حقلا القاعدتين يظلان فارغين عند فتح البرنامج (طلب المستخدم)
}
async function loadSettings() {
  try {
    const r = await fetch('/api/settings');
    fillSettings(await r.json());
  } catch {}
}
$('btnSave').addEventListener('click', async () => {
  const body = {
    host: $('cHost').value.trim(),
    port: $('cPort').value.trim(),
    user: $('cUser').value.trim(),
    password: $('cPass').value,
    schemaFile: $('cSchema').value.trim(),
    primaryFile: $('cPrimary').value.trim(),
    workDir: $('cWork').value.trim(),
  };
  const r = await fetch('/api/settings', {
    method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body),
  });
  const j = await r.json();
  const m = $('saveMsg');
  m.textContent = j.ok ? 'تم حفظ الإعدادات.' : 'فشل الحفظ.';
  m.className = 'status ' + (j.ok ? 'ok' : 'err');
  setTimeout(() => m.textContent = '', 2500);
});
$('btnTest').addEventListener('click', async () => {
  // احفظ أولًا
  const body = {
    host: $('cHost').value.trim(), port: $('cPort').value.trim(),
    user: $('cUser').value.trim(), password: $('cPass').value,
  };
  await fetch('/api/settings', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  const m = $('testResult');
  m.textContent = 'جارٍ الاختبار…'; m.className = 'status';
  const r = await fetch('/api/test', { method: 'POST' });
  const j = await r.json();
  if (j.ok) {
    m.textContent = '✓ تم الاتصال — الإصدار ' + j.version + ' — قواعد: ' + j.databases.join(', ');
    m.className = 'status ok';
  } else {
    m.textContent = '✗ فشل: ' + j.error;
    m.className = 'status err';
  }
});

// ---------------- بيانات التجربة ----------------
async function renderDemoStatus() {
  try {
    const r = await fetch('/api/demo/status');
    const d = await r.json();
    const parts = [];
    if (d.source) parts.push('المصدر ' + d.source.db + ': ' + d.source.tables + ' جدولًا (' + fmtCounts(d.source.counts) + ')');
    if (d.destination) parts.push('الوجهة ' + d.destination.db + ': ' + d.destination.tables + ' جدولًا');
    $('demoStatus').textContent = parts.length ? parts.join('  ·  ') : 'لا توجد قواعد تجريبية بعد.';
  } catch {}
}
function fmtCounts(c) {
  return Object.entries(c || {}).filter(([, v]) => v != null).map(([k, v]) => k + ':' + v).join('، ');
}
$('btnDemo').addEventListener('click', async () => {
  btnRun.disabled = false;
  appendLog('');
  appendLog('>> تجهيز بيانات التجربة (ss2025)...');
  const r = await fetch('/api/demo/setup', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ force: true }) });
  const j = await r.json();
  if (!j.ok) appendLog('>> خطأ: ' + j.error);
  await refreshState();
});
$('btnDemoReset').addEventListener('click', async () => {
  appendLog('');
  appendLog('>> حذف كل قواعد التجربة...');
  const r = await fetch('/api/demo/reset', { method: 'POST' });
  const j = await r.json();
  if (j.ok) appendLog('>> حُذفت: ' + (j.dropped.join(', ') || 'لا شيء'));
  await refreshState();
});

// ---------------- بدء ----------------
loadSettings();
refreshState();
connectSSE();
setInterval(refreshState, 2500);
