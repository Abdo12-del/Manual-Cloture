'use strict';
// =====================================================================
//  server.js - خادم برنامج الإقفال السنوي
//
//  - يقدّم الواجهة الرسومية (Arabic RTL)
//  - يبدأ خادم MySQL التجريبي (بروتوكول MySQL حقيقي فوق SQLite)
//  - يقدم API: الإعدادات، اختبار الاتصال، تنفيذ الإقفال، الإلغاء،
//    بث السجل (SSE)، تجهيز/حالة بيانات التجربة
// =====================================================================
const path = require('path');
const fs = require('fs');
const http = require('http');
const express = require('express');

const { startServer: startMysql, PORT: MYSQL_PORT } = require('./mysql-server');
const { runCloture, job, TABLES, TOTAL_STEPS } = require('./closure');
const demo = require('./demo-loader');
const { engine } = require('./engine');

const PORT = parseInt(process.env.PORT || '3000', 10);
const WEB_DIR = __dirname;
const SETTINGS_FILE = path.join(WEB_DIR, 'cloture-settings.json');
const REPO = path.join(WEB_DIR, '..');

// ---------------- الإعدادات ----------------
function defaultSettings() {
  return {
    host: '127.0.0.1',
    port: String(MYSQL_PORT),
    user: 'root',
    password: '',
    schemaFile: path.join(REPO, 'Schema16102016.sql'),
    primaryFile: path.join(REPO, 'PrimaryData20150428.sql'),
    workDir: path.join(WEB_DIR, 'work'),
    srcDb: '',
    dstDb: '',
  };
}
function loadSettings() {
  const d = defaultSettings();
  try {
    const s = JSON.parse(fs.readFileSync(SETTINGS_FILE, 'utf8'));
    return { ...d, ...s };
  } catch { return d; }
}
function saveSettings(s) {
  fs.writeFileSync(SETTINGS_FILE, JSON.stringify(s, null, 2), 'utf8');
}

const app = express();
app.use(express.json({ limit: '2mb' }));
app.use(express.static(path.join(WEB_DIR, 'public')));

// ---------------- بث SSE ----------------
const sseClients = new Set();
app.get('/api/stream', (req, res) => {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    Connection: 'keep-alive',
    'X-Accel-Buffering': 'no',
  });
  res.write('retry: 2000\n\n');
  sseClients.add(res);
  req.on('close', () => sseClients.delete(res));
});
function broadcast(event, data) {
  const msg = 'event: ' + event + '\ndata: ' + JSON.stringify(data) + '\n\n';
  for (const c of sseClients) { try { c.write(msg); } catch {} }
}
job.subscribe = (fn) => { job.listeners.add(fn); return () => job.listeners.delete(fn); };
job.subscribe((event, data) => broadcast(event, data));

// ---------------- حالة عامة ----------------
app.get('/api/state', (req, res) => {
  let dbs = [];
  try {
    const conn = { db: null, user: 'root', fkChecks: true, charset: 'utf8' };
    dbs = engine.execute(conn, 'SHOW DATABASES').rows.map(r => r[0]);
  } catch {}
  res.json({
    running: job.running,
    step: job.step,
    total: TOTAL_STEPS,
    status: job.status,
    error: job.error,
    result: job.result,
    tables: TABLES,
    mysqlDemoPort: MYSQL_PORT,
    databases: dbs,
    settings: loadSettings(),
  });
});

// ---------------- الإعدادات ----------------
app.get('/api/settings', (req, res) => res.json(loadSettings()));
app.post('/api/settings', (req, res) => {
  const s = loadSettings();
  const b = req.body || {};
  for (const k of ['host', 'port', 'user', 'password', 'schemaFile', 'primaryFile', 'workDir', 'srcDb', 'dstDb']) {
    if (b[k] !== undefined) s[k] = String(b[k]);
  }
  s.port = String(s.port).replace(/\D/g, '').slice(0, 5) || '3306';
  saveSettings(s);
  res.json({ ok: true, settings: s });
});

