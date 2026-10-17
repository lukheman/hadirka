const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bcrypt = require('bcryptjs');

const app = express();
app.use(cors());
app.use(express.json());


const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'tjs_app',
  password: process.env.DB_PASSWORD || 'tjs_app_2026',
  database: process.env.DB_NAME || 'db_absen_tjs',
  port: process.env.DB_PORT || 3306,
  dateStrings: true,
};

let pool;
try {
  pool = mysql.createPool(dbConfig);
  console.log('🔗 Connecting to MySQL (db_absen_tjs)...');
} catch (err) {
  console.error('❌ Error creating MySQL Pool:', err.message);
}

async function getKaryawanByIdentifier(identifier) {
  if (!identifier) return null;
  const cleanStr = String(identifier).trim();
  const [rows] = await pool.query(
    'SELECT * FROM tb_karyawan WHERE id_karyawan = ? OR LOWER(nik_karyawan) = ?',
    [isNaN(cleanStr) ? 0 : Number(cleanStr), cleanStr.toLowerCase()]
  );
  return rows.length > 0 ? rows[0] : null;
}

app.post('/api/auth/login', async (req, res) => {
  const { identifier, password } = req.body;
  if (!identifier || !password) {
    return res.status(400).json({ success: false, message: 'NIK & Password wajib diisi.' });
  }

  try {
    const user = await getKaryawanByIdentifier(identifier);

    if (user) {
      
      const isValidPassword = user.password.startsWith('$2')
        ? bcrypt.compareSync(password, user.password)
        : user.password === password;

      if (!isValidPassword) {
        return res.status(401).json({ success: false, message: 'Password Karyawan yang Anda masukkan salah.' });
      }

      return res.json({
        success: true,
        user: {
          id: user.id_karyawan,
          nik: user.nik_karyawan,
          username: user.nik_karyawan, 
          nama: user.nama_karyawan,
          email: `${user.nik_karyawan}@tjs.local`, 
          noHp: user.no_hp || '',
          role: 'karyawan',
          jabatan: user.jabatan || '-',
          departemen: '-',
          fotoProfil: user.foto_profil || null,
          token: `token_karyawan_${Date.now()}`,
        },
      });
    }

    return res.status(404).json({ success: false, message: 'NIK tidak ditemukan di database.' });
  } catch (err) {
    return res.status(500).json({ success: false, message: `Database error: ${err.message}` });
  }
});

app.post('/api/auth/register', async (req, res) => {
  const { nik, nama, password, noHp, jabatan, id_site } = req.body;

  if (!nik || !nama || !password) {
    return res.status(400).json({ success: false, message: 'NIK, Nama, & Password wajib diisi.' });
  }

  const cleanNik = nik.trim().toUpperCase();
  const hashedPassword = bcrypt.hashSync(password, 10);

  try {
    const [existCheck] = await pool.query(
      'SELECT nik_karyawan FROM tb_karyawan WHERE UPPER(nik_karyawan) = ?',
      [cleanNik]
    );

    if (existCheck.length > 0) {
      return res.status(400).json({ success: false, message: 'NIK sudah terdaftar.' });
    }

    const insertQuery = `INSERT INTO tb_karyawan (nik_karyawan, nama_karyawan, password, no_hp, jabatan, id_site, tgl_masuk, status_karyawan, dibuat_pada) VALUES (?, ?, ?, ?, ?, ?, CURDATE(), 'AKTIF', NOW())`;
    const [result] = await pool.query(insertQuery, [
      cleanNik,
      nama,
      hashedPassword,
      noHp || '',
      jabatan || '-',
      id_site || 1,
    ]);

    const newId = result.insertId;

    return res.json({
      success: true,
      message: 'Pendaftaran berhasil disimpan!',
      user: {
        id: newId,
        nik: cleanNik,
        username: cleanNik,
        nama: nama,
        email: `${cleanNik}@tjs.local`,
        noHp: noHp || '',
        role: 'karyawan',
        jabatan: jabatan || '-',
        departemen: '-',
        token: `token_karyawan_${Date.now()}`,
      },
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: `Database error: ${err.message}` });
  }
});




