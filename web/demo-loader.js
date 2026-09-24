'use strict';
// =====================================================================
//  demo-loader.js - تجهيز قاعدة المصدر التجريبية (ss2025)
//  يستورد المخطط الحقيقي + البيانات الأولية + بيانات تجريبية واقعية
//  حتى يمكن تجربة الإقفال كاملًا (ss2025 -> ss2026).
// =====================================================================
const fs = require('fs');
const path = require('path');
const { engine } = require('./engine');
const S = require('./sql-file');

const REPO = path.join(__dirname, '..');
const SCHEMA = path.join(REPO, 'Schema16102016.sql');
const PRIMARY = path.join(REPO, 'PrimaryData20150428.sql');

function importFileToDb(dbName, filePath, log) {
  const text = fs.readFileSync(filePath, 'utf8');
  const conn = { db: null, user: 'root', fkChecks: true, charset: 'utf8' };
  engine.createDatabase(dbName, true);
  conn.db = dbName;
  const db = engine.openDb(dbName);
  const stmts = S.splitSqlStatements(text).map(s => S.stripTrailingDelim(s)).filter(s => s.trim() !== '');
  let ok = 0, skipped = 0, errors = [];
  for (const raw of stmts) {
    const clean = S.stripNormalComments(raw).trim().replace(/;+$/, '');
    if (clean === '' || S.isCommentOnly(clean)) { skipped++; continue; }
    try {
      engine.execute(conn, clean);
      ok++;
    } catch (e) {
      errors.push(clean.slice(0, 80) + '  =>  ' + e.message.slice(0, 80));
      skipped++;
    }
  }
  log('  ' + path.basename(filePath) + ': ' + ok + ' أمرًا ناجحًا، ' + errors.length + ' فاشل، ' + skipped + ' تعليقات مُتخطاة');
  if (errors.length) log('  أخطاء: ' + errors.slice(0, 5).join(' | '));
  return { ok, skipped, errors };
}

// منتجات تجريبية (25) - اسم عربي + فرنسي، سعر، تكلفة، كمية أولية
const PRODUCTS = [
  ['A001', 'سكر 5 كغ', 'Sucre 5kg', 1, 120, 15.00, 12.50],
  ['A002', 'زيت المائدة 5 لتر', "Huile 5L", 1, 80, 38.00, 33.00],
  ['A003', 'دقيق 25 كغ', 'Farine 25kg', 1, 60, 210.00, 185.00],
  ['A004', 'حليب مجفف 400غ', 'Lait en poudre 400g', 2, 200, 650.00, 540.00],
  ['A005', 'قهوة 250غ', 'Café 250g', 2, 150, 950.00, 800.00],
  ['A006', 'شاي 200غ', 'Thé 200g', 2, 180, 320.00, 260.00],
  ['A007', 'معجون 500غ', 'Semoule 500g', 1, 300, 45.00, 38.00],
  ['A008', 'تونة 160غ', 'Thon 160g', 2, 400, 280.00, 230.00],
  ['A009', 'مربى العنب 370غ', 'Confiture raisin 370g', 3, 90, 220.00, 170.00],
  ['A010', 'صلصة الطماطم 400غ', 'Sauce tomate 400g', 1, 250, 120.00, 95.00],
  ['A011', 'بسكويت محشي', 'Biscuit garni', 3, 320, 60.00, 48.00],
  ['A012', 'ماء معدني 1.5 لتر', 'Eau minérale 1.5L', 3, 500, 15.00, 11.00],
  ['A013', 'مشروب غازي 33cl', 'Boisson gazeuse 33cl', 3, 450, 40.00, 30.00],
  ['A014', 'عصير برتقال 1 لتر', 'Jus d\'orange 1L', 3, 120, 250.00, 190.00],
  ['A015', 'صابون سائل 1 لتر', 'Lessive liquide 1L', 4, 100, 350.00, 280.00],
  ['A016', 'مناديل ورقية', 'Chiffons papier', 4, 200, 25.00, 18.00],
  ['A017', 'معقم 500مل', 'Désinfectant 500ml', 4, 150, 180.00, 130.00],
  ['A018', 'فرشاة أسنان', 'Brosse à dents', 4, 250, 35.00, 24.00],
  ['A019', 'معجون أسنان 75مل', 'Pâte à dents 75ml', 4, 140, 150.00, 105.00],
  ['A020', 'صابون صحي 125غ', 'Savon de toilette 125g', 4, 220, 45.00, 32.00],
  ['A021', 'دجاج طازج (كغ)', 'Poulet frais (kg)', 5, 60, 850.00, 720.00],
  ['A022', 'لحم بقري (كغ)', 'Bœuf (kg)', 5, 40, 1900.00, 1600.00],
  ['A023', 'بيض (30 حبة)', 'Œufs (30)', 5, 90, 900.00, 750.00],
  ['A024', 'جبن أبيض 500غ', 'Fromage blanc 500g', 5, 70, 480.00, 390.00],
  ['A025', 'زبدة 250غ', 'Beurre 250g', 5, 55, 650.00, 540.00],
];

