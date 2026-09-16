import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/data/model_user.dart';
import '../data/model_profil.dart';

import '../../../../core/backend/backend_provider.dart';


final profilProvider = StateNotifierProvider<ProfilNotifier, ProfilUser>((ref) {
  final notifier = ProfilNotifier(ref);

  ref.listen(authProvider, (previous, next) {
    if (next.user != null && previous?.user?.id != next.user?.id) {
      notifier.syncWithAuthUser(next.user!);
    } else if (next.user == null) {
      notifier.reset();
    }
  });

  final authState = ref.read(authProvider);
  if (authState.user != null) {
    notifier.syncWithAuthUser(authState.user!);
  }

  return notifier;
});

class ProfilNotifier extends StateNotifier<ProfilUser> {
  final ImagePicker _picker = ImagePicker();
  final Ref? _ref;

  ProfilNotifier([this._ref])
      : super(
        const ProfilUser(
            id: '-',
            nik: '-',
            nama: 'Karyawan',
            jenisKelamin: '-',
            noHp: '-',
            jabatan: '-',
            departemen: '-',
            tanggalMasuk: '-',
            statusKepegawaian: 'AKTIF',
            alamat: '-',
            gajiPokok: 0,
            namaBank: '-',
            noRek: '-',
            atasNamaRek: '-',
            notifikasiAktif: true,
          ),
        ) {
    _loadNotificationState();
  }

  Future<void> syncWithAuthUser(UserAccount user) async {
    state = state.copyWith(
      id: user.id,
      nik: user.nik,
      nama: user.nama,
      noHp: user.noHp,
      jabatan: user.jabatan,
      departemen: user.departemen,
    );

    if (user.fotoProfil != null && user.fotoProfil!.isNotEmpty) {
      try {
        final bytes = base64Decode(user.fotoProfil!);
        if (bytes.isNotEmpty) {
          state = state.copyWith(fotoProfilBytes: bytes);
          return;
        }
      } catch (_) {}
    }

    await _loadSavedFotoProfil(user.nik);
  }

  Future<void> _loadSavedFotoProfil(String nik) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<String> keysToTry = [
        if (nik.isNotEmpty && nik != '-') 'foto_profil_base64_$nik',
      ];

      for (var key in keysToTry) {
        final base64Str = prefs.getString(key);
        if (base64Str != null && base64Str.isNotEmpty) {
          final bytes = base64Decode(base64Str);
          if (bytes.isNotEmpty) {
            state = state.copyWith(fotoProfilBytes: bytes);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error _loadSavedFotoProfil: $e');
    }
  }

  void reset() {
    state = const ProfilUser(
      id: '-',
      nik: '-',
      nama: 'Karyawan',
      jenisKelamin: '-',
      noHp: '-',
      jabatan: '-',
      departemen: '-',
      tanggalMasuk: '-',
      statusKepegawaian: '-',
      alamat: '-',
      gajiPokok: 0,
      namaBank: '-',
      noRek: '-',
      atasNamaRek: '-',
    );
  }

  Future<void> _loadNotificationState() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool('notifikasi_aktif') ?? true;
    state = state.copyWith(notifikasiAktif: isActive);
    
    if (isActive) {
      NotificationService().scheduleDailyReminders();
    }
  }

  
  void updateProfil({
    required String nama,
    required String noHp,
    required String alamat,
  }) {
    state = state.copyWith(
      nama: nama,
      noHp: noHp,
      alamat: alamat,
    );
  }

  
  Future<Map<String, dynamic>?> pickFotoProfil(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final file = File(pickedFile.path);
        if (bytes.isNotEmpty) {
          return {
            'bytes': bytes,
            'file': file,
          };
        }
      }
    } catch (e) {
      debugPrint('Standard ImagePicker error: $e');
    }

    
    if (!kIsWeb && Platform.isWindows) {
      try {
        const script = r'''
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Filter = "Image Files (*.jpg;*.jpeg;*.png;*.webp)|*.jpg;*.jpeg;*.png;*.webp"
$dialog.Title = "Pilih Foto Profil"
if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    Write-Output $dialog.FileName
}
''';
        final result = await Process.run('powershell', ['-NoProfile', '-Command', script]);
        final filePath = result.stdout.toString().trim();
        if (filePath.isNotEmpty && await File(filePath).exists()) {
          final file = File(filePath);
          final bytes = await file.readAsBytes();
          return {
            'bytes': bytes,
            'file': file,
          };
        }
      } catch (err) {
        debugPrint('Windows OpenFileDialog fallback error: $err');
      }
    }

    return null;
  }

  
  Future<void> setFotoProfilBytes(Uint8List bytes, [File? file]) async {
    
    state = state.copyWith(fotoProfilBytes: bytes, fotoProfil: file);

    final base64Str = base64Encode(bytes);
    final currentNik = state.nik;

    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('foto_profil_base64_global', base64Str);
      await prefs.setString('foto_profil_base64_latest', base64Str);
      if (currentNik.isNotEmpty && currentNik != '-') {
        await prefs.setString('foto_profil_base64_$currentNik', base64Str);
      }
    } catch (e) {
      debugPrint('Error setFotoProfilBytes prefs: $e');
    }

    
    if (_ref != null) {
      final authUser = _ref!.read(authProvider).user;
      if (authUser != null) {
        _ref!.read(authProvider.notifier).updateUser(fotoProfil: base64Str);
      }
    }

    
    if (_ref != null && currentNik.isNotEmpty && currentNik != '-') {
      try {
        await _ref!.read(servicesRepositoryProvider).updateProfile({
          'nik': currentNik,
          'fotoProfil': base64Str,
        });
        debugPrint('Foto profil berhasil disimpan ke MySQL Database!');
      } catch (err) {
        debugPrint('Error sync foto to MySQL DB: $err');
      }
    }
  }

  
  Future<void> hapusFotoProfil() async {
    state = state.copyWith(clearFoto: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentNik = state.nik;
      if (currentNik.isNotEmpty && currentNik != '-') {
        await prefs.remove('foto_profil_base64_$currentNik');
        await prefs.remove('foto_profil_$currentNik');
      }
      await prefs.remove('foto_profil_base64_latest');
      await prefs.remove('foto_profil_latest');
      await prefs.remove('foto_profil_base64_global');
    } catch (_) {}
  }

  
  Future<void> toggleNotifikasi(bool status) async {
    state = state.copyWith(notifikasiAktif: status);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifikasi_aktif', status);

    final notifService = NotificationService();
    if (status) {
      await notifService.requestPermissions();
      await notifService.scheduleDailyReminders();
    } else {
      await notifService.cancelAllNotifications();
    }
  }
}

