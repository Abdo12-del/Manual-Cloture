'use strict';
// =====================================================================
//  mysql-server.js - خادم MySQL تجريبي (بروتوكول MySQL الحقيقي)
//
//  خادم TCP يتحدث بروتوكول MySQL (handshake V10 + mysql_native_password)
//  فوق المحرك التجريبي (SQLite). يتحدث معه أي عميل MySQL حقيقي:
//  mysql2 (البرنامج نفسه)، mysql client، phpMyAdmin...
//
//  يدعم: COM_QUERY, COM_PING, COM_QUIT, COM_INIT_DB, COM_STATISTICS,
//         COM_FIELD_LIST, COM_SLEEP + أوضاع EOF/DEPRECATE_EOF.
// =====================================================================
const net = require('net');
const { engine } = require('./engine');
const S = require('./sql-file');

const PORT = parseInt(process.env.MYSQL_PORT || '3306', 10);
const HOST = process.env.MYSQL_HOST || '0.0.0.0';
const SERVER_VERSION = '10.6.19-gamadev-demo';

// ---------------- ثوابت القدرات ----------------
const C = {
  LONG_PASSWORD: 0x00000001,
  FOUND_ROWS: 0x00000002,
  LONG_FLAG: 0x00000004,
  CONNECT_WITH_DB: 0x00000008,
  NO_SCHEMA: 0x00000010,
  PROTOCOL_41: 0x00000200,
  TRANSACTIONS: 0x00002000,
  SECURE_CONNECTION: 0x00008000,
  MULTI_STATEMENTS: 0x00010000,
  MULTI_RESULTS: 0x00020000,
  PS_MULTI_RESULTS: 0x00040000,
  PLUGIN_AUTH: 0x00080000,
  CONNECT_ATTRS: 0x00100000,
  PLUGIN_AUTH_LENENC: 0x00200000,
  DEPRECATE_EOF: 0x01000000,
};
const SERVER_CAPS = (
  C.LONG_PASSWORD | C.FOUND_ROWS | C.LONG_FLAG | C.CONNECT_WITH_DB |
  C.PROTOCOL_41 | C.TRANSACTIONS | C.SECURE_CONNECTION |
  C.MULTI_STATEMENTS | C.MULTI_RESULTS | C.PS_MULTI_RESULTS |
  C.PLUGIN_AUTH | C.CONNECT_ATTRS | C.PLUGIN_AUTH_LENENC | C.DEPRECATE_EOF
);

// ---------------- أدوات الحزم ----------------
function writePacket(socket, seq, payload) {
  const len = payload.length;
  const head = Buffer.alloc(4);
  head.writeUInt8(len & 0xff, 0);
  head.writeUInt8((len >> 8) & 0xff, 1);
  head.writeUInt8((len >> 16) & 0xff, 2);
  head.writeUInt8(seq & 0xff, 3);
  socket.write(Buffer.concat([head, payload]));
}

function lenencInt(v) {
  if (v < 251) return Buffer.from([v]);
  if (v < 0x10000) { const b = Buffer.alloc(3); b[0] = 0xfc; b.writeUInt16LE(v, 1); return b; }
  const b = Buffer.alloc(4); b[0] = 0xfd; b.writeUIntLE(v, 1, 3); return b;
}
function lenencStr(s) {
  const buf = Buffer.from(String(s), 'utf8');
  return Buffer.concat([lenencInt(buf.length), buf]);
}

function okPacket(affected, insertId, statusFlags = 0x0002, warnings = 0) {
  const p = [Buffer.from([0x00]), lenencInt(affected || 0), lenencInt(insertId || 0),
    Buffer.from([(statusFlags & 0xff), (statusFlags >> 8) & 0xff]),
    Buffer.from([(warnings & 0xff), (warnings >> 8) & 0xff])];
  return Buffer.concat(p);
}
function errPacket(code, sqlState, msg) {
  const p = [Buffer.from([0xff]), Buffer.from([(code & 0xff), (code >> 8) & 0xff]),
    Buffer.from([0x23]), Buffer.from(sqlState.slice(0, 5).padEnd(5, ' '), 'ascii'),
    Buffer.from(String(msg), 'utf8')];
  return Buffer.concat(p);
}
function eofPacket() {
  return Buffer.from([0xfe, 0, 0, 0x02, 0]);
}
function colDef(schema, table, name, type = 0xfd, flags = 0, decimals = 10, length = 255) {
  const p = [
    lenencStr('def'), lenencStr(schema || ''), lenencStr(table || ''),
    lenencStr(table || ''), lenencStr(name || ''), lenencStr(name || ''),
    Buffer.from([0x0c]),                                      // طول الحقول الثابتة
    Buffer.from([0x21, 0x00]),                                // character set = 33 (utf8_general_ci)
    Buffer.from([length & 0xff, (length >> 8) & 0xff, 0, 0]), // column length
    Buffer.from([type & 0xff]),                               // column type
    Buffer.from([flags & 0xff, (flags >> 8) & 0xff]),         // flags
    Buffer.from([decimals & 0xff]),                           // decimals
    Buffer.from([0, 0]),                                      // filler
  ];
  return Buffer.concat(p);
}
function encodeValue(v) {
  if (v === null || v === undefined) return Buffer.from([0xfb]);
  if (Buffer.isBuffer(v)) return lenencStr(v.toString('binary'));
  return lenencStr(String(v));
}

