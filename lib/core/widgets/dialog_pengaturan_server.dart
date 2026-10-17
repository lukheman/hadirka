import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../network/api_config.dart';
import '../theme/app_colors.dart';
import '../utils/app_notification.dart';

class DialogPengaturanServer extends StatefulWidget {
  const DialogPengaturanServer({super.key});

  @override
  State<DialogPengaturanServer> createState() => _DialogPengaturanServerState();
}

class _DialogPengaturanServerState extends State<DialogPengaturanServer> {
  late TextEditingController _ipController;
  bool _sedangMenguji = false;
  bool? _statusKoneksi;
  String? _pesanStatus;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: ApiConfig.baseUrl);
    _ujiKoneksiAwal();
  }

  Future<void> _ujiKoneksiAwal() async {
    setState(() {
      _sedangMenguji = true;
    });
    final ok = await ApiConfig.testConnection(_ipController.text.trim());
    if (mounted) {
      setState(() {
        _sedangMenguji = false;
        _statusKoneksi = ok;
        _pesanStatus = ok
            ? 'Server MySQL Terhubung & Siap Digunakan!'
            : 'Tidak dapat terhubung. Cek Wi-Fi & IP Laptop Anda.';
      });
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _ujiKoneksiManual() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _sedangMenguji = true;
      _statusKoneksi = null;
      _pesanStatus = 'Sedang menguji koneksi ke server...';
    });

    final ok = await ApiConfig.testConnection(_ipController.text.trim());
    if (mounted) {
      setState(() {
        _sedangMenguji = false;
        _statusKoneksi = ok;
        _pesanStatus = ok
            ? 'KONEKSI BERHASIL! Server merespons.'
            : 'GAGAL TERHUBUNG! Pastikan HP & Laptop di Wi-Fi yang sama.';
      });
    }
  }

  Future<void> _simpanIP() async {
    final input = _ipController.text.trim();
    if (input.isEmpty) return;

    await ApiConfig.setCustomUrl(input);

    if (mounted) {
      Navigator.of(context).pop(true);
      AppNotification.showSuccess(context, 'IP Server berhasil disimpan: ${ApiConfig.baseUrl}');
    }
  }

  Future<void> _resetIP() async {
    await ApiConfig.resetCustomUrl();
    setState(() {
      _ipController.text = ApiConfig.baseUrl;
    });
    _ujiKoneksiManual();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.wifi,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pengaturan Server HP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Masukkan alamat server website HRD (XAMPP/Laragon atau server dev) agar HP dapat terhubung. Contoh: http://192.168.x.x/ipm-hris atau http://192.168.x.x:8000',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              
              TextFormField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: 'Alamat URL Server API',
                  hintText: 'http://192.168.x.x/ipm-hris/api',
                  prefixIcon: const Icon(LucideIcons.globe, size: 18, color: AppColors.secondary),
                  suffixIcon: IconButton(
                    icon: const Icon(LucideIcons.rotateCcw, size: 18, color: AppColors.onSurfaceVariant),
                    tooltip: 'Reset Default',
                    onPressed: _resetIP,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusKoneksi == true
                      ? AppColors.successBg
                      : (_statusKoneksi == false ? AppColors.errorBg : AppColors.surfaceContainer),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusKoneksi == true
                        ? AppColors.success
                        : (_statusKoneksi == false ? AppColors.error : AppColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    if (_sedangMenguji) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Sedang menguji koneksi server...',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                    ] else ...[
                      Icon(
                        _statusKoneksi == true
                            ? LucideIcons.checkCircle2
                            : (_statusKoneksi == false ? LucideIcons.xCircle : LucideIcons.helpCircle),
                        size: 18,
                        color: _statusKoneksi == true
                            ? AppColors.success
                            : (_statusKoneksi == false ? AppColors.error : AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _pesanStatus ?? 'Tekan "Tes Koneksi" untuk memeriksa.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusKoneksi == true
                                ? AppColors.success
                                : (_statusKoneksi == false ? AppColors.error : AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sedangMenguji ? null : _ujiKoneksiManual,
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('TES KONEKSI', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _simpanIP,
                      icon: const Icon(LucideIcons.save, size: 16),
                      label: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