app.put('/api/user/profile', async (req, res) => {
  const { username, nik, nama, email, noHp, fotoProfil } = req.body;
  const identifier = username || nik;
  
  if (!identifier) {
    return res.status(400).json({ success: false, message: 'NIK wajib diisi.' });
  }

  try {
    const user = await getKaryawanByIdentifier(identifier);
    if (!user) {
      return res.status(404).json({ success: false, message: 'Pengguna tidak ditemukan.' });
    }

    if (fotoProfil !== undefined) {
      await pool.query('UPDATE tb_karyawan SET foto_profil = ? WHERE id_karyawan = ?', [fotoProfil, user.id_karyawan]);
    }

    if (nama) {
      await pool.query(
        'UPDATE tb_karyawan SET nama_karyawan = ?, no_hp = ? WHERE id_karyawan = ?',
        [nama.trim(), noHp || '', user.id_karyawan]
      );
    }

    return res.json({
      success: true,
      message: 'Data profil & foto berhasil disimpan!',
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: `Database error: ${err.message}` });
  }
});

app.put('/api/user/password', async (req, res) => {
  const { username, oldPassword, newPassword } = req.body;
  if (!username || !oldPassword || !newPassword) {
    return res.status(400).json({ success: false, message: 'Password lama dan password baru wajib diisi.' });
  }

  try {
    const user = await getKaryawanByIdentifier(username);
    if (!user) {
      return res.status(404).json({ success: false, message: 'ID / NIK pengguna tidak ditemukan.' });
    }

    const isValidPassword = user.password.startsWith('$2')
      ? bcrypt.compareSync(oldPassword, user.password)
      : user.password === oldPassword;

    if (!isValidPassword) {
      return res.status(400).json({ success: false, message: 'Password lama yang Anda masukkan salah.' });
    }

    const hashedNewPw = bcrypt.hashSync(newPassword, 10);
    await pool.query('UPDATE tb_karyawan SET password = ? WHERE id_karyawan = ?', [hashedNewPw, user.id_karyawan]);

    return res.json({ success: true, message: 'Password berhasil diubah!' });
  } catch (err) {
    return res.status(500).json({ success: false, message: `Database error: ${err.message}` });
  }
});


