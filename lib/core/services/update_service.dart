import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static String? get _versionUrl => dotenv.env['UPDATE_VERSION_URL'];

  static Future<void> check(BuildContext context) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;

    final versionUrl = _versionUrl;
    final parsedVersionUrl =
        versionUrl == null ? null : Uri.tryParse(versionUrl);
    if (parsedVersionUrl == null || parsedVersionUrl.scheme != 'https') {
      debugPrint(
          'Cek update dilewati: UPDATE_VERSION_URL harus memakai HTTPS.');
      return;
    }

    try {
      final response =
          await http.get(parsedVersionUrl).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return;

      final serverCode = _readVersionCode(decoded['version_code']);
      final apkUrl = decoded['apk_url'];
      if (serverCode == null || apkUrl is! String || apkUrl.isEmpty) return;

      final info = await PackageInfo.fromPlatform();
      final currentCode = int.tryParse(info.buildNumber);
      if (currentCode == null ||
          serverCode <= currentCode ||
          !context.mounted) {
        return;
      }

      _showUpdateDialog(context, decoded, apkUrl);
    } catch (error) {
      debugPrint('Cek update gagal: $error');
    }
  }

  static int? _readVersionCode(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static void _showUpdateDialog(
    BuildContext context,
    Map<String, dynamic> data,
    String apkUrl,
  ) {
    final force = data['force'] == true;
    final versionName = data['version_name']?.toString() ?? 'baru';
    final notes = data['notes']?.toString() ?? 'Versi baru siap diunduh.';

    showDialog<void>(
      context: context,
      barrierDismissible: !force,
      builder: (dialogContext) => PopScope(
        canPop: !force,
        child: AlertDialog(
          title: Text('Update $versionName tersedia'),
          content: Text(notes),
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Nanti'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showDownloadDialog(context, apkUrl);
              },
              child: const Text('Update Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showDownloadDialog(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DownloadDialog(url: url),
    );
  }
}

class _DownloadDialog extends StatefulWidget {
  const _DownloadDialog({required this.url});

  final String url;

  @override
  State<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<_DownloadDialog> {
  CancelToken? _cancelToken;
  double _progress = 0;
  String _status = 'Memulai unduhan...';
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    setState(() {
      _error = false;
      _progress = 0;
      _status = 'Memulai unduhan...';
    });

    _download();
  }

  Future<void> _download() async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/app-update.apk';
      final file = File(filePath);
      if (await file.exists()) await file.delete();

      await Dio().download(
        widget.url,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (!mounted || total <= 0) return;
          setState(() {
            _progress = (received / total).clamp(0, 1).toDouble();
            _status = 'Mengunduh... ${(_progress * 100).round()}%';
          });
        },
        options: Options(
          headers: const {'Accept': 'application/vnd.android.package-archive'},
          followRedirects: true,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );

      if (!mounted) return;
      setState(() => _status = 'Membuka installer...');
      final result = await OpenFilex.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );
      if (!mounted || result.type == ResultType.done) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      setState(() {
        _error = true;
        _status = 'Gagal membuka installer: ${result.message}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _status = 'Terjadi kesalahan: $error';
      });
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mengunduh Update'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _error ? 0 : _progress),
          const SizedBox(height: 12),
          Text(_status),
        ],
      ),
      actions: [
        if (_error) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(onPressed: _start, child: const Text('Coba Lagi')),
        ],
      ],
    );
  }
}
