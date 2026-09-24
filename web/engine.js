'use strict';
// =====================================================================
//  engine.js - محرك القواعد التجريبي (SQLite خلف بروتوكول MySQL)
//
//  كل "قاعدة MySQL" = ملف SQLite + سجل للأوامر الأصلية (DDL)
//  يدعم الأوامر التي يستعملها البرنامج فعلياً:
//   CREATE/DROP DATABASE, USE, SHOW DATABASES/TABLES/CREATE TABLE,
//   CREATE TABLE, DROP TABLE, INSERT/REPLACE, UPDATE, DELETE, SELECT,
//   SET ..., BEGIN/COMMIT/ROLLBACK, TRUNCATE, LOCK/UNLOCK,
//   CREATE VIEW/FUNCTION/PROCEDURE/TRIGGER (تُسجَّل وتُتخطى)
// =====================================================================
const fs = require('fs');
const path = require('path');
const Database = require('better-sqlite3');
const S = require('./sql-file');

const DATA_DIR = path.join(__dirname, 'demo-server', 'data');
const SERVER_VERSION = '10.6.19-gamadev-demo';
fs.mkdirSync(DATA_DIR, { recursive: true });

const REGISTRY = path.join(DATA_DIR, 'databases.json');

function loadRegistry() {
  try { return JSON.parse(fs.readFileSync(REGISTRY, 'utf8')); }
  catch { return {}; }
}
function saveRegistry(reg) {
  fs.writeFileSync(REGISTRY, JSON.stringify(reg, null, 2));
}

class Engine {
  constructor() {
    this.reg = loadRegistry();
    this.conns = new Map(); // name -> sqlite db (cached)
    this.memDb = null;      // للاستعلامات التي لا تحتاج قاعدة (SELECT 1, VERSION()...)
  }

  mem() {
    if (!this.memDb) { this.memDb = new Database(':memory:'); this.registerFunctions(this.memDb, null); }
    return this.memDb;
  }

  // تسجيل دوال MySQL الشائعة داخل SQLite
  registerFunctions(db, conn) {
    const userFn = () => ((conn && conn.user) || 'root') + '@localhost';
    const dbFn = () => (conn && conn.db) || null;
    try {
      db.function('VERSION', () => SERVER_VERSION);
      db.function('CURRENT_USER', userFn);
      db.function('USER', userFn);
      db.function('SESSION_USER', userFn);
      db.function('SYSTEM_USER', userFn);
      db.function('DATABASE', dbFn);
      db.function('SCHEMA', dbFn);
      db.function('CONNECTION_ID', () => 1);
      db.function('LAST_INSERT_ID', () => 0);
      db.function('FOUND_ROWS', () => 0);
      db.function('RAND', () => Math.random());
      db.function('YEAR', (d) => (d == null ? null : String(d).slice(0, 4)));
      db.function('MONTH', (d) => (d == null ? null : String(d).slice(5, 7)));
      db.function('DAY', (d) => (d == null ? null : String(d).slice(8, 10)));
      db.function('DAYOFMONTH', (d) => (d == null ? null : String(d).slice(8, 10)));
      db.function('HOUR', (d) => (d == null ? null : String(d).slice(11, 13)));
      db.function('MINUTE', (d) => (d == null ? null : String(d).slice(14, 16)));
      db.function('SUBSTRING_INDEX', (s, delim, cnt) => {
        if (s == null || delim == null || cnt == null) return null;
        s = String(s); delim = String(delim);
        if (delim === '') return '';
        const parts = s.split(delim);
        const n = parseInt(cnt, 10);
        if (n > 0) return parts.slice(0, n).join(delim);
        if (n < 0) return parts.slice(n).join(delim);
        return '';
      });
    } catch { /* مسجلة مسبقًا */ }
  }

  dbFile(name) {
    return path.join(DATA_DIR, name + '.sqlite');
  }

  openDb(name) {
    if (this.conns.has(name)) return this.conns.get(name);
    const f = this.dbFile(name);
    const db = new Database(f, { timeout: 8000 });
    db.pragma('journal_mode = WAL');
    db.pragma('foreign_keys = OFF');
    this.registerFunctions(db, null);
    // جدول ميتا: يحتفظ بالـ DDL الأصلي لكل جدول/عرض/دالة
    db.exec('CREATE TABLE IF NOT EXISTS __mysql_meta (kind TEXT, name TEXT, ddl TEXT, PRIMARY KEY(kind, name))');
    this.conns.set(name, db);
    return db;
  }