app.get('/api/attendance', async (req, res) => {
  try {
    const { username } = req.query;
    let query = `
      SELECT 
        a.id_absen AS id_log,
        a.id_karyawan,
        a.id_lokasi,
        a.tanggal_absen,
        a.waktu_masuk,
        a.waktu_keluar,
        a.nama_lokasi,
        a.latitude,
        a.longitude,
        a.jarak_meter,
        a.status_kehadiran,
        a.keterlambatan_menit,
        a.is_tepat_waktu,
        a.foto_selfie_path,
        a.dibuat_pada,
        k.nik_karyawan AS karyawan_nik,
        k.nik_karyawan AS karyawan_username,
        k.nama_karyawan AS karyawan_nama
      FROM tb_absen a
      JOIN tb_karyawan k ON a.id_karyawan = k.id_karyawan
    `;
    let params = [];

    if (username) {
      query += ' WHERE LOWER(k.nik_karyawan) = ? OR k.id_karyawan = ?';
      const cleanUser = username.toLowerCase();
      params.push(cleanUser, isNaN(cleanUser) ? 0 : Number(cleanUser));
    }
    query += ' ORDER BY a.dibuat_pada DESC';

    const [rows] = await pool.query(query, params);

    const mapped = rows.map((r) => {
      let durasiKerjaMenit = 0;
      if (r.waktu_masuk && r.waktu_keluar) {
        const parseTime = (tStr) => {
          const m = String(tStr).match(/(\d{1,2}):(\d{2})/);
          return m ? parseInt(m[1]) * 60 + parseInt(m[2]) : 0;
        };
        const inMin = parseTime(r.waktu_masuk);
        const outMin = parseTime(r.waktu_keluar);
        if (outMin >= inMin) durasiKerjaMenit = outMin - inMin;
      }

      return {
        id: r.id_log,
        nik: r.karyawan_nik || r.karyawan_username,
        username: r.karyawan_username,
        nama: r.karyawan_nama,
        tanggal: r.tanggal_absen,
        waktuIn: r.waktu_masuk,
        waktuOut: r.waktu_keluar,
        lokasiNama: r.nama_lokasi,
        latitude: r.latitude,
        longitude: r.longitude,
        jarakMeter: r.jarak_meter,
        status: r.status_kehadiran,
        keterlambatanMenit: r.keterlambatan_menit,
        durasiKerjaMenit: durasiKerjaMenit,
        isTepat: r.is_tepat_waktu === 1,
        fotoPath: r.foto_selfie_path,
        tipe: r.waktu_keluar ? 'check_out' : 'check_in',
        waktu: r.dibuat_pada ? String(r.dibuat_pada).replace(' ', 'T') : new Date().toISOString(),
      };
    });

    return res.json({ success: true, data: mapped });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.post('/api/attendance/submit', async (req, res) => {
  const { username, latitude, longitude, tipe, fotoPath } = req.body;
  const identifier = username || 'TJS-2024-089';

  try {
    const user = await getKaryawanByIdentifier(identifier);
    if (!user) {
      return res.status(404).json({ success: false, message: `Karyawan (${identifier}) tidak ditemukan.` });
    }

    
    const [lokasiRows] = await pool.query('SELECT * FROM tb_site WHERE is_aktif = 1 LIMIT 1');
    const idLokasi = lokasiRows.length > 0 ? lokasiRows[0].id_site : 1;
    const namaLokasi = lokasiRows.length > 0 ? lokasiRows[0].nama_site : 'Kantor TJS Dawi-Dawi';

    const now = new Date();
    const witaOffsetMs = 8 * 60 * 60 * 1000;
    const witaDate = new Date(now.getTime() + witaOffsetMs);
    const todayStr = witaDate.toISOString().substring(0, 10);
    const hours = String(witaDate.getUTCHours()).padStart(2, '0');
    const minutes = String(witaDate.getUTCMinutes()).padStart(2, '0');
    const timeStr = `${hours}:${minutes} WITA`;

    const [todayLogs] = await pool.query(
      'SELECT * FROM tb_absen WHERE id_karyawan = ? AND tanggal_absen = ?',
      [user.id_karyawan, todayStr]
    );

    let idLog = 0;
    let waktuIn = timeStr;
    let waktuOut = null;
    let durasiKerjaMenit = 0;
    let keterlambatanMenit = 0;
    let isTepat = true;

    const jamNum = witaDate.getUTCHours();
    const minNum = witaDate.getUTCMinutes();
    if (jamNum > 8 || (jamNum === 8 && minNum > 0)) {
      keterlambatanMenit = (jamNum - 8) * 60 + minNum;
      isTepat = false;
    }

    if (tipe === 'check_out') {
      if (todayLogs.length > 0) {
        idLog = todayLogs[0].id_absen;
        waktuIn = todayLogs[0].waktu_masuk || '08:00 WITA';
        waktuOut = timeStr;
        keterlambatanMenit = todayLogs[0].keterlambatan_menit || 0;
        isTepat = todayLogs[0].is_tepat_waktu === 1;

        const matchIn = waktuIn.match(/(\d{1,2}):(\d{2})/);
        if (matchIn) {
          const inTotalMin = parseInt(matchIn[1]) * 60 + parseInt(matchIn[2]);
          const outTotalMin = jamNum * 60 + minNum;
          durasiKerjaMenit = Math.max(0, outTotalMin - inTotalMin);
        }

        await pool.query(
          'UPDATE tb_absen SET waktu_keluar = ?, status_kehadiran = ? WHERE id_absen = ?',
          [waktuOut, 'Sudah Selesai', idLog]
        );
      } else {
        waktuOut = timeStr;
        waktuIn = '08:00 WITA';
        const [resIns] = await pool.query(
          `INSERT INTO tb_absen (id_karyawan, id_lokasi, tanggal_absen, waktu_masuk, waktu_keluar, nama_lokasi, latitude, longitude, jarak_meter, status_kehadiran, keterlambatan_menit, is_tepat_waktu, foto_selfie_path, dibuat_pada)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
          [user.id_karyawan, idLokasi, todayStr, waktuIn, waktuOut, namaLokasi, latitude || 0, longitude || 0, 10.0, 'Sudah Selesai', 0, 1, fotoPath || null]
        );
        idLog = resIns.insertId;
      }
    } else {
      
      if (todayLogs.length > 0) {
        idLog = todayLogs[0].id_absen;
        waktuIn = todayLogs[0].waktu_masuk || timeStr;
        waktuOut = todayLogs[0].waktu_keluar;
      } else {
        const [resIns] = await pool.query(
          `INSERT INTO tb_absen (id_karyawan, id_lokasi, tanggal_absen, waktu_masuk, waktu_keluar, nama_lokasi, latitude, longitude, jarak_meter, status_kehadiran, keterlambatan_menit, is_tepat_waktu, foto_selfie_path, dibuat_pada)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
          [user.id_karyawan, idLokasi, todayStr, waktuIn, null, namaLokasi, latitude || 0, longitude || 0, 10.0, isTepat ? 'Tepat Waktu' : `Terlambat ${keterlambatanMenit}m`, keterlambatanMenit, isTepat ? 1 : 0, fotoPath || null]
        );
        idLog = resIns.insertId;
      }
    }

    return res.json({
      success: true,
      message: `Absen ${tipe === 'check_out' ? 'keluar' : 'masuk'} berhasil disimpan.`,
      data: {
        id: idLog,
        tipe: tipe,
        lokasiId: idLokasi,
        namaLokasi: namaLokasi,
        latitude: latitude || 0,
        longitude: longitude || 0,
        jarakMeter: 10.0,
        waktu: witaDate.toISOString(),
        waktuIn: waktuIn,
        waktuOut: waktuOut,
        isTepat: isTepat,
        keterlambatanMenit: keterlambatanMenit,
        durasiKerjaMenit: durasiKerjaMenit,
        fotoPath: fotoPath || null,
      },
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: `Database error: ${err.message}` });
  }
});




app.get('/api/leave', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT p.*, k.nik_karyawan AS karyawan_nik, k.nama_karyawan AS karyawan_nama
      FROM tb_pengajuan p
      JOIN tb_karyawan k ON p.id_karyawan = k.id_karyawan
      ORDER BY p.dibuat_pada DESC
    `);

    const mapped = rows.map((r) => ({
      id: r.id_pengajuan,
      nik: r.karyawan_nik,
      username: r.karyawan_nik,
      nama: r.karyawan_nama,
      jenis: r.jenis_pengajuan,
      tanggal: r.rentang_tanggal,
      alasan: r.alasan_pengajuan,
      status: r.status_approval,
      lampiranPath: r.lampiran_path,
      createdAt: r.dibuat_pada ? String(r.dibuat_pada).replace(' ', 'T') : new Date().toISOString(),
    }));

    
    mapped.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());

    return res.json({ success: true, data: mapped });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.post('/api/leave', async (req, res) => {
  const { username, jenis, tanggal, alasan, lampiranPath } = req.body;
  const identifier = username || 'TJS-2024-089';

  try {
    const user = await getKaryawanByIdentifier(identifier);
    if (!user) {
      return res.status(404).json({ success: false, message: `Karyawan (${identifier}) tidak ditemukan.` });
    }

    const query = `INSERT INTO tb_pengajuan (id_karyawan, jenis_pengajuan, rentang_tanggal, alasan_pengajuan, status_approval, lampiran_path, dibuat_pada) VALUES (?, ?, ?, ?, 'MENUNGGU', ?, NOW())`;
    await pool.query(query, [user.id_karyawan, jenis || 'Cuti Tahunan', tanggal || '-', alasan || '-', lampiranPath || null]);

    return res.json({ success: true, message: 'Pengajuan cuti/izin/sakit berhasil disimpan.' });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.put('/api/leave/:id/status', async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  try {
    await pool.query('UPDATE tb_pengajuan SET status_approval = ? WHERE id_pengajuan = ?', [status, id]);
    return res.json({ success: true, message: `Status pengajuan (ID: ${id}) berhasil diubah menjadi ${status}.` });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});




app.get('/api/loan', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT p.*, k.nik_karyawan AS karyawan_nik, k.nama_karyawan AS karyawan_nama
      FROM tb_pinjaman p
      JOIN tb_karyawan k ON p.id_karyawan = k.id_karyawan
      ORDER BY p.created_at DESC
    `);

    const mapped = rows.map((r) => ({
      id: r.id_pinjaman,
      nik: r.karyawan_nik,
      username: r.karyawan_nik,
      nama: r.karyawan_nama,
      nominal: r.nominal_pinjaman,
      tenor: 0,
      angsuran: 0,
      alasan: r.ket_pinjaman,
      status: 'DISETUJUI',
      createdAt: r.created_at ? String(r.created_at).replace(' ', 'T') : new Date().toISOString(),
      tglPinjaman: r.tgl_pinjaman,
      tglBayar: r.tgl_bayar_pinjaman,
    }));

    return res.json({ success: true, data: mapped });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.post('/api/loan', async (req, res) => {
  const { username, nominal, tenor, angsuran, alasan } = req.body;
  const identifier = username || 'TJS-2024-089';

  try {
    const user = await getKaryawanByIdentifier(identifier);
    if (!user) {
      return res.status(404).json({ success: false, message: `Karyawan (${identifier}) tidak ditemukan.` });
    }

    const today = new Date();
    const tglPinjaman = today.toISOString().split('T')[0];

    
    const tglBayar = new Date(today);
    tglBayar.setMonth(today.getMonth() + (tenor || 1));
    const tglBayarStr = tglBayar.toISOString().split('T')[0];

    const query = `INSERT INTO tb_pinjaman (id_karyawan, tgl_pinjaman, tgl_bayar_pinjaman, nominal_pinjaman, ket_pinjaman, created_at) VALUES (?, ?, ?, ?, ?, NOW())`;
    await pool.query(query, [user.id_karyawan, tglPinjaman, tglBayarStr, nominal || 0, alasan || '-']);

    return res.json({ success: true, message: 'Pengajuan pinjaman berhasil disimpan.' });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.put('/api/loan/:id/status', async (req, res) => {
  return res.json({ success: true, message: `Status pinjaman tidak digunakan di skema baru.` });
});




app.get('/api/geofence', async (req, res) => {
  try {
    const activeOnly = req.query.activeOnly === 'true';
    const query = activeOnly
      ? 'SELECT * FROM tb_site WHERE is_aktif = 1 ORDER BY id_site ASC'
      : 'SELECT * FROM tb_site ORDER BY id_site ASC';
    const [rows] = await pool.query(query);

    const mapped = rows.map((r) => ({
      id: r.id_site,
      kode: r.kode_lokasi,
      nama: r.nama_site,
      latitude: r.latitude,
      longitude: r.longitude,
      radius: r.radius_meter,
      alamat: r.lokasi,
      deskripsi: r.deskripsi_lokasi,
      isAktif: r.is_aktif === 1,
      createdAt: r.created_at ? String(r.created_at).replace(' ', 'T') : new Date().toISOString(),
    }));

    return res.json({ success: true, data: mapped });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.put('/api/geofence/:id', async (req, res) => {
  const { id } = req.params;
  const { nama, latitude, longitude, radius, alamat, deskripsi, isAktif } = req.body;
  try {
    await pool.query(
      `UPDATE tb_site SET nama_site = ?, latitude = ?, longitude = ?, radius_meter = ?, lokasi = ?, deskripsi_lokasi = ?, is_aktif = ? WHERE id_site = ?`,
      [nama, latitude, longitude, radius, alamat || '', deskripsi || '', isAktif ? 1 : 0, id]
    );
    return res.json({ success: true, message: `Data lokasi geofence (${nama}) berhasil diperbarui!` });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});




app.get('/api/payslip', async (req, res) => {
  try {
    const { username } = req.query;
    let query = `
      SELECT s.*, k.nik_karyawan AS karyawan_nik, k.nik_karyawan AS karyawan_username, k.nama_karyawan AS karyawan_nama
      FROM tb_slip_gaji s
      JOIN tb_karyawan k ON s.id_karyawan = k.id_karyawan
    `;
    let params = [];

    if (username) {
      query += ' WHERE LOWER(k.nik_karyawan) = ? OR k.id_karyawan = ?';
      const cleanUser = username.toLowerCase();
      params.push(cleanUser, isNaN(cleanUser) ? 0 : Number(cleanUser));
    }
    query += ' ORDER BY s.dibuat_pada DESC';

    const [rows] = await pool.query(query, params);

    const mapped = rows.map((r) => ({
      id: r.id_slip_gaji,
      nik: r.karyawan_nik || r.karyawan_username,
      username: r.karyawan_username,
      nama: r.karyawan_nama,
      periode: r.periode,
      gajiPokok: r.gaji_pokok,
      tunjangan: r.tunjangan,
      potongan: r.potongan,
      totalDiterima: r.total_diterima,
      status: r.status_rilis,
      createdAt: r.dibuat_pada ? String(r.dibuat_pada).replace(' ', 'T') : new Date().toISOString(),
    }));

    return res.json({ success: true, data: mapped });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.post('/api/payslip', async (req, res) => {
  const { username, periode, gajiPokok, tunjangan, potongan } = req.body;
  const identifier = username || 'TJS-2024-089';

  try {
    const user = await getKaryawanByIdentifier(identifier);
    if (!user) {
      return res.status(404).json({ success: false, message: `Karyawan (${identifier}) tidak ditemukan.` });
    }

    const gPokok = Number(gajiPokok) || 0;
    const tJangan = Number(tunjangan) || 0;
    const pTongan = Number(potongan) || 0;
    const total = gPokok + tJangan - pTongan;

    const query = `INSERT INTO tb_slip_gaji (id_karyawan, periode, gaji_pokok, tunjangan, potongan, total_diterima, status_rilis, dibuat_pada) VALUES (?, ?, ?, ?, ?, ?, 'DITERBITKAN', NOW())`;
    await pool.query(query, [user.id_karyawan, periode || 'Agustus 2026', gPokok, tJangan, pTongan, total]);

    return res.json({ success: true, message: 'Slip gaji karyawan berhasil dirilis oleh HR.' });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.delete('/api/payslip/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM tb_slip_gaji WHERE id_slip_gaji = ?', [id]);
    return res.json({ success: true, message: `Slip gaji (ID: ${id}) berhasil dihapus.` });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});




app.get('/api/users', async (req, res) => {
  try {
    const [karyawan] = await pool.query(
      'SELECT id_karyawan AS id, nik_karyawan AS nik, nik_karyawan AS username, nama_karyawan AS nama, CONCAT(nik_karyawan, "@tjs.local") AS email, no_hp AS noHp, "karyawan" AS role, jabatan, "-" AS departemen, dibuat_pada FROM tb_karyawan ORDER BY id_karyawan ASC'
    );
    return res.json({ success: true, data: karyawan });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.post('/api/users', async (req, res) => {
  const { nik, nama, password, noHp, jabatan } = req.body;
  if (!nik || !nama || !password) {
    return res.status(400).json({ success: false, message: 'NIK, Nama, dan Password wajib diisi!' });
  }

  const cleanNik = nik.trim().toUpperCase();

  try {
    const [existCheck] = await pool.query(
      'SELECT nik_karyawan FROM tb_karyawan WHERE UPPER(nik_karyawan) = ?',
      [cleanNik]
    );

    if (existCheck.length > 0) {
      return res.status(400).json({ success: false, message: 'NIK sudah terdaftar.' });
    }

    const hashedPassword = bcrypt.hashSync(password, 10);
    const query = `INSERT INTO tb_karyawan (nik_karyawan, nama_karyawan, password, no_hp, jabatan, tgl_masuk, status_karyawan, dibuat_pada) VALUES (?, ?, ?, ?, ?, CURDATE(), 'AKTIF', NOW())`;
    await pool.query(query, [
      cleanNik,
      nama,
      hashedPassword,
      noHp || '',
      jabatan || '-',
    ]);

    return res.json({ success: true, message: `Akun Karyawan (${nama}) berhasil ditambahkan!` });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.delete('/api/users/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const user = await getKaryawanByIdentifier(id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'Pengguna tidak ditemukan.' });
    }

    await pool.query('DELETE FROM tb_karyawan WHERE id_karyawan = ?', [user.id_karyawan]);
    return res.json({ success: true, message: `Akun Karyawan (ID: ${user.id_karyawan}) berhasil dihapus!` });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});




app.get('/api/notifications', async (req, res) => {
  try {
    const { username } = req.query;
    let query = `
      SELECT n.*, k.nik_karyawan AS karyawan_nik, k.nik_karyawan AS karyawan_username
      FROM tb_notifikasi n
      JOIN tb_karyawan k ON n.id_karyawan = k.id_karyawan
    `;
    let params = [];

    if (username) {
      query += ' WHERE LOWER(k.nik_karyawan) = ? OR k.id_karyawan = ?';
      const cleanUser = username.toLowerCase();
      params.push(cleanUser, isNaN(cleanUser) ? 0 : Number(cleanUser));
    }
    query += ' ORDER BY n.dibuat_pada DESC';

    const [rows] = await pool.query(query, params);

    const mapped = rows.map((r) => ({
      id: r.id_notifikasi,
      judul: r.judul,
      pesan: r.pesan,
      kategori: r.kategori,
      isDibaca: r.is_dibaca === 1,
      createdAt: r.dibuat_pada ? String(r.dibuat_pada).replace(' ', 'T') : new Date().toISOString(),
    }));

    return res.json({ success: true, data: mapped });
  } catch (err) {
    return res.status(500).json({ success: false, message: err.message });
  }
});

const os = require('os');
const PORT = process.env.PORT || 3000;

function getLocalIpAddresses() {
  const interfaces = os.networkInterfaces();
  const addresses = [];
  for (const name of Object.keys(interfaces)) {
    for (const net of interfaces[name]) {
      if (net.family === 'IPv4' && !net.internal) {
        addresses.push(net.address);
      }
    }
  }
  return addresses;
}

app.listen(PORT, () => {
  const ipList = getLocalIpAddresses();
  console.log('\n===================================================================');
  console.log('🚀 BACKEND SERVER ABSENSI TJS AKTIF!');
  console.log('-------------------------------------------------------------------');
  console.log(`💻 Local PC:      http://localhost:${PORT}/api`);
  if (ipList.length > 0) {
    ipList.forEach((ip) => {
      console.log(`📱 UNTUK HP (WiFi): http://${ip}:${PORT}/api`);
    });
  } else {
    console.log(`📱 UNTUK HP:       Gunakan IP Wi-Fi Laptop Anda (port ${PORT})`);
  }
  console.log('===================================================================\n');
});
