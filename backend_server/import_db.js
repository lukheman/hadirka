const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function runImport() {
  console.log('⏳ Connecting to XAMPP MySQL server (localhost)...');
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      user: 'root',
      password: '',
      multipleStatements: true,
    });

    console.log('✅ Connected to MySQL server.');

    const sqlPath = path.join(__dirname, 'db_absen_tjs.sql');
    const sqlContent = fs.readFileSync(sqlPath, 'utf8');

    console.log('⏳ Importing db_absen_tjs.sql into XAMPP MySQL...');
    await connection.query(sqlContent);

    console.log('🎉 SUCCESS! Database db_absen_tjs and all tables successfully imported into XAMPP MySQL!');
    await connection.end();
    process.exit(0);
  } catch (err) {
    console.error('❌ Failed to import database to XAMPP MySQL:', err.message);
    process.exit(1);
  }
}

runImport();