// زبائن وموردون - Solde (الدين على الزبون) / Soldefx (مستحق للمورد)
const PERSONS = [
  // [raiSocial, contactName, tel, mobile, idType, CreditInitial, DetteInitial, solde, soldefx, Activity]
  ['شركة النور للتوزيع', 'أحمد بن علي', '032.14.22.03', '0664.198.606', 1, 0, 0, 15000.00, 0, 'بيع جملة'],
  ['مؤسسة الخضر والفاكهة', 'خالد منصور', '033.20.11.04', '0770.220.330', 1, 0, 0, 8500.50, 0, 'بيع تجزئة'],
  ['مطعم الأصيل', 'سمير حداد', '031.95.55.02', '0550.111.222', 1, 0, 0, 23000.00, 0, 'مطاعم'],
  ['فندق الواحة', 'ليلى مراد', '031.90.10.10', '0661.333.444', 1, 0, 0, 41000.75, 0, 'فنادق'],
  ['مخابز المدينة', 'عبد القادر طاهر', '033.12.88.99', '0771.555.666', 1, 0, 0, 5600.25, 0, 'مخابز'],
  ['محل الحديقة', 'نادية بوقرة', '032.22.33.44', '0662.777.888', 1, 0, 0, 1200.00, 0, 'بقالة'],
  ['مدرسة الأمل', 'فرحات صالح', '031.99.00.11', '0552.999.000', 1, 0, 0, 0, 0, 'تعليم'],
  ['صيدلية السلام', 'د. رياض عمر', '033.44.55.66', '0773.121.314', 1, 0, 0, 7800.00, 0, 'صيدليات'],
  ['شركة النقل السريع', 'بلقاسم نور', '032.55.66.77', '0664.151.617', 3, 0, 0, 3200.00, -4500.00, 'نقل'],
  ['مؤسسة النظافة الحديثة', 'حسان قاسم', '031.77.88.99', '0553.252.627', 3, 0, 0, 0, -12000.00, 'خدمات'],
  ['مطبعة الوسام', 'رشيد بلال', '033.88.99.00', '0774.383.939', 3, 0, 0, 950.00, -800.00, 'طباعة'],
  ['ورشة الصيانة الشاملة', 'توفيق سالم', '032.99.00.22', '0665.414.243', 3, 0, 0, 0, -6300.00, 'صيانة'],
  ['مطعم البحر', 'إبراهيم نجار', '031.11.22.33', '0554.545.556', 1, 0, 0, 18700.40, 0, 'مطاعم'],
  ['مقهى الصداقة', 'كمال زروق', '033.33.44.55', '0775.676.778', 1, 0, 0, 4300.10, 0, 'مقاهي'],
  ['محل الإلكترونيات', 'ماجد شرقي', '032.66.77.88', '0666.797.980', 1, 0, 0, 0, 0, 'إلكترونيات'],
  ['سوبر ماركت الوسط', 'عائشة درويش', '031.44.55.66', '0555.818.283', 1, 0, 0, 5200.00, 0, 'بيع تجزئة'],
  // موردون
  ['مصنع الحليب الوطني', 'مراسل: يوسف', '021.44.00.11', '0780.111.000', 2, 0, 0, 0, -32000.00, 'تصنيع ألبان'],
  ['مؤسسة السكر المتحدة', 'مراسل: سليم', '021.55.22.33', '0780.222.111', 2, 0, 0, 0, -18500.00, 'سكر'],
  ['شركة الزيوت الجزائرية', 'مراسل: هدى', '021.66.44.55', '0780.333.222', 2, 0, 0, 0, -27400.00, 'زيوت'],
  ['مورد القهوة العربية', 'مراسل: جواد', '021.77.55.66', '0780.444.333', 2, 0, 0, 0, -9800.00, 'مواد أولية'],
  ['مطبعة العبوات', 'مراسل: سعاد', '021.88.66.77', '0780.555.444', 2, 0, 0, 0, -15600.00, 'عبوات'],
  ['شركة المياه المعدنية', 'مراسل: فريد', '021.99.77.88', '0780.666.555', 2, 0, 0, 0, -7300.00, 'مشروبات'],
  ['مورد الخضر - سوق الجملة', 'مراسل: الطاهر', '021.10.88.99', '0780.777.666', 2, 0, 0, 0, -21000.00, 'خضر وفواكه'],
];

