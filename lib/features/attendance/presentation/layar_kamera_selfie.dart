import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';

class LayarKameraSelfie extends StatefulWidget {
  const LayarKameraSelfie({super.key});

  @override
  State<LayarKameraSelfie> createState() => _LayarKameraSelfieState();
}

class _LayarKameraSelfieState extends State<LayarKameraSelfie> {
  CameraController? _controller;
  String? _error;
  bool _siap = false;
  bool _mengambilFoto = false;

  @override
  void initState() {
    super.initState();
    _siapkanKamera();
  }

  Future<void> _siapkanKamera() async {
    try {
      final cameras = await availableCameras();
      final kameraDepan = cameras.firstWhere(
        (kamera) => kamera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        kameraDepan,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _siap = true;
      });
    } on CameraException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.description ?? error.code;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _ambilFoto() async {
    final controller = _controller;
    if (controller == null || !_siap || _mengambilFoto) return;
    setState(() => _mengambilFoto = true);
    try {
      final foto = await controller.takePicture();
      if (mounted) Navigator.of(context).pop(File(foto.path));
    } on CameraException catch (error) {
      if (mounted) {
        setState(() {
          _mengambilFoto = false;
          _error = error.description ?? error.code;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Foto Selfie Absensi'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(LucideIcons.x),
            tooltip: 'Batal',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: controller != null && controller.value.isInitialized
                  ? _buildPreview(controller)
                  : Center(
                      child: _error == null
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Kamera tidak dapat dibuka.\n$_error',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
              color: Colors.black,
              child: Column(
                children: [
                  const Text(
                    'Pastikan wajah terlihat jelas dan pencahayaan cukup.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _ambilFoto,
                    child: Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _siap ? AppColors.primary : Colors.white38,
                          shape: BoxShape.circle,
                        ),
                        child: _mengambilFoto
                            ? const Padding(
                                padding: EdgeInsets.all(18),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(LucideIcons.camera,
                                color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(CameraController controller) {
    return Center(
      // CameraPreview sudah memiliki AspectRatio dan rotasi orientasi sendiri.
      // Jangan bungkus lagi dengan AspectRatio controller.value.aspectRatio;
      // kamera portrait memakai rasio kebalikan sehingga gambar bisa gepeng.
      child: CameraPreview(controller),
    );
  }
}
