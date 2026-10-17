<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = "localhost";
$user = "root";
$pass = "";
$db   = "db_absen_tjs";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    echo json_encode(["success" => false, "message" => "Koneksi XAMPP MySQL Gagal: " . $conn->connect_error]);
    exit();
}

$action = isset($_GET['action']) ? $_GET['action'] : '';
$input = json_decode(file_get_contents('php://input'), true);

switch ($action) {
    case 'login':
        $identifier = strtolower(trim($input['identifier'] ?? ''));
        $password = $input['password'] ?? '';

        $stmt = $conn->prepare("SELECT * FROM tb_karyawan WHERE LOWER(nik_karyawan) = ?");
        $stmt->bind_param("s", $identifier);
        $stmt->execute();
        $res = $stmt->get_result();

        if ($res->num_rows > 0) {
            $u = $res->fetch_assoc();
            
            // Verifikasi password (Bcrypt)
            if (password_verify($password, $u['password']) || $u['password'] === $password) {
                echo json_encode([
                    "success" => true,
                    "user" => [
                        "id" => (int)$u['id_karyawan'], 
                        "nik" => $u['nik_karyawan'], 
                        "nama" => $u['nama_karyawan'],
                        "role" => 'karyawan',
                        "jabatan" => $u['jabatan'], 
                        "status" => $u['status_karyawan'],
                        "token" => "token_karyawan_" . time()
                    ]
                ]);
                exit();
            } else {
                echo json_encode(["success" => false, "message" => "Password yang Anda masukkan salah."]);
                exit();
            }
        }
        echo json_encode(["success" => false, "message" => "NIK Karyawan tidak terdaftar di sistem."]);
        break;

    case 'attendance_get':
        $sql = "SELECT a.*, k.nik_karyawan AS karyawan_nik, k.nama_karyawan AS karyawan_nama 
                FROM tb_absen a 
                JOIN tb_karyawan k ON a.id_karyawan = k.id_karyawan 
                ORDER BY a.dibuat_pada DESC";
        $res = $conn->query($sql);
        $data = [];
        if ($res) {
            while ($r = $res->fetch_assoc()) {
                $data[] = [
                    "id" => (int)$r['id'], 
                    "nik" => $r['karyawan_nik'], 
                    "nama" => $r['karyawan_nama'],
                    "tanggal" => $r['tanggal_absen'], 
                    "waktuIn" => $r['waktu_masuk'], 
                    "waktuOut" => $r['waktu_keluar'],
                    "lokasiNama" => $r['nama_lokasi'], 
                    "latitude" => (float)$r['latitude'], 
                    "longitude" => (float)$r['longitude'],
                    "jarakMeter" => (float)$r['jarak_meter'], 
                    "status" => $r['status_kehadiran'], 
                    "keterlambatanMenit" => (int)$r['keterlambatan_menit'],
                    "isTepat" => $r['is_tepat_waktu'] == 1, 
                    "fotoPath" => $r['foto_selfie_path']
                ];
            }
        }
        echo json_encode(["success" => true, "data" => $data]);
        break;

    case 'leave_get':
        $sql = "SELECT p.*, k.nik_karyawan AS karyawan_nik, k.nama_karyawan AS karyawan_nama FROM tb_pengajuan p JOIN tb_karyawan k ON p.id_karyawan = k.id_karyawan ORDER BY p.dibuat_pada DESC";
        $res = $conn->query($sql);
        $data = [];
        if ($res) {
            while ($r = $res->fetch_assoc()) {
                $data[] = [
                    "id" => (int)$r['id_pengajuan'], 
                    "nik" => $r['karyawan_nik'], 
                    "nama" => $r['karyawan_nama'],
                    "jenis" => $r['jenis_pengajuan'], 
                    "tanggal" => $r['rentang_tanggal'], 
                    "alasan" => $r['alasan_pengajuan'],
                    "status" => $r['status_approval'], 
                    "lampiranPath" => $r['lampiran_path'],
                    "dibuat_pada" => $r['dibuat_pada'],
                    "createdAt" => str_replace(' ', 'T', $r['dibuat_pada'])
                ];
            }
        }
        echo json_encode(["success" => true, "data" => $data]);
        break;

    case 'geofence_get':
        $res = $conn->query("SELECT * FROM tb_site ORDER BY id_site ASC");
        $data = [];
        if ($res) {
            while ($r = $res->fetch_assoc()) {
                $data[] = [
                    "id" => (int)$r['id_site'], 
                    "kode" => $r['kode_lokasi'],
                    "nama" => $r['nama_site'], 
                    "latitude" => (float)$r['latitude'],
                    "longitude" => (float)$r['longitude'], 
                    "radius" => (float)$r['radius_meter'],
                    "alamat" => $r['lokasi'], 
                    "deskripsi" => $r['deskripsi_lokasi'],
                    "isAktif" => (int)$r['is_aktif'] === 1,
                    "createdAt" => str_replace(' ', 'T', $r['created_at'])
                ];
            }
        }
        echo json_encode(["success" => true, "data" => $data]);
        break;

    case 'loan_get':
        $sql = "SELECT p.*, k.nik_karyawan AS karyawan_nik, k.nama_karyawan AS karyawan_nama FROM tb_pinjaman p JOIN tb_karyawan k ON p.id_karyawan = k.id_karyawan ORDER BY p.created_at DESC";
        $res = $conn->query($sql);
        $data = [];
        if ($res) {
            while ($r = $res->fetch_assoc()) {
                $data[] = [
                    "id" => (int)$r['id_pinjaman'], 
                    "nik" => $r['karyawan_nik'], 
                    "nama" => $r['karyawan_nama'],
                    "nominal" => (float)$r['nominal_pinjaman'], 
                    "tenor" => 0, 
                    "angsuran" => 0,
                    "alasan" => $r['ket_pinjaman'], 
                    "status" => 'DISETUJUI',
                    "tgl_pinjaman" => $r['tgl_pinjaman'],
                    "tgl_bayar" => $r['tgl_bayar_pinjaman']
                ];
            }
        }
        echo json_encode(["success" => true, "data" => $data]);
        break;

    case 'users_get':
        $resK = $conn->query("SELECT id_karyawan AS id, nik_karyawan AS nik, nama_karyawan AS nama, jabatan FROM tb_karyawan ORDER BY id_karyawan ASC");
        $data = [];
        if ($resK) {
            while ($r = $resK->fetch_assoc()) { 
                $r['id'] = (int)$r['id'];
                $r['role'] = 'karyawan';
                $data[] = $r; 
            }
        }
        echo json_encode(["success" => true, "data" => $data]);
        break;

    default:
        echo json_encode(["success" => true, "message" => "XAMPP MySQL Native PHP API Relational Aktif."]);
        break;
}

$conn->close();
?>
