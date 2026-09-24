'use strict';
// =====================================================================
//  closure.js - محرك الإقفال السنوي (8 خطوات)
//
//  يعمل عبر عميل MySQL حقيقي (mysql2) ضد أي خادم MySQL/MariaDB:
//   1. تصدير بيانات الجداول السبعة من المصدر
//   2. حذف قاعدة الوجهة إن كانت موجودة (بعد نسخة احتياطية)
//   3. إنشاء قاعدة الوجهة
//   4. استيراد بنية القاعدة (Schema)
//   5. استيراد البيانات الأولية (PrimaryData)
//   6. استيراد بيانات المصدر
//   7. ترحيل الأرصدة: UPDATE personnez SET CreditInitial=Solde, DetteInitial=Soldefx
//   8. SET GLOBAL FOREIGN_KEY_CHECKS=1
//
//  حمايات: معاينة بدون تنفيذ، فحص وجود الوجهة قبل أي أمر، نسخة احتياطية،
//          تسجيل كل شيء في ملف، إيقاف عند أول خطأ، إمكانية الإلغاء.
// =====================================================================
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const S = require('./sql-file');

const TABLES = ['articlesliste', 'codbar', 'personnez', 'fav', 'favliste', 'userz', 'dosse'];
const TOTAL_STEPS = 8;