// ---------------- قراءة حزم من التيار ----------------
class PacketReader {
  constructor(socket, onPacket) {
    this.buf = Buffer.alloc(0);
    this.onPacket = onPacket;
    socket.on('data', (d) => {
      this.buf = Buffer.concat([this.buf, d]);
      this.drain();
    });
  }
  drain() {
    while (this.buf.length >= 4) {
      const len = this.buf[0] | (this.buf[1] << 8) | (this.buf[2] << 16);
      if (this.buf.length < 4 + len) return;
      const seq = this.buf[3];
      const payload = this.buf.slice(4, 4 + len);
      this.buf = this.buf.slice(4 + len);
      try { this.onPacket(seq, payload); } catch (e) { /* يُعالج في المعالج */ }
    }
  }
}

// ---------------- اتصال واحد ----------------
let connCounter = 1;
function handleSocket(socket) {
  const threadId = connCounter++;
  const state = {
    phase: 'handshake',
    caps: 0,
    deprecateEof: false,
    conn: { db: null, user: 'root', fkChecks: true, charset: 'utf8' },
    seq: 0,
    closed: false,
  };
  state.salt = Buffer.from(require('crypto').randomBytes(20));

  socket.setNoDelay(true);
  socket.on('error', () => {});
  socket.on('close', () => { state.closed = true; });

  // --- Handshake V10 ---
  const p1 = state.salt.slice(0, 8);
  const p2 = state.salt.slice(8, 20);
  const hs = [
    Buffer.from([0x0a]),
    Buffer.from(SERVER_VERSION + '\0', 'utf8'),
    Buffer.from([threadId & 0xff, (threadId >> 8) & 0xff, (threadId >> 16) & 0xff, (threadId >> 24) & 0xff]),
    p1,
    Buffer.from([0]),
    Buffer.from([SERVER_CAPS & 0xff, (SERVER_CAPS >> 8) & 0xff]),
    Buffer.from([33]), // charset utf8
    Buffer.from([0x02, 0x00]), // status: autocommit
    Buffer.from([(SERVER_CAPS >> 16) & 0xff, (SERVER_CAPS >> 24) & 0xff]),
    Buffer.from([21]), // طول كامل للـ salt
    Buffer.alloc(10),
    Buffer.concat([p2, Buffer.from([0])]),
    Buffer.from('mysql_native_password\0', 'utf8'),
  ];
  writePacket(socket, 0, Buffer.concat(hs));

  const reader = new PacketReader(socket, (seq, payload) => {
    if (state.closed) return;
    try {
      if (state.phase === 'handshake') {
        state.phase = 'ready';
        if (payload.length > 4) {
          const caps = payload.readUInt32LE(0);
          state.caps = caps;
          state.deprecateEof = !!(caps & C.DEPRECATE_EOF);
          // اسم المستخدم
          let i = 32; // 4 caps + 4 maxpkt + 1 charset + 23 reserved
          const username = payload.toString('utf8', i, payload.indexOf(0, i));
          state.conn.user = username || 'root';
          i = payload.indexOf(0, i) + 1;
          // استجابة المصادقة
          let authLen;
          if (caps & C.PLUGIN_AUTH_LENENC || (caps & C.PLUGIN_AUTH) === 0) {
            authLen = payload[i]; i += 1;
          } else {
            authLen = payload[i]; i += 1;
          }
          i += authLen;
          // قاعدة محددة؟
          if (caps & C.CONNECT_WITH_DB) {
            if (i < payload.length) {
              const dbEnd = payload.indexOf(0, i);
              const dbn = dbEnd === -1 ? payload.toString('utf8', i) : payload.toString('utf8', i, dbEnd);
              if (dbn) {
                if (engine.reg[dbn]) state.conn.db = dbn;
                else { writePacket(socket, 1, errPacket(1049, '42000', `Unknown database '${dbn}'`)); socket.end(); return; }
              }
              i = (dbEnd === -1 ? payload.length : dbEnd + 1);
            }
          }
          // خصائص الاتصال
          if (caps & C.CONNECT_ATTRS && i < payload.length) {
            const al = payload[i]; i += 1 + al;
          }
        }
        writePacket(socket, 2, okPacket(0, 0));
        return;
      }
      onCommand(socket, state, payload);
    } catch (e) {
      try {
        const code = e.code || 1105;
        writePacket(socket, state.seq, errPacket(code, e.sqlState || 'HY000', e.message));
      } catch {}
    }
  });

  // --- الأوامر ---
  function onCommand(socket, state, payload) {
    const cmd = payload[0];
    const body = payload.slice(1);

    switch (cmd) {
      case 0x01: // QUIT
        socket.end(); return;
      case 0x0e: // PING
        writePacket(socket, 1, okPacket(0, 0)); return;
      case 0x09: { // STATISTICS
        const text = 'Uptime: ' + Math.floor(process.uptime()) +
          '  Threads: 1  Questions: ' + connCounter +
          '  Slow queries: 0  Opens: 1  Flush tables: 1  Open tables: 1';
        writePacket(socket, 1, Buffer.concat([Buffer.from([0x00]), Buffer.from(text, 'utf8')]));
        return;
      }
      case 0x02: { // INIT_DB
        const dbn = body.toString('utf8').replace(/\0.*$/, '');
        if (!engine.reg[dbn]) { writePacket(socket, 1, errPacket(1049, '42000', `Unknown database '${dbn}'`)); return; }
        state.conn.db = dbn;
        writePacket(socket, 1, okPacket(0, 0));
        return;
      }
      case 0x04: { // FIELD_LIST (قديم)
        writePacket(socket, 1, eofPacket());
        return;
      }
      case 0x03: { // QUERY
        const sql = body.toString('utf8');
        handleQuery(socket, state, sql);
        return;
      }
      default: {
        // COM_SLEEP (0x00) وغير معروفة: رد OK
        writePacket(socket, 1, okPacket(0, 0));
      }
    }
  }

  function handleQuery(socket, state, sql) {
    // أوامر متعددة في نص واحد: نفذها بالتتابع وأجب بالنتيجة الأخيرة ذات قيمة
    // استثناء: أجسام CREATE PROCEDURE/FUNCTION/TRIGGER/EVENT تحتوي ';' داخليًا —
    // تُمرَّر كأمر واحد دون تقسيم.
    const isRoutine = /^\s*CREATE\s+(?:OR\s+REPLACE\s+)?(?:DEFINER\s*=\s*\S+\s+)?(?:AGGREGATOR\s*\S+\s+)?(PROCEDURE|FUNCTION|TRIGGER|EVENT)\b/i.test(sql);
    let stmts;
    if (isRoutine) {
      stmts = [sql];
    } else {
      try { stmts = S.splitSqlStatements(sql); }
      catch (e) { writePacket(socket, 1, errPacket(1064, '42000', e.message)); return; }
      stmts = stmts.map(s2 => S.stripTrailingDelim(s2)).filter(s2 => s2.trim() !== '');
      if (!stmts.length) { writePacket(socket, 1, okPacket(0, 0)); return; }
    }

    let lastResult = null;
    let totalAffected = 0;
    for (const st of stmts) {
      let res;
      try {
        res = engine.execute(state.conn, st);
      } catch (e) {
        writePacket(socket, 1, errPacket(e.code || 1105, e.sqlState || 'HY000', e.message));
        return;
      }
      if (res.type === 'rows') lastResult = res;
      totalAffected += res.affected || 0;
    }

    if (lastResult) {
      const r = lastResult;
      const schema = state.conn.db || '';
      // عدد الأعمدة
      writePacket(socket, 1, lenencInt(r.columns.length));
      let seq = 2;
      for (const c of r.columns) {
        writePacket(socket, seq++, colDef(schema, '', c.name, 0xfd, 0, 10, 255));
      }
      if (!state.deprecateEof) writePacket(socket, seq++, eofPacket());
      for (const row of r.rows) {
        const parts = [];
        for (const v of row) parts.push(encodeValue(v));
        writePacket(socket, seq++, Buffer.concat(parts));
        if (state.closed) return;
      }
      writePacket(socket, seq++, state.deprecateEof ? okPacket(0, 0) : eofPacket());
    } else {
      writePacket(socket, 1, okPacket(totalAffected, 0));
    }
  }
}

function startServer(port = PORT, host = HOST) {
  return new Promise((resolve, reject) => {
    const srv = net.createServer(handleSocket);
    srv.on('error', reject);
    srv.listen(port, host, () => resolve(srv));
    return srv;
  });
}

module.exports = { startServer, PORT };