function esc(s) {
  return "'" + String(s).replace(/\\/g, '\\\\').replace(/'/g, "\\'") + "'";
}

function setupDemoData(force, log = () => {}) {
  const db = 'ss2025';
  const report = { db, steps: [] };

  if (engine.reg[db] && !force) {
    throw new Error('قاعدة ' + db + ' موجودة بالفعل — استخدم "إعادة التجهيز" للتبديل.');
  }
  if (engine.reg[db]) {
    engine.dropDatabase(db, true);
    report.steps.push('حُذفت ' + db + ' القديمة');
  }

  log('إنشاء قاعدة المصدر التجريبية ' + db + ' ...');
  engine.createDatabase(db, true);

  importFileToDb(db, SCHEMA, (l) => log(l));
  importFileToDb(db, PRIMARY, (l) => log(l));

  const conn = { db, user: 'root', fkChecks: true, charset: 'utf8' };
  const dbx = engine.openDb(db);

  // تصنيفات إضافية
  engine.execute(conn, `INSERT INTO categoris VALUES (2,'Boissons',1,1,NULL,NULL,NULL,NULL),(3,'Epicerie',1,1,NULL,NULL,NULL,NULL),(4,'Hygiene',1,1,NULL,NULL,NULL,NULL),(5,'Frais',1,1,NULL,NULL,NULL,NULL)`);
  report.steps.push('تصنيفات: +4');

  // المنتجات
  const insA = [];
  for (const [ref, ar, fr, cat, qte, pv, pa] of PRODUCTS) {
    insA.push(`(${esc(ref)},${esc(ar)},${esc(fr)},${cat},${qte}.000000,${(pv / 1.19).toFixed(2)},${pv.toFixed(2)},19.000000,1,${esc(ref)})`);
  }
  engine.execute(conn, 'INSERT INTO articlesliste (RefArt, NomArt, NomArtAR, idCat, QTE, PrixAchat, PrixVD, TVA, idDoss, Ninven) VALUES ' + insA.join(','));
  report.steps.push('منتجات: ' + PRODUCTS.length);

  // أكواد بار
  const insC = PRODUCTS.slice(0, 10).map((p, i) => `('613${String(100000000 + i * 137).padStart(9, '0')}',${esc(p[0])},1,NULL,1.0)`).join(',');
  engine.execute(conn, 'INSERT INTO codbar (idcodBar,RefArt,idDoss,Observ,groupage) VALUES ' + insC);
  report.steps.push('أكواد بار: 10');

  // الأشخاص: [raiSocial, contact, tel, mobile, idType, CreditInitial, DetteInitial, solde, soldefx, Activity]
  const insP = PERSONS.map(p => `(${esc(p[0])},${esc(p[1])},${esc(p[2])},${esc(p[3])},${p[4]},1,${p[5]},${p[6]},${esc(p[9])},${p[7].toFixed(2)},${p[8].toFixed(2)},1,NULL)`).join(',');
  engine.execute(conn, `INSERT INTO personnez (raiSocial,contactName,tel,mobile,idType,idClass,CreditInitial,DetteInitial,Activity,solde,soldefx,idDoss,blocker) VALUES ${insP}`);
  report.steps.push('أشخاص: ' + PERSONS.length + ' (زبائن وموردون)');

  // المفضلة
  engine.execute(conn, "INSERT INTO fav (Nomfav, img, iddoss) VALUES ('المشروبات','',1),('الخضروات','',1)");
  engine.execute(conn, "INSERT INTO favliste (prod1,prod2,prod3,prod4,prod5,idfav,iddoss,ref1,ref2,ref3,ref4,ref5) VALUES ('ماء معدني 1.5 لتر','مشروب غازي 33cl','عصير برتقال 1 لتر',NULL,NULL,1,1,'A012','A013','A014',NULL,NULL),('زبدة 250غ','جبن أبيض 500غ','بيض (30 حبة)',NULL,NULL,2,1,'A025','A024','A023',NULL,NULL)");
  report.steps.push('مفضلة: 2');

  // مستخدمون إضافيون
  engine.execute(conn, `INSERT INTO userz (nomUser,passWord,Annuler,canAdmin,canSell,canBuy,canSellCont,canFacturer,idDoss,dbname,superAdmin,canRemise,canChangePrice) VALUES ('Vendeur 1','2222',0,0,1,0,1,1,1,${esc('ss2025')},0,0,0)`);
  report.steps.push('مستخدم: +1 (Vendeur 1 / 2222)');

  // الشركة + السنة
  engine.execute(conn, 'UPDATE dosse SET idyears = 2025 WHERE idDoss = 1');
  engine.execute(conn, 'INSERT INTO yearz (idyears,idDoss) VALUES (2025,1)');
  report.steps.push('سنة 2025 مسجلة في yearz و dosse');

  // إحصاء
  const counts = {};
  for (const t of ['articlesliste', 'personnez', 'codbar', 'userz', 'dosse', 'fav', 'favliste', 'categoris', 'yearz']) {
    const r = engine.execute(conn, 'SELECT COUNT(*) c FROM ' + t);
    counts[t] = r.rows[0][0];
  }
  report.counts = counts;
  log('إحصاء ' + db + ': ' + JSON.stringify(counts));
  return report;
}

function demoStatus() {
  const info = { source: null, destination: null, tables: 0 };
  for (const db of engine.listDatabases()) {
    const conn = { db, user: 'root', fkChecks: true, charset: 'utf8' };
    const r = engine.execute(conn, 'SHOW TABLES');
    const counts = {};
    for (const t of ['articlesliste', 'personnez', 'codbar', 'userz', 'dosse']) {
      try {
        const c = engine.execute(conn, 'SELECT COUNT(*) c FROM ' + t);
        counts[t] = c.rows[0][0];
      } catch { counts[t] = null; }
    }
    if (db === 'ss2025') info.source = { db, tables: r.rows.length, counts };
    else info.destination = { db, tables: r.rows.length, counts };
  }
  return info;
}

function resetDemo(log = () => {}) {
  const dropped = [];
  for (const db of [...engine.listDatabases()]) {
    engine.dropDatabase(db, true);
    dropped.push(db);
    log('حُذفت ' + db);
  }
  return dropped;
}

module.exports = { setupDemoData, demoStatus, resetDemo };