// ---------------- أدوات ----------------
function sqlVal(v) {
  if (v === null || v === undefined) return 'NULL';
  if (typeof v === 'number') return String(v);
  if (v instanceof Date) return "'" + v.toISOString().replace('T', ' ').slice(0, 19) + "'";
  if (Buffer.isBuffer(v)) return "x'" + v.toString('hex') + "'";
  if (typeof v === 'boolean') return v ? '1' : '0';
  let s = String(v);
  s = s.replace(/\\/g, '\\\\').replace(/'/g, "\\'")
       .replace(/\n/g, '\\n').replace(/\r/g, '\\r')
       .replace(/\0/g, '\\0').replace(/\x1a/g, '\\Z');
  return "'" + s + "'";
}

class Job {
  constructor() {
    this.running = false;
    this.cancel = false;
    this.step = 0;
    this.title = '';
    this.status = 'جاهز.';
    this.error = null;
    this.result = null;
    this.listeners = new Set();
  }
  emit(event, data) {
    for (const l of this.listeners) {
      try { l(event, data); } catch {}
    }
  }
  log(line) {
    this.emit('log', line);
  }
  progress(step, total, title) {
    this.step = step; this.title = title || '';
    this.emit('progress', { step, total, title: this.title });
  }
  state(status, extra = {}) {
    if (status !== undefined) this.status = status;
    this.emit('state', { status: this.status, error: this.error, result: this.result, ...extra });
  }
  throwCancel() {
    const e = new Error('CANCELLED');
    e.cancelled = true;
    throw e;
  }
}

const job = new Job();
module.exports.job = job;

// ---------------- تصدير جداول من قاعدة إلى ملف ----------------
async function dumpTables(conn, cfg, db, tables, outPath, label) {
  const lines = [];
  lines.push('-- gamadev Cloture - MySQL dump');
  lines.push('-- Database: ' + db + '   Tables: ' + tables.join(', '));
  lines.push('-- ' + new Date().toISOString());
  lines.push('');
  lines.push('SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;');
  lines.push('/*!40101 SET NAMES utf8 */;');

  const summary = [];
  for (const t of tables) {
    job.checkCancel();
    let createSql = null;
    try {
      const [rows] = await conn.query('SHOW CREATE TABLE `' + db + '`.`' + t + '`');
      if (rows.length) createSql = rows[0]['Create Table'];
    } catch (e) { /* الجدول غير موجود */ }
    if (!createSql) {
      job.log('     تحذير: الجدول ' + t + ' غير موجود في ' + db + ' - تم تخطيه');
      continue;
    }
    lines.push('');
    lines.push('-- Table structure for table `' + t + '`');
    lines.push('');
    lines.push('DROP TABLE IF EXISTS `' + t + '`;');
    lines.push(createSql + ';');
    lines.push('');
    lines.push('-- Dumping data for table `' + t + '`');
    lines.push('');
    lines.push('LOCK TABLES `' + t + '` WRITE;');
    lines.push('/*!40000 ALTER TABLE `' + t + '` DISABLE KEYS */;');

    const batch = 200;
    let offset = 0, total = 0;
    for (;;) {
      job.checkCancel();
      const [rs] = await conn.query('SELECT * FROM `' + db + '`.`' + t + '` LIMIT ' + batch + ' OFFSET ' + offset);
      if (!rs.length) break;
      const vals = rs.map(row => '(' + Object.values(row).map(sqlVal).join(',') + ')');
      lines.push('INSERT INTO `' + t + '` VALUES ' + vals.join(',') + ';');
      total += rs.length;
      offset += rs.length;
      if (rs.length < batch) break;
    }
    lines.push('/*!40000 ALTER TABLE `' + t + '` ENABLE KEYS */;');
    lines.push('UNLOCK TABLES;');
    job.log('     الجدول ' + t + ' : ' + total + ' صف');
    summary.push([t, total]);
  }
  lines.push('');
  lines.push('SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;');
  fs.writeFileSync(outPath, lines.join('\n'), 'utf8');
  return summary;
}

// ---------------- استيراد ملف SQL ----------------
async function importFile(conn, cfg, filePath, label, emitStmts) {
  const text = fs.readFileSync(filePath, 'utf8');
  const stmts = S.splitSqlStatements(text)
    .map(s => S.stripTrailingDelim(s))
    .filter(s => s.trim() !== '' && !S.isCommentOnly(s));

  const t0 = Date.now();
  let ok = 0, skipped = 0;
  for (let i = 0; i < stmts.length; i++) {
    job.checkCancel();
    const raw = stmts[i];
    const clean = S.stripNormalComments(raw).trim().replace(/;+$/, '');
    if (clean === '' || S.isCommentOnly(clean)) { skipped++; continue; }
    try {
      await conn.query(clean);
      ok++;
    } catch (e) {
      // أوامر routines/views: إن فشل التنفيذ في محرك حقيقي قديم نتابع
      if (/PROCEDURE|FUNCTION|TRIGGER|VIEW/i.test(clean) && /create/i.test(clean)) {
        job.log('     تحذير: تعذر إنشاء روتين/عرض: ' + e.message.slice(0, 100));
        skipped++;
        continue;
      }
      const err = new Error('خطأ في استيراد ' + label + ' (الأمر رقم ' + (i + 1) + '): ' + e.message);
      err.sql = clean.slice(0, 300);
      throw err;
    }
    if ((i + 1) % 50 === 0) {
      job.log('     ... ' + (i + 1) + ' من ' + stmts.length + ' أوامر');
    }
  }
  const secs = ((Date.now() - t0) / 1000).toFixed(1);
  job.log('     اكتمل الاستيراد: ' + ok + ' أمرًا ناجحًا، ' + skipped + ' متخطى (' + secs + ' ثانية)');
  return ok;
}

// ---------------- تشغيل الإقفال ----------------
async function runCloture(cfg, opts) {
  if (job.running) throw new Error('there is already a running job');
  const { srcDb, dstDb, allowDelete, dryRun } = opts;
  job.running = true;
  job.cancel = false;
  job.error = null;
  job.result = null;
  job.logPath = null;

  try {
    // ----- التحقق من المدخلات -----
    if (!/^[A-Za-z0-9_]+$/.test(srcDb)) throw new Error('اسم قاعدة المصدر غير صحيح (حروف لاتينية وأرقام و _ فقط).');
    if (!/^[A-Za-z0-9_]+$/.test(dstDb)) throw new Error('اسم قاعدة الوجهة غير صحيح (حروف لاتينية وأرقام و _ فقط).');
    if (srcDb === dstDb) throw new Error('اسما القاعدتين متطابقان. صحّح أحدهما.');
    if (!fs.existsSync(cfg.workDir)) fs.mkdirSync(cfg.workDir, { recursive: true });
    if (!fs.existsSync(cfg.schemaFile)) throw new Error('ملف البنية غير موجود: ' + cfg.schemaFile);
    if (!fs.existsSync(cfg.primaryFile)) throw new Error('ملف البيانات الأولية غير موجود: ' + cfg.primaryFile);

    const stamp = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 14);
    const dumpFile = path.join(cfg.workDir, 'DBCloture_' + dstDb + '_' + stamp + '.sql');
    const logFile = path.join(cfg.workDir, 'cloture_' + dstDb + '_' + stamp + '.log');
    const backupFile = path.join(cfg.workDir, 'backup_' + dstDb + '_' + stamp + '.sql');
    job.logPath = logFile;
    fs.writeFileSync(logFile, '', 'utf8');

    const emitLog = job.log.bind(job);
    const log2 = (line) => {
      emitLog(line);
      try { fs.appendFileSync(logFile, line + '\n', 'utf8'); } catch {}
    };

    log2('===== برنامج الإقفال السنوي - gamadev =====');
    log2('التاريخ: ' + new Date().toLocaleString('en-GB'));
    log2('الخادم: ' + cfg.host + ':' + cfg.port + '   المستخدم: ' + cfg.user);
    log2('المصدر: ' + srcDb + '   ->   الوجهة: ' + dstDb);
    log2('ملف السجل: ' + logFile);

    // ----- الاتصال -----
    log2('');
    log2('الاتصال بالخادم...');
    let conn;
    try {
      conn = await mysql.createConnection({
        host: cfg.host,
        port: parseInt(cfg.port, 10) || 3306,
        user: cfg.user,
        password: cfg.password || '',
        connectTimeout: 8000,
        multipleStatements: false,
      });
    } catch (e) {
      throw new Error('تعذر الاتصال بالخادم: ' + e.message);
    }
    const [vrows] = await conn.query('SELECT VERSION() AS v');
    log2('تم الاتصال. إصدار الخادم: ' + vrows[0].v);

    // ----- فحص القواعد -----
    const [dbs] = await conn.query('SHOW DATABASES');
    const dbList = dbs.map(r => Object.values(r)[0]);
    if (!dbList.includes(srcDb)) {
      await conn.end();
      throw new Error('قاعدة المصدر "' + srcDb + '" غير موجودة على الخادم. القواعد الموجودة: ' + dbList.join(', '));
    }
    const dstExists = dbList.includes(dstDb);
    log2('قواعد موجودة: ' + dbList.join(', '));
    log2(dstExists ? 'قاعدة الوجهة موجودة مسبقًا.' : 'قاعدة الوجهة غير موجودة (سبشأنها جديد).');

    // أسماء الخطوات الثمانية
    const stepTitles = [
      'تصدير بيانات الجداول السبعة من القاعدة المصدر',
      'حذف قاعدة الوجهة إن كانت موجودة',
      'إنشاء قاعدة الوجهة',
      'استيراد بنية القاعدة (Schema)',
      'استيراد البيانات الأولية (PrimaryData)',
      'استيراد بيانات المصدر إلى قاعدة الوجهة',
      'ترحيل أرصدة الزبائن والموردين إلى الأرصدة الافتتاحية',
      'إعادة تفعيل قيود المفاتيح الأجنبية',
    ];

    // ----- معاينة بدون تنفيذ -----
    if (dryRun) {
      log2('');
      log2('===== معاينة الأوامر (لم يُنفَّذ أي شيء) =====');
      log2('[' + 1 + '/' + TOTAL_STEPS + '] mysqldump-equivalent: ' + srcDb + ' (' + TABLES.join(' ') + ') -> ' + dumpFile);
      if (dstExists) log2('     + نسخة احتياطية كاملة من ' + dstDb + ' -> ' + backupFile);
      log2('[' + 2 + '/' + TOTAL_STEPS + '] DROP DATABASE IF EXISTS ' + dstDb + ';');
      log2('[' + 3 + '/' + TOTAL_STEPS + '] CREATE DATABASE ' + dstDb + ' CHARACTER SET utf8;');
      log2('[' + 4 + '/' + TOTAL_STEPS + '] استيراد ' + cfg.schemaFile + '  (أمرًا: ' +
        S.splitSqlStatements(fs.readFileSync(cfg.schemaFile, 'utf8')).length + ')');
      log2('[' + 5 + '/' + TOTAL_STEPS + '] استيراد ' + cfg.primaryFile);
      log2('[' + 6 + '/' + TOTAL_STEPS + '] استيراد ' + dumpFile);
      log2('[' + 7 + '/' + TOTAL_STEPS + '] UPDATE personnez SET CreditInitial = Solde, DetteInitial = Soldefx;');
      log2('[' + 8 + '/' + TOTAL_STEPS + '] SET GLOBAL FOREIGN_KEY_CHECKS=1;');
      await conn.end();
      job.result = { dryRun: true, dumpFile, logFile };
      job.state('معاينة فقط — لم يُنفَّذ شيء.', { result: job.result });
      return;
    }

    // ----- حماية الوجهة -----
    if (dstExists && !allowDelete) {
      await conn.end();
      const e = new Error('قاعدة الوجهة "' + dstDb + '" موجودة مسبقًا ولم تُفعّل خانة "اسمح بالحذف". لم يُنفَّذ أي أمر.');
      throw e;
    }

    // ----- نسخة احتياطية إن لزم -----
    if (dstExists) {
      job.progress(0, TOTAL_STEPS, 'نسخة احتياطية من قاعدة الوجهة');
      log2('');
      log2('>> قاعدة الوجهة موجودة: تُؤخذ نسخة احتياطية كاملة إلى:');
      log2('   ' + backupFile);
      const [ts] = await conn.query('SHOW TABLES FROM `' + dstDb + '`');
      const tableNames = ts.map(r => Object.values(r)[0]);
      try {
        await dumpTables(conn, cfg, dstDb, tableNames, backupFile, 'نسخة احتياطية');
        log2('>> اكتملت النسخة الاحتياطية.');
      } catch (e) {
        if (e.cancelled) throw e;
        await conn.end();
        throw new Error('فشلت النسخة الاحتياطية — لن تُحذف قاعدة الوجهة: ' + e.message);
      }
    }

    const tAll = Date.now();

    // [1] تصدير الجداول السبعة
    job.progress(1, TOTAL_STEPS, stepTitles[0]);
    log2('');
    log2('[' + 1 + '/' + TOTAL_STEPS + '] ' + stepTitles[0]);
    const t1 = Date.now();
    await dumpTables(conn, cfg, srcDb, TABLES, dumpFile, 'التصدير');
    log2('     ملف التصدير: ' + dumpFile + '  (' + ((Date.now() - t1) / 1000).toFixed(1) + ' ثانية)');

    // [2] حذف الوجهة
    job.progress(2, TOTAL_STEPS, stepTitles[1]);
    log2('');
    log2('[' + 2 + '/' + TOTAL_STEPS + '] DROP DATABASE IF EXISTS ' + dstDb + ';');
    const t2 = Date.now();
    await conn.query('DROP DATABASE IF EXISTS `' + dstDb + '`');
    log2('     تم (' + ((Date.now() - t2) / 1000).toFixed(1) + ' ثانية)');

    // [3] إنشاء الوجهة
    job.progress(3, TOTAL_STEPS, stepTitles[2]);
    log2('[' + 3 + '/' + TOTAL_STEPS + '] CREATE DATABASE ' + dstDb + ' CHARACTER SET utf8;');
    const t3 = Date.now();
    await conn.query('CREATE DATABASE `' + dstDb + '` CHARACTER SET utf8');
    log2('     تم (' + ((Date.now() - t3) / 1000).toFixed(1) + ' ثانية)');

    // سياق العمل على القاعدة الجديدة
    await conn.query('USE `' + dstDb + '`');

    // [4] استيراد البنية
    job.progress(4, TOTAL_STEPS, stepTitles[3]);
    log2('[' + 4 + '/' + TOTAL_STEPS + '] استيراد بنية القاعدة من:');
    log2('     ' + cfg.schemaFile);
    const t4 = Date.now();
    await importFile(conn, cfg, cfg.schemaFile, 'ملف البنية');
    log2('     (' + ((Date.now() - t4) / 1000).toFixed(1) + ' ثانية)');

    // [5] استيراد البيانات الأولية
    job.progress(5, TOTAL_STEPS, stepTitles[4]);
    log2('[' + 5 + '/' + TOTAL_STEPS + '] استيراد البيانات الأولية من:');
    log2('     ' + cfg.primaryFile);
    const t5 = Date.now();
    await importFile(conn, cfg, cfg.primaryFile, 'ملف البيانات الأولية');
    log2('     (' + ((Date.now() - t5) / 1000).toFixed(1) + ' ثانية)');

    // [6] استيراد بيانات المصدر
    job.progress(6, TOTAL_STEPS, stepTitles[5]);
    log2('[' + 6 + '/' + TOTAL_STEPS + '] استيراد بيانات المصدر من:');
    log2('     ' + dumpFile);
    const t6 = Date.now();
    await importFile(conn, cfg, dumpFile, 'ملف بيانات المصدر');
    log2('     (' + ((Date.now() - t6) / 1000).toFixed(1) + ' ثانية)');

    // [7] ترحيل الأرصدة
    job.progress(7, TOTAL_STEPS, stepTitles[6]);
    log2('[' + 7 + '/' + TOTAL_STEPS + '] UPDATE personnez SET CreditInitial = Solde, DetteInitial = Soldefx;');
    const t7 = Date.now();
    const [ures] = await conn.query('UPDATE personnez SET CreditInitial = Solde, DetteInitial = Soldefx');
    log2('     تم ترحيل ' + (ures.affectedRows || 0) + ' صفًا من الأشخاص (' + ((Date.now() - t7) / 1000).toFixed(1) + ' ثانية)');

    // [8] إعادة تفعيل القيود (غير حاسمة)
    job.progress(8, TOTAL_STEPS, stepTitles[7]);
    log2('[' + 8 + '/' + TOTAL_STEPS + '] SET GLOBAL FOREIGN_KEY_CHECKS=1;');
    try {
      await conn.query('SET GLOBAL FOREIGN_KEY_CHECKS=1');
      log2('     تم');
    } catch (e) {
      log2('     تحذير: ' + e.message.slice(0, 120) + ' (غير حاسم — المخطط لا يحتوي مفاتيح أجنبية)');
    }

    // ----- الخلاصة -----
    log2('');
    log2('===== إحصاء القاعدة الجديدة ' + dstDb + ' =====');
    const summary = {};
    for (const t of TABLES) {
      try {
        const [r] = await conn.query('SELECT COUNT(*) AS c FROM `' + dstDb + '`.`' + t + '`');
        summary[t] = r[0].c;
        log2('     ' + t.padEnd(14) + ': ' + r[0].c + ' صف');
      } catch (e) {
        summary[t] = null;
        log2('     ' + t.padEnd(14) + ': (غير موجود)');
      }
    }
    await conn.end();

    const secs = ((Date.now() - tAll) / 1000).toFixed(1);
    log2('');
    log2('===== اكتمل الإقفال بنجاح (' + secs + ' ثانية) =====');
    log2('ملف بيانات المصدر: ' + dumpFile);
    if (dstExists) log2('النسخة الاحتياطية: ' + backupFile);
    log2('ملف السجل: ' + logFile);
    log2('');
    log2('تنبيه: العملية تنقل المنتجات والأشخاص والمستخدمين وبيانات الشركة فقط.');
    log2('      لا تُرحَّل كميات المخزون ولا أرصدة الصندوق والبنك ولا الجداول المرجعية.');

    job.result = { dryRun: false, summary, dumpFile, backupFile: dstExists ? backupFile : null, logFile, seconds: parseFloat(secs) };
    job.state('اكتمل الإقفال بنجاح.', { result: job.result });
  } catch (e) {
    if (e.cancelled) {
      job.state('أُلغي التنفيذ.', { error: null, result: null });
    } else {
      job.error = e.message;
      job.state('فشل — راجع السجل.', { error: e.message });
      if (job.logPath) { try { fs.appendFileSync(job.logPath, '\n>> خطأ: ' + e.message + '\n', 'utf8'); } catch {} }
    }
  } finally {
    job.running = false;
    job.emit('finished', {});
  }
}

// دالة إلغاء
job.checkCancel = function () {
  if (this.cancel) { this.throwCancel(); }
};

module.exports = { runCloture, job, TABLES, TOTAL_STEPS };
