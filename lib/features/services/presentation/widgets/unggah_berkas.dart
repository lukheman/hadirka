import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class UnggahBerkas extends StatefulWidget {
  final Function(File?)? onFileSelected;

  const UnggahBerkas({super.key, this.onFileSelected});

  @override
  State<UnggahBerkas> createState() => _UnggahBerkasState();
}

class _UnggahBerkasState extends State<UnggahBerkas> {
  File? _selectedFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
        });
        if (widget.onFileSelected != null) {
          widget.onFileSelected!(_selectedFile);
        }
      }
    } catch (_) {}
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
    if (widget.onFileSelected != null) {
      widget.onFileSelected!(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedFile != null) {
      final fileName = _selectedFile!.path.split('/').last.split('\\').last;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.successBg.withOpacity(0.6),
          border:
              Border.all(color: AppColors.success.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Dokumen berhasil dilampirkan',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _removeFile,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  'HAPUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border:
              Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.uploadCloud,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unggah Lampiran Dokumen (Opsional)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Foto Surat Sakit (SKS) / Berkas pendukung (JPG, PNG)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(LucideIcons.paperclip, size: 16),
              label: const Text('PILIH DOKUMEN',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