  closeAll() {
    for (const [k, db] of this.conns) { try { db.close(); } catch {} }
    this.conns.clear();
  }

  listDatabases() {
    return Object.keys(this.reg).sort();
  }

  // إنشاء قاعدة: يعيد "ok" أو يرمي خطأ MySQL
  createDatabase(name, ifNotExists) {
    if (!/^[A-Za-z0-9_]+$/.test(name)) throw mysqlErr(1064, "You have an error in your SQL syntax");
    if (this.reg[name]) {
      if (ifNotExists) return { ok: true, exists: true };
      throw mysqlErr(1007, `Can't create database '${name}'; database exists`);
    }
    this.reg[name] = { created: new Date().toISOString() };
    saveRegistry(this.reg);
    const db = this.openDb(name);
    db.exec('CREATE TABLE IF NOT EXISTS __mysql_meta (kind TEXT, name TEXT, ddl TEXT, PRIMARY KEY(kind, name))');
    return { ok: true, exists: false };
  }

  dropDatabase(name, ifExists) {
    if (!this.reg[name]) {
      if (ifExists) return { ok: true, existed: false };
      throw mysqlErr(1008, `Can't drop database '${name}'; database doesn't exist`);
    }
    delete this.reg[name];
    saveRegistry(this.reg);
    const c = this.conns.get(name);
    if (c) { try { c.close(); } catch {} this.conns.delete(name); }
    for (const ext of ['', '-wal', '-shm']) {
      try { fs.unlinkSync(this.dbFile(name) + ext); } catch {}
    }
    return { ok: true, existed: true };
  }

  // ------------------------------------------------------------------
  //  تنفيذ أمر واحد: يعيد
  //   { type:'ok', affected, insertId }
  //   { type:'rows', columns:[{name}], rows:[[...]] }
  //   { type:'text', text }
  // ------------------------------------------------------------------
  execute(conn, sqlRaw) {
    const sql = S.stripTrailingDelim(sqlRaw).trim();
    if (sql === '') return { type: 'ok', affected: 0, insertId: 0 };
    if (S.isCommentOnly(sql)) return { type: 'ok', affected: 0, insertId: 0 };
    let s = S.stripNormalComments(sql).trim().replace(/;\s*$/, '');
    const up = s.toUpperCase();

    // ---------------- USE ----------------
    let m = s.match(/^USE\s+(`[^`]+`|[\w.]+)$/i);
    if (m) {
      const dbn = m[1].replace(/`/g, '');
      if (!this.reg[dbn]) throw mysqlErr(1049, `Unknown database '${dbn}'`);
      conn.db = dbn;
      return { type: 'ok', affected: 0, insertId: 0 };
    }

