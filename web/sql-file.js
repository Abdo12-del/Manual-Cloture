'use strict';
// =====================================================================
//  sql-file.js - أدوات ملفات SQL:
//   - تقسيم ملف SQL إلى أوامر مع احترام DELIMITER والاستروحات والتعليقات
//   - معالجة التعليقات الشرطية /*!12345 ... */ (مخرجات mysqldump)
//   - ترجمة أوامر MySQL إلى صيغة يقبلها SQLite (للخادم التجريبي)
// =====================================================================

// تقسيم نص SQL إلى أوامر (كل أمر نص خام كما هو، مع علامات الفصل)
// يدعم: DELIMITER xx  /  '...'  /  "..."  /  -- ...  /  /* ... */  /  /*!...*/
function splitSqlStatements(sql) {
  const stmts = [];
  let delim = ';';
  let cur = '';
  let inS = false;   // داخل '...'
  let inD = false;   // داخل "..."
  let inLine = false;
  let inBlock = false;
  let inCond = false; // داخل /*!...*/
  const n = sql.length;

  for (let i = 0; i < n; i++) {
    const ch = sql[i];
    const nx = i + 1 < n ? sql[i + 1] : '';

    if (inLine) {
      cur += ch;
      if (ch === '\n') inLine = false;
      continue;
    }
    if (inBlock) {
      cur += ch;
      if (ch === '*' && nx === '/') { cur += '/'; i++; inBlock = false; }
      continue;
    }
    if (inCond) {
      cur += ch;
      if (ch === '*' && nx === '/') { cur += '/'; i++; inCond = false; }
      continue;
    }
    if (inS) {
      cur += ch;
      if (ch === '\\') { if (nx !== '') { cur += nx; i++; } }
      else if (ch === "'") {
        if (nx === "'") { cur += "'"; i++; } // '' هروب
        else inS = false;
      }
      continue;
    }
    if (inD) {
      cur += ch;
      if (ch === '\\') { if (nx !== '') { cur += nx; i++; } }
      else if (ch === '"') inD = false;
      continue;
    }

    // خارج الاستروحات والتعليقات
    if (ch === '-' && nx === '-' && (i + 2 >= n || /\s/.test(sql[i + 2]))) {
      inLine = true; cur += ch; continue;
    }
    if (ch === '#' ) {
      // تعليق سطري في MySQL
      const eol = sql.indexOf('\n', i);
      if (eol === -1) { inLine = true; cur += ch; continue; }
      cur += sql.slice(i, eol + 1); i = eol; continue;
    }
    if (ch === '/' && nx === '*') {
      const m = sql.slice(i).match(/^\/\*!(\d{5})/);
      if (m) { inCond = true; cur += '/*'; i++; continue; }
      inBlock = true; cur += '/*'; i++; continue;
    }
    if (ch === "'") { inS = true; cur += ch; continue; }
    if (ch === '"') { inD = true; cur += ch; continue; }

    // أمر DELIMITER (يبدأ سطرًا، خارج الاستروحات)
    if ((cur === '' || /[\r\n;]$/.test(cur)) && /^DELIMITER\s+/i.test(sql.slice(i, i + 11))) {
      const eol = sql.indexOf('\n', i);
      const seg = sql.slice(i + 9, eol === -1 ? n : eol);
      const d = seg.trim();
      if (d) {
        cur += '\n';
        delim = d;
        i = eol === -1 ? n : eol;
        continue;
      }
    }

    cur += ch;
    if (cur.endsWith(delim)) {
      stmts.push(cur);
      cur = '';
    }
  }
  if (cur.trim() !== '') stmts.push(cur);
  return stmts;
}

// إزالة علامات الفصل المتبقية في نهاية الأمر ( ; أو ;; ...)
function stripTrailingDelim(stmt) {
  return stmt.replace(/[\r\n;\s]+$/, '');
}