// ---------------- اختبار الاتصال ----------------
app.post('/api/test', async (req, res) => {
  const mysql = require('mysql2/promise');
  const s = loadSettings();
  try {
    const conn = await mysql.createConnection({
      host: s.host,
      port: parseInt(s.port, 10) || 3306,
      user: s.user,
      password: s.password || '',
      connectTimeout: 6000,
    });
    const [r] = await conn.query('SELECT VERSION() AS v, CURRENT_USER() AS u');
    const [dbs] = await conn.query('SHOW DATABASES');
    await conn.end();
    res.json({ ok: true, version: r[0].v, user: r[0].u, databases: dbs.map(x => Object.values(x)[0]) });
  } catch (e) {
    res.json({ ok: false, error: e.message });
  }
});

// ---------------- تنفيذ الإقفال ----------------
app.post('/api/run', (req, res) => {
  if (job.running) return res.status(409).json({ ok: false, error: 'there is a running job' });
  const s = loadSettings();
  const b = req.body || {};
  const opts = {
    srcDb: String(b.srcDb || s.srcDb || '').trim(),
    dstDb: String(b.dstDb || s.dstDb || '').trim(),
    allowDelete: !!b.allowDelete,
    dryRun: !!b.dryRun,
  };
  if (!opts.srcDb || !opts.dstDb) {
    return res.status(400).json({ ok: false, error: 'الرجاء كتابة اسمَي قاعدة المصدر والوجهة.' });
  }
  // ملاحظة: أسماء القاعدتين لا تُحفظ — الواجهة تفتح فارغة في كل مرة (بناءً على طلب المستخدم)
  runCloture(s, opts).catch(e => { /* مُعالج داخل runCloture */ });
  res.json({ ok: true });
});

app.post('/api/cancel', (req, res) => {
  if (!job.running) return res.json({ ok: false, error: 'no job running' });
  job.cancel = true;
  res.json({ ok: true });
});

// ---------------- بيانات التجربة ----------------
app.post('/api/demo/setup', (req, res) => {
  const force = !!(req.body || {}).force;
  try {
    const report = demo.setupDemoData(force, (l) => broadcast('log', l));
    res.json({ ok: true, report });
  } catch (e) {
    res.json({ ok: false, error: e.message });
  }
});
app.get('/api/demo/status', (req, res) => res.json(demo.demoStatus()));
app.post('/api/demo/reset', (req, res) => {
  const dropped = demo.resetDemo((l) => broadcast('log', l));
  res.json({ ok: true, dropped });
});

// ---------------- التشغيل ----------------
async function main() {
  // 1) خادم MySQL التجريبي
  let mysqlPort = MYSQL_PORT;
  try {
    const srv = await startMysql(MYSQL_PORT);
    console.log('[mysql-demo] listening on ' + MYSQL_PORT);
  } catch (e) {
    if (e.code === 'EADDRINUSE') {
      mysqlPort = 3307;
      await startMysql(mysqlPort);
      console.log('[mysql-demo] 3306 occupied, listening on ' + mysqlPort);
    } else throw e;
  }

  // 2) خادم الويب
  const server = http.createServer(app);
  server.listen(PORT, '0.0.0.0', () => {
    console.log('[web] listening on ' + PORT + ' (mysql demo on ' + mysqlPort + ')');
  });

  // 3) إن لم توجد بيانات تجريبية، أنشئها تلقائيًا عند أول تشغيل
  if (!engine.reg['ss2025']) {
    setTimeout(() => {
      try {
        console.log('[demo] initializing ss2025 demo database...');
        demo.setupDemoData(false, (l) => console.log('[demo] ' + l));
        console.log('[demo] ss2025 ready');
      } catch (e) {
        console.error('[demo] init failed:', e.message);
      }
    }, 500);
  }
}

main().catch(e => {
  console.error('fatal:', e);
  process.exit(1);
});