    // ---------------- SHOW ----------------
    if (/^SHOW\s+DATABASES$/i.test(s)) {
      const rows = this.listDatabases().map(d => [d]);
      return { type: 'rows', columns: [{ name: 'Database' }], rows };
    }
    m = s.match(/^SHOW\s+(?:FULL\s+)?TABLES(?:\s+FROM\s+(`[^`]+`|\w+))?\s*(?:LIKE\s+'((?:[^'\\]|\\.)*)')?$/i);
    if (m) {
      const dbn = m[1] ? m[1].replace(/`/g, '') : conn.db;
      if (!this.reg[dbn]) throw mysqlErr(1049, `Unknown database '${dbn}'`);
      const db = this.openDb(dbn);
      const like = m[2];
      const rows = db.prepare(`SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' AND name != '__mysql_meta' ORDER BY name`).all()
        .map(r => [r.name])
        .filter(r => !like || new RegExp('^' + like.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').replace(/%/g, '.*').replace(/_/g, '.') + '$', 'i').test(r[0]));
      return { type: 'rows', columns: [{ name: 'Tables_in_' + dbn }], rows };
    }
    m = s.match(/^SHOW\s+CREATE\s+TABLE\s+(`[^`]+`|\w+)(?:\s*\.\s*(`[^`]+`|\w+))?$/i);
    if (m) {
      let t = m[1].replace(/`/g, '');
      if (m[2]) { conn.db = t; t = m[2].replace(/`/g, ''); }
      const db = this.requireDb(conn);
      const meta = db.prepare('SELECT ddl FROM __mysql_meta WHERE kind IN (\'table\',\'view\') AND name = ?').get(t);
      if (!meta) throw mysqlErr(1146, `Table '${conn.db}.${t}' doesn't exist`);
      return { type: 'rows', columns: [{ name: 'Table' }, { name: 'Create Table' }], rows: [[t, meta.ddl]] };
    }
    if (/^SHOW\s+(VARIABLES|STATUS|WARNINGS|PROCESSLIST|GRANTS|MASTER\s+STATUS|SLAVE\s+STATUS|ENGINE|ENGINES|INDEX|COLUMNS|FIELDS|CREATE\s+DATABASE|BINARY|PLUGINS|TRIGGERS|ROUTINES|CHARSET|CHARACTER\s+SET)/i.test(s)) {
      if (/^SHOW\s+VARIABLES/i.test(s)) {
        const rows = [
          ['version', '10.6.19-gamadev-demo'],
          ['version_comment', 'gamadev demo engine (SQLite-backed MySQL protocol server)'],
          ['character_set_server', 'utf8'],
          ['collation_server', 'utf8_general_ci'],
          ['max_allowed_packet', '16777216'],
          ['autocommit', '1'],
          ['foreign_key_checks', conn.fkChecks ? '1' : '0'],
        ];
        const lm = s.match(/LIKE\s+'((?:[^'\\]|\\.)*)'$/i);
        const filtered = lm ? rows.filter(r => new RegExp('^' + lm[1].replace(/%/g, '.*').replace(/_/g, '.') + '$', 'i').test(r[0])) : rows;
        return { type: 'rows', columns: [{ name: 'Variable_name' }, { name: 'Value' }], rows: filtered };
      }
      return { type: 'ok', affected: 0, insertId: 0 };
    }

    // ---------------- SELECT خاص ----------------
    if (/^SELECT\s+VERSION\s*\(\s*\)$/i.test(s)) return oneRow('VERSION()', [['10.6.19-gamadev-demo']]);
    if (/^SELECT\s+CURRENT_USER\s*\(\s*\)$/i.test(s)) return oneRow('CURRENT_USER()', [[(conn.user || 'root') + '@localhost']]);
    if (/^SELECT\s+USER\s*\(\s*\)$/i.test(s)) return oneRow('USER()', [[(conn.user || 'root') + '@localhost']]);
    if (/^SELECT\s+DATABASE\s*\(\s*\)$/i.test(s)) return oneRow('DATABASE()', [[conn.db || null]]);
    if (/^SELECT\s+@@(hostname|port|version|version_comment|datadir|basedir|server_id|socket|init_connect|sql_mode|character_set_server|collation_server|max_allowed_packet|autocommit|foreign_key_checks|tx_isolation|time_zone|lower_case_table_names|interactive_timeout|wait_timeout|net_read_timeout)/i.test(s)) {
      const varName = s.match(/^SELECT\s+@@([\w]+)/i)[1].toLowerCase();
      const vals = {
        hostname: 'localhost', port: 3306, version: '10.6.19-gamadev-demo',
        version_comment: 'gamadev demo', datadir: DATA_DIR + '/', basedir: '/',
        server_id: 1, socket: '', init_connect: '', sql_mode: 'STRICT_TRANS_TABLES',
        character_set_server: 'utf8', collation_server: 'utf8_general_ci',
        max_allowed_packet: 16777216, autocommit: 1, foreign_key_checks: conn.fkChecks ? 1 : 0,
        tx_isolation: 'REPEATABLE-READ', time_zone: 'SYSTEM', lower_case_table_names: 0,
        interactive_timeout: 28800, wait_timeout: 28800, net_read_timeout: 30,
      };
      const col = s.replace(/^SELECT\s+@@/i, '').replace(/\s*\)/, '').replace(/\)/, '').trim() || varName;
      return oneRow(col, [[vals[varName] !== undefined ? vals[varName] : null]]);
    }
    if (/^SELECT\s+\d+\s*(#.*)?$/i.test(s)) return oneRow('', [[parseInt(s.match(/\d+/)[0], 10)]]);

    // ---------------- SET ----------------
    if (/^SET\s/i.test(s)) {
      const fk = s.match(/FOREIGN_KEY_CHECKS\s*=\s*(['"]?)(\w+)\1/i);
      if (fk) conn.fkChecks = !/^(0|off|false)$/i.test(fk[2]);
      const names = s.match(/SET\s+((?:NAMES|CHARACTER\s+SET)\s+\w+(?:\s*COLLATE\s+\w+)?)/i);
      if (names) conn.charset = names[1].trim();
      return { type: 'ok', affected: 0, insertId: 0 };
    }

    // ---------------- معاملات ----------------
    if (/^(BEGIN|START\s+TRANSACTION)$/i.test(s)) { this.requireDb(conn).exec('BEGIN'); return { type: 'ok', affected: 0, insertId: 0 }; }
    if (/^(COMMIT|END)$/i.test(s)) { try { this.requireDb(conn).exec('COMMIT'); } catch {} return { type: 'ok', affected: 0, insertId: 0 }; }
    if (/^ROLLBACK$/i.test(s)) { try { this.requireDb(conn).exec('ROLLBACK'); } catch {} return { type: 'ok', affected: 0, insertId: 0 }; }

    // ---------------- LOCK/UNLOCK ----------------
    if (/^(LOCK\s+TABLES|UNLOCK\s+TABLES)/i.test(s)) return { type: 'ok', affected: 0, insertId: 0 };

    // ---------------- مؤهّل قاعدة.جدول ----------------
    // SQLite لا يفهم db.table: نحوّله إلى USE ضمني + اسم الجدول فقط
    if (/\./.test(s)) {
      s = s.replace(/`([A-Za-z0-9_]+)`\s*\.\s*`([A-Za-z0-9_]+)`/g, (m, d, t) => {
        if (this.reg[d]) { conn.db = d; return '`' + t + '`'; }
        return m;
      });
      s = s.replace(/\b([A-Za-z0-9_]+)\s*\.\s*(?=[A-Za-z0-9_`])/g, (m, d) => {
        if (this.reg[d]) { conn.db = d; return ''; }
        return m;
      });
    }

    // ---------------- CREATE/DROP DATABASE ----------------
    m = s.match(/^CREATE\s+(DATABASE|SCHEMA)\s+(IF\s+NOT\s+EXISTS\s+)?(`[^`]+`|\w+)/i);
    if (m) {
      const r = this.createDatabase(m[3].replace(/`/g, ''), !!m[2]);
      return { type: 'ok', affected: 0, insertId: 0 };
    }
    m = s.match(/^DROP\s+(DATABASE|SCHEMA)\s+(IF\s+EXISTS\s+)?(`[^`]+`|\w+)/i);
    if (m) { this.dropDatabase(m[3].replace(/`/g, ''), !!m[2]); return { type: 'ok', affected: 0, insertId: 0 }; }
    if (/^ALTER\s+(DATABASE|SCHEMA)/i.test(s)) return { type: 'ok', affected: 0, insertId: 0 };

    // ---------------- أوامر لا تنفذ في المحرك التجريبي (تُسجَّل فقط) ----------------
    if (/^CREATE\s+(OR\s+REPLACE\s+)?(?:DEFINER\s*=\s*\S+\s+)?(VIEW|FUNCTION|PROCEDURE|TRIGGER|EVENT|INDEX)/i.test(s)) {
      const kind = s.match(/^CREATE\s+(?:OR\s+REPLACE\s+)?(?:DEFINER\s*=\s*\S+\s+)?(VIEW|FUNCTION|PROCEDURE|TRIGGER|EVENT|INDEX)/i)[1].toLowerCase();
      this.storeMeta(conn, kind, s);
      return { type: 'ok', affected: 0, insertId: 0 };
    }
    if (/^DROP\s+(VIEW|FUNCTION|PROCEDURE|TRIGGER|EVENT|INDEX)\s+(IF\s+EXISTS\s+)?/i.test(s)) return { type: 'ok', affected: 0, insertId: 0 };
    if (/^(ANALYZE|OPTIMIZE|REPAIR|FLUSH|PURGE|RESET|GRANT|REVOKE|KILL)\b/i.test(s)) return { type: 'ok', affected: 0, insertId: 0 };
    if (/^CHECK\s+TABLE/i.test(s)) {
      const db = this.requireDb(conn);
      const t = s.match(/CHECK\s+TABLE\s+(`[^`]+`|\w+)/i);
      const rows = t ? [[t[1].replace(/`/g, ''), 'status', 'OK']] : [];
      return { type: 'rows', columns: [{ name: 'Table' }, { name: 'Op' }, { name: 'Msg_type' }, { name: 'Msg_text' }], rows };
    }

    // ---------------- CREATE TABLE ----------------
    if (/^CREATE\s+TABLE\b/i.test(s)) {
      const db = this.requireDb(conn);
      const tr = S.translateCreateTable(s);
      if (!tr) throw mysqlErr(1064, "You have an error in your SQL syntax (unsupported CREATE TABLE)");
      const existing = db.prepare("SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name = ?").get(tr.name);
      if (existing) {
        if (/IF\s+NOT\s+EXISTS/i.test(s)) return { type: 'ok', affected: 0, insertId: 0 };
        db.prepare(`DROP TABLE IF EXISTS "${tr.name}"`).run();
      }
      try {
        db.exec(tr.ddl);
      } catch (e) {
        throw mysqlErr(1064, `SQLite error creating table ${tr.name}: ${e.message}`);
      }
      this.storeMetaRaw(conn, 'table', tr.name, s);
      if (tr.skipped.length) {
        db.prepare('INSERT OR IGNORE INTO __mysql_meta (kind, name, ddl) VALUES (?,?,?)')
          .run('skipped', tr.name, tr.skipped.join('\n'));
      }
      return { type: 'ok', affected: 0, insertId: 0 };
    }

    // ---------------- DROP TABLE ----------------
    if (/^DROP\s+TABLE\b/i.test(s)) {
      const db = this.requireDb(conn);
      const ifExists = /IF\s+EXISTS/i.test(s);
      const rest = s.replace(/^DROP\s+TABLE\s+(IF\s+EXISTS\s+)?/i, '');
      const names = rest.split(',').map(x => x.trim().replace(/`/g, '')).filter(Boolean);
      for (const t of names) {
        const ex = db.prepare("SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name = ?").get(t);
        if (!ex && !ifExists) throw mysqlErr(1051, `Can't drop table '${t}'; table doesn't exist`);
        db.prepare(`DROP TABLE IF EXISTS "${t}"`).run();
        db.prepare("DELETE FROM __mysql_meta WHERE name = ?").run(t);
      }
      return { type: 'ok', affected: 0, insertId: 0 };
    }

    // ---------------- ALTER TABLE (محدود) ----------------
    if (/^ALTER\s+TABLE\b/i.test(s)) {
      const db = this.requireDb(conn);
      const t = s.match(/^ALTER\s+TABLE\s+(`[^`]+`|\w+)\s+(.*)$/is);
      if (t) {
        const tbl = t[1].replace(/`/g, '');
        const actions = t[2].split(',').map(x => x.trim());
        for (const a of actions) {
          const am = a.match(/^ADD\s+(?:COLUMN\s+)?(`[^`]+`|\w+)\s+(INT|INTEGER|VARCHAR|TEXT|DECIMAL|DOUBLE|FLOAT|DATE|DATETIME|BLOB|CHAR)(\(\d*(,\d*)?\))?(\s+DEFAULT\s+('[^']*'|\d+|NULL))?(\s+NOT\s+NULL)?(\s+NULL)?/i);
          if (am) {
            const colName = am[1].replace(/`/g, '');
            const map = { INT: 'INTEGER', INTEGER: 'INTEGER', VARCHAR: 'TEXT', TEXT: 'TEXT', DECIMAL: 'NUMERIC', DOUBLE: 'REAL', FLOAT: 'REAL', DATE: 'TEXT', DATETIME: 'TEXT', BLOB: 'BLOB', CHAR: 'TEXT' };
            let def = map[am[2].toUpperCase()];
            if (am[4]) def += am[4].toUpperCase() === 'NOT' ? '' : '';
            if (am[5]) def += ' DEFAULT ' + am[5].slice(8).trim();
            db.exec(`ALTER TABLE "${tbl}" ADD COLUMN "${colName}" ${def}`);
            continue;
          }
          // DISABLE KEYS / ENABLE KEYS / AUTO_INCREMENT=... / ENGINE=...  -> تجاهل
          if (!/^(DISABLE\s+KEYS|ENABLE\s+KEYS|AUTO_INCREMENT\s*=|ENGINE\s*=|ROW_FORMAT\s*=|COMMENT\s*=|DEFAULT\s+CHARSET)/i.test(a)) {
            // تجاهل بقية الأوامر غير المدعومة
          }
        }
      }
      return { type: 'ok', affected: 0, insertId: 0 };
    }

    // ---------------- TRUNCATE ----------------
    if (/^TRUNCATE\s+(TABLE\s+)?(`[^`]+`|\w+)/i.test(s)) {
      const db = this.requireDb(conn);
      const t = s.match(/TRUNCATE\s+(?:TABLE\s+)?(`[^`]+`|\w+)/i)[1].replace(/`/g, '');
      db.exec(`DELETE FROM "${t}"`);
      return { type: 'ok', affected: 0, insertId: 0 };
    }

    // ---------------- INSERT / REPLACE ----------------
    if (/^(INSERT|REPLACE)\s+(INTO|IGNORE\s+INTO)/i.test(s)) {
      const db = this.requireDb(conn);
      let stmt = S.sanitizeSqliteValues(s);
      try {
        const r = db.exec(stmt);
        return { type: 'ok', affected: db.prepare('SELECT changes() c').get().c, insertId: db.prepare('SELECT last_insert_rowid() i').get().i };
      } catch (e) {
        throw mysqlErr(1064, `SQLite error: ${e.message} | SQL: ${stmt.slice(0, 200)}`);
      }
    }

    // ---------------- UPDATE / DELETE ----------------
    if (/^(UPDATE|DELETE)\b/i.test(s)) {
      const db = this.requireDb(conn);
      let stmt = S.sanitizeSqliteValues(S.translateSelect(s));
      try {
        db.exec(stmt);
        return { type: 'ok', affected: db.prepare('SELECT changes() c').get().c, insertId: 0 };
      } catch (e) {
        throw mysqlErr(1064, `SQLite error: ${e.message} | SQL: ${stmt.slice(0, 200)}`);
      }
    }

    // ---------------- SELECT عام ----------------
    if (/^SELECT\b/i.test(s)) {
      // استعلام بلا قاعدة محددة (SELECT VERSION()، SELECT 1...) — يعمل على قاعدة ذاكرة
      const db = (conn.db && this.reg[conn.db]) ? this.openDb(conn.db) : this.mem();
      let stmt = S.translateSelect(s);
      stmt = stmt.replace(/\bSQL_CALC_FOUND_ROWS\b/gi, '');
      stmt = stmt.replace(/\bSTRAIGHT_JOIN\b/gi, 'JOIN');
      try {
        const info = db.prepare(stmt);
        const cols = info.columns().map(c => c.name);
        const rows = info.all().map(r => cols.map(c => (r[c] === undefined ? null : r[c])));
        return { type: 'rows', columns: cols.map(c => ({ name: c })), rows };
      } catch (e) {
        throw mysqlErr(1064, `SQLite error: ${e.message} | SQL: ${stmt.slice(0, 200)}`);
      }
    }

    throw mysqlErr(1064, 'Statement not supported by demo engine: ' + s.slice(0, 120));
  }

  requireDb(conn) {
    if (!conn.db || !this.reg[conn.db]) throw mysqlErr(1046, 'No database selected');
    return this.openDb(conn.db);
  }

  storeMeta(conn, kind, stmt) {
    if (!conn.db) return;
    const db = this.openDb(conn.db);
    const name = stmt.match(/(?:VIEW|FUNCTION|PROCEDURE|TRIGGER|EVENT|INDEX)\s+(?:IF\s+(?:NOT\s+)?EXISTS\s+)?(`[^`]+`|\w+)/i);
    const n = name ? name[1].replace(/`/g, '') : 'unknown';
    db.prepare('INSERT OR REPLACE INTO __mysql_meta (kind, name, ddl) VALUES (?,?,?)').run(kind, n, stmt.slice(0, 4000));
  }

  storeMetaRaw(conn, kind, name, ddl) {
    if (!conn.db) return;
    const db = this.openDb(conn.db);
    db.prepare('INSERT OR REPLACE INTO __mysql_meta (kind, name, ddl) VALUES (?,?,?)').run(kind, name, ddl.slice(0, 20000));
  }

  // جدول الأخطاء: codes شائعة
  errorCount() { return 0; }
}

function mysqlErr(code, msg) {
  const e = new Error(msg);
  e.code = code;
  e.sqlState = { 1049: '42000', 1007: 'HY000', 1008: 'HY000', 1046: '3D000', 1051: '42000', 1146: '42S02', 1064: '42000' }[code] || 'HY000';
  return e;
}
function oneRow(col, rows) {
  return { type: 'rows', columns: [{ name: col }], rows };
}

module.exports = { engine: new Engine(), DATA_DIR };