// هل الأمر مجرد تعليق (أو تعليق شرطي)؟
function isCommentOnly(stmt) {
  const s = stripTrailingDelim(stmt).replace(/^\s+/, '');
  if (s === '') return true;
  // أزل التعليقات العادية والشرطية كلها
  let out = s;
  // شرطية
  out = out.replace(/\/\*!.*?\*\//gs, '');
  // عادية
  out = out.replace(/\/\*.*?\*\//gs, '');
  // سطرية
  out = out.replace(/--[^\r\n]*/g, '').replace(/#[^\r\n]*/g, '');
  return out.trim() === '';
}

// محتوى الأمر بدون التعليقات العادية (مع إبقاء /*!...*/)
function stripNormalComments(stmt) {
  let out = '';
  let i = 0;
  const n = stmt.length;
  let inS = false, inD = false, inLine = false, inBlock = false, inCond = false;
  for (; i < n; i++) {
    const ch = stmt[i], nx = i + 1 < n ? stmt[i + 1] : '';
    if (inLine) { if (ch === '\n') inLine = false; continue; }
    if (inBlock) { if (ch === '*' && nx === '/') { i++; inBlock = false; } continue; }
    if (inCond) { out += ch; if (ch === '*' && nx === '/') { out += '/'; i++; inCond = false; } continue; }
    if (inS) {
      out += ch;
      if (ch === '\\') { if (nx !== '') { out += nx; i++; } }
      else if (ch === "'") { if (nx === "'") { out += "'"; i++; } else inS = false; }
      continue;
    }
    if (inD) {
      out += ch;
      if (ch === '\\') { if (nx !== '') { out += nx; i++; } }
      else if (ch === '"') inD = false;
      continue;
    }
    if (ch === '-' && nx === '-' && (i + 2 >= n || /\s/.test(stmt[i + 2]))) { inLine = true; continue; }
    if (ch === '#') { const eol = stmt.indexOf('\n', i); i = eol === -1 ? n - 1 : eol; continue; }
    if (ch === '/' && nx === '*') {
      if (stmt.slice(i).match(/^\/\*!/)) { inCond = true; out += '/*'; i++; continue; }
      inBlock = true; i++; continue;
    }
    if (ch === "'") { inS = true; out += ch; continue; }
    if (ch === '"') { inD = true; out += ch; continue; }
    out += ch;
  }
  return out;
}

// ---------------------------------------------------------------------
//  تحويل DDL: CREATE TABLE MySQL  ->  CREATE TABLE SQLite
// ---------------------------------------------------------------------

const TYPE_MAP = [
  [/^(TINYINT|SMALLINT|MEDIUMINT|INT|INTEGER|BIGINT)(\(\d+\))?(\s+UNSIGNED)?(\s+ZEROFILL)?$/i, 'INTEGER'],
  [/^(TINYINT|SMALLINT|MEDIUMINT|INT|INTEGER|BIGINT)(\(\d+\))?(\s+UNSIGNED)?(\s+ZEROFILL)?\s+AUTO_INCREMENT$/i, 'INTEGER'],
  [/^(FLOAT|DOUBLE|REAL)(\s+UNSIGNED)?(\(\d+(,\d+)?\))?$/i, 'REAL'],
  [/^(DECIMAL|NUMERIC|FIXED|DEC)(\(\d+(,\d+)?\))?(\s+UNSIGNED)?$/i, 'NUMERIC'],
  [/^(CHAR|VARCHAR|TINYTEXT|TEXT|MEDIUMTEXT|LONGTEXT|TINYBLOB|JSON|GEOMETRY|POINT|LINESTRING|POLYGON|MULTIPOINT|MULTILINESTRING|MULTIPOLYGON|GEOMETRYCOLLECTION)\(?\d*\)?$/i, 'TEXT'],
  [/^(BIT)(\(\d+\))?$/i, 'INTEGER'],
  [/^(BINARY|VARBINARY|BLOB|MEDIUMBLOB|LONGBLOB|YEAR)\(?\d*\)?$/i, 'BLOB'],
  [/^(DATE|DATETIME|TIME|TIMESTAMP)(\(\d+\))?$/i, 'TEXT'],
  [/^(ENUM|SET)\s*\(.*\)$/is, 'TEXT'],
];

function mapColumnType(rawType) {
  const t = rawType.trim();
  for (const [re, out] of TYPE_MAP) if (re.test(t)) return out;
  return 'TEXT';
}

// تقسيم نص عند فواصل عليا (خارج الأقواس والاستروحات)
function splitTopLevel(text, sep) {
  const parts = [];
  let cur = '', depth = 0, inS = false, inD = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i], nx = i + 1 < text.length ? text[i + 1] : '';
    if (inS) {
      cur += ch;
      if (ch === '\\') { if (nx !== '') { cur += nx; i++; } }
      else if (ch === "'") { if (nx === "'") { cur += "'"; i++; } else inS = false; }
      continue;
    }
    if (inD) {
      cur += ch;
      if (ch === '\\') { if (nx !== '') { cur += nx; i++; } }
      else if (ch === '"') inD = false;
      continue;
    }
    if (ch === "'") { inS = true; cur += ch; continue; }
    if (ch === '"') { inD = true; cur += ch; continue; }
    if (ch === '(') depth++;
    if (ch === ')') depth--;
    if (ch === sep && depth === 0) { parts.push(cur); cur = ''; continue; }
    cur += ch;
  }
  if (cur.trim() !== '') parts.push(cur);
  return parts;
}

// إزالة COMMENT '...' (مع احترام الهروب)
function stripCommentOption(text) {
  let out = '';
  for (let i = 0; i < text.length; i++) {
    const m = /^COMMENT\s+'/i.exec(text.slice(i));
    if (m) {
      i += m[0].length;
      // اقرأ الاستروحة
      while (i < text.length) {
        if (text[i] === '\\' && i + 1 < text.length) { i += 2; continue; }
        if (text[i] === "'") {
          if (i + 1 < text.length && text[i + 1] === "'") { i += 2; continue; }
          i++; break;
        }
        i++;
      }
      continue;
    }
    out += text[i];
  }
  return out;
}

// تحويل تعريف عمود واحد
function translateColumnDef(def, skipped) {
  const d = stripCommentOption(def).trim();
  // الاسم (قد يكون محاطاً بعلامات خلفية)
  const m = d.match(/^(`[^`]+`|\[[^\]]+\]|\w+)\s+([\s\S]+)$/);
  if (!m) return null;
  let name = m[1].replace(/`|\[|\]/g, '');
  const rest = m[2];

  const isAutoInc = /\bAUTO_INCREMENT\b/i.test(rest);
  let r = rest;
  r = r.replace(/\bAUTO_INCREMENT\b/gi, '');
  r = r.replace(/\bUNSIGNED\b/gi, '');
  r = r.replace(/\bZEROFILL\b/gi, '');
  r = r.replace(/\bCHARACTER\s+SET\s+\w+(\s+COLLATE\s+\w+)?/gi, '');
  r = r.replace(/\bCOLLATE\s+\w+(\.\w+)?/gi, '');
  r = r.replace(/\bDEFAULT\s+b'([01]*)'/gi, (mm, bits) => 'DEFAULT ' + (bits ? parseInt(bits, 2) : 0));
  r = r.replace(/\bDEFAULT\s+CURRENT_TIMESTAMP(\(\d+\))?/gi, 'DEFAULT CURRENT_TIMESTAMP');
  // REFERENCES ( ... ) ... ON DELETE/UPDATE ...
  r = r.replace(/\bREFERENCES\b[\s\S]*$/i, '');
  r = r.replace(/\bON\s+DELETE\b[\s\S]*$/i, '');
  r = r.replace(/\bON\s+UPDATE\b[\s\S]*$/i, '');
  // CHECK ( ... )
  r = r.replace(/\bCHECK\s*\((?:[^()]*|\((?:[^()]*|\([^()]*\))*\))*\)/gi, '');
  // النوع
  const tm = r.match(/^(INT(EGE)?R?|TINYINT|SMALLINT|MEDIUMINT|BIGINT|FLOAT|DOUBLE|REAL|DEC(IMAL)?|NUMERIC|FIXED|CHAR|VARCHAR|TINYTEXT|TEXT|MEDIUMTEXT|LONGTEXT|BINARY|VARBINARY|TINYBLOB|BLOB|MEDIUMBLOB|LONGBLOB|DATE|DATETIME|TIME|TIMESTAMP|YEAR|BIT|JSON|ENUM|SET|GEOMETRY)(\(\d*(,\d*)?\))?(\s+[^,]*)?/i);
  let mapped, remainder;
  if (tm) {
    mapped = mapColumnType(tm[1] + (tm[3] || ''));
    remainder = r.slice(tm[0].length);
  } else {
    mapped = 'TEXT';
    remainder = '';
  }
  let outDef = '`' + name + '` ' + mapped;
  if (isAutoInc) outDef += ' PRIMARY KEY AUTOINCREMENT';
  else {
    // أبقِ NOT NULL / DEFAULT / UNIQUE / PRIMARY KEY
    const keep = [];
    if (/\bNOT\s+NULL\b/i.test(remainder)) keep.push('NOT NULL');
    const dm = remainder.match(/\bDEFAULT\s+('[^']*'|\d+(?:\.\d+)?|NULL|CURRENT_TIMESTAMP|'[^']*')/i);
    if (dm) keep.push('DEFAULT ' + dm[1]);
    if (/\bUNIQUE\b/i.test(remainder) && !/\bPRIMARY\s+KEY\b/i.test(remainder)) keep.push('UNIQUE');
    if (/\bPRIMARY\s+KEY\b/i.test(remainder)) keep.push('PRIMARY KEY');
    if (keep.length) outDef += ' ' + keep.join(' ');
  }
  return outDef;
}

// تحويل CREATE TABLE كامل
// يعيد { ddl, name, skipped } أو null إن تعذر
function translateCreateTable(stmt) {
  const s = stmt.replace(/\s+/g, ' ').trim();
  const m = s.match(/^CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(`[^`]+`|\[[^\]]+\]|\w+)\s*\(([\s\S]*)\)\s*(.*)$/i);
  if (!m) return null;
  const name = m[1].replace(/`|\[|\]/g, '');
  const bodyRaw = m[2];
  const options = m[3] || '';
  const skipped = [];

  // تحقق من أن الإخلاء المتبقي بعد القوس المغلق لا يحتوي أقواساً (خيارات الجدول فقط)
  const parts = splitTopLevel(bodyRaw, ',');
  const defs = [];
  let pkCol = null;

  for (let p of parts) {
    const part = p.trim();
    if (part === '') continue;
    if (/^PRIMARY\s+KEY\s*\(/i.test(part)) {
      const cm = part.match(/^PRIMARY\s+KEY\s*\(([^)]*)\)/i);
      pkCol = cm ? cm[1].split(',').map(x => x.trim().replace(/`/g, '').replace(/^\(\d+\)\s*/,'')) : [];
      continue;
    }
    if (/^UNIQUE\s+(KEY\s+`?[\w]+`?\s*)?\(/i.test(part) || /^UNIQUE\s*\(/i.test(part)) {
      const cm = part.match(/\(([^)]*)\)/);
      if (cm) defs.push('UNIQUE (' + cm[1].trim() + ')');
      continue;
    }
    if (/^(KEY|FULLTEXT|SPATIAL|CONSTRAINT|FOREIGN\s+KEY|INDEX)\b/i.test(part)) {
      skipped.push(part.replace(/\s+/g, ' ').slice(0, 80));
      continue;
    }
    if (/^CHECK\b/i.test(part)) { skipped.push('CHECK ...'); continue; }
    const col = translateColumnDef(part, skipped);
    if (col !== null) defs.push(col);
  }

  // SQLite: مفتاح أساسي واحد فقط. إن وُجد AUTOINCREMENT فهو يحمل PRIMARY KEY
  // (يُسقط أي PRIMARY KEY مركب آخر — مقبول للمحرك التجريبي).
  const hasAutoInc = defs.some(d => /AUTOINCREMENT/.test(d));
  if (!hasAutoInc && pkCol && pkCol.length > 0) {
    defs.push('PRIMARY KEY (' + pkCol.join(', ') + ')');
  }

  if (!defs.length) return null;
  const ddl = 'CREATE TABLE `' + name + '` (' + defs.join(', ') + ')';
  return { ddl, name, skipped };
}

// ---------------------------------------------------------------------
//  تنقية قيم/أوامر MySQL لتعمل في SQLite
// ---------------------------------------------------------------------

// تحويل 0x1F -> x'1F'  و  b'01' -> 1  وإزالة بادئات الترميز _utf8'...'
// مهم: SQLite لا يفهم الهروب بالمائل \' — لذا نفكّ هروب MySQL ونعيد
// ترميزه بأسلوب SQLite (تضعيف علامة الاقتباس).
function sanitizeSqliteValues(sql) {
  let out = '';
  let inS = false, inD = false;
  for (let i = 0; i < sql.length; i++) {
    const ch = sql[i], nx = i + 1 < sql.length ? sql[i + 1] : '';
    if (inS) {
      if (ch === '\\') {
        // فكّ هروب MySQL إلى حرف فعلي، ثم أعد ترميزه لـ SQLite
        const c = nx;
        if (c === "'") out += "''";
        else if (c === '\\') out += '\\';
        else if (c === 'n') out += '\n';
        else if (c === 'r') out += '\r';
        else if (c === 't') out += '\t';
        else if (c === '0') out += '';      // NUL: لا يقبله SQLite في TEXT
        else if (c === 'Z') out += '\x1a';
        else if (c === 'b') out += '\b';
        else if (c === '%') out += '\\%';  // MySQL \% = حرفي (نُبقيه كما هو)
        else if (c === '_') out += '\\_';
        else out += c === '' ? '\\' : c;
        if (nx !== '') i++;
        continue;
      }
      out += ch;
      if (ch === "'") {
        if (nx === "'") { out += "'"; i++; } else inS = false;
      }
      continue;
    }
    if (inD) {
      if (ch === '\\') {
        const c = nx;
        if (c === '"') out += '""';
        else if (c === '\\') out += '\\';
        else if (c === 'n') out += '\n';
        else if (c === 'r') out += '\r';
        else if (c === 't') out += '\t';
        else out += c === '' ? '\\' : c;
        if (nx !== '') i++;
        continue;
      }
      out += ch;
      if (ch === '"') inD = false;
      continue;
    }
    if (ch === "'") { inS = true; out += ch; continue; }
    if (ch === '"') { inD = true; out += ch; continue; }
    // بادئة ترميز: _utf8'..'  _binary'..'  _latin1'..'  _utf8mb4'..'
    const cp = sql.slice(i).match(/^_[a-z0-9_]{2,10}'/i);
    if (cp) { i += cp[0].length - 1; out += "'"; continue; }
    // رقم سداسي 0x...
    const hx = sql.slice(i).match(/^0[xX][0-9a-fA-F]+/);
    if (hx && (i === 0 || /[\s(,=\[]/.test(sql[i - 1]))) {
      out += "x'" + hx[0].slice(2) + "'";
      i += hx[0].length - 1;
      continue;
    }
    // رقم ثنائي b'...'
    const bt = sql.slice(i).match(/^([bB])'([01]*)'/);
    if (bt && (i === 0 || /[\s(,=\[]/.test(sql[i - 1]))) {
      out += (bt[2] ? parseInt(bt[2], 2) : 0);
      i += bt[0].length - 1;
      continue;
    }
    out += ch;
  }
  // أمان أخير: أزل أي NUL متبقٍ (لا يقبله SQLite في TEXT)
  return out.replace(/\0/g, '');
}

// دوال SELECT: تحويلات محدودة لدعم استعلامات البرنامج
function translateSelect(sql) {
  let s = sql;
  s = s.replace(/\bNOW\s*\(\s*\)/gi, "datetime('now')");
  s = s.replace(/\bCURDATE\s*\(\s*\)/gi, "date('now')");
  s = s.replace(/\bCURTIME\s*\(\s*\)/gi, "time('now')");
  s = s.replace(/\bSYSDATE\s*\(\s*\)/gi, "datetime('now')");
  s = s.replace(/\bCONVERT\s*\(([^,()]+)\s+USING\s+\w+\)/gi, '($1)');
  s = s.replace(/\bCAST\s*\(([^()]+)\s+AS\s+SIGNED(?:\s+INTEGER)?\)/gi, 'CAST($1 AS INTEGER)');
  s = s.replace(/\bCAST\s*\(([^()]+)\s+AS\s+UNSIGNED(?:\s+INTEGER)?\)/gi, 'CAST($1 AS INTEGER)');
  s = s.replace(/\bCAST\s*\(([^()]+)\s+AS\s+(?:CHAR|CHARACTER)\s*(?:\(\s*\d+\s*\))?\)/gi, 'CAST($1 AS TEXT)');
  s = s.replace(/\bCAST\s*\(([^()]+)\s+AS\s+BINARY\s*(?:\(\s*\d+\s*\))?\)/gi, 'CAST($1 AS BLOB)');
  s = s.replace(/\bCAST\s*\(([^()]+)\s+AS\s+(?:DATE|DATETIME|TIMESTAMP|TIME)\)/gi, 'CAST($1 AS TEXT)');
  s = s.replace(/\bIFNULL\s*\(/gi, 'ifnull(');
  s = s.replace(/\bGROUP_CONCAT\s*\(([^()]*)\s+SEPARATOR\s+'((?:[^'\\]|\\.)*)'\s*\)/gi, "GROUP_CONCAT($1, '$2')");
  s = s.replace(/\bIF\s*\(/gi, 'IIF(');
  s = s.replace(/\bWITH\s+ROLLUP\b/gi, '');
  return s;
}

module.exports = {
  splitSqlStatements,
  stripTrailingDelim,
  isCommentOnly,
  stripNormalComments,
  translateCreateTable,
  sanitizeSqliteValues,
  translateSelect,
  splitTopLevel,
};
