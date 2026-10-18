import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class TimemarkService {
  static Future<File> tempelTimemark({
    required File foto,
    required DateTime waktu,
    required String namaLokasi,
    required double? latitude,
    required double? longitude,
    required double? akurasi,
  }) async {
    final bytes = await foto.readAsBytes();
    final sumber = img.decodeImage(bytes);
    if (sumber == null) {
      throw StateError('Format foto selfie tidak didukung.');
    }

    // Kamera depan menghasilkan foto mirror pada sebagian perangkat.
    // Bakar orientasi EXIF lebih dulu, lalu balik horizontal agar foto akhir
    // mengikuti posisi nyata dan tulisan timemark tetap normal.
    final berorientasi = img.bakeOrientation(sumber);
    final fotoNormal = img.flip(
      berorientasi,
      direction: img.FlipDirection.horizontal,
    );
    final bytesNormal = img.encodeJpg(fotoNormal, quality: 95);

    final codec = await ui.instantiateImageCodec(bytesNormal);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final ukuran = Size(image.width.toDouble(), image.height.toDouble());
    canvas.drawImage(image, Offset.zero, Paint());

    final skala = (image.width / 1080).clamp(0.7, 2.0).toDouble();
    final padding = 22 * skala;
    final fontSize = 26 * skala;
    final tanggal = DateFormat('dd/MM/yyyy HH:mm:ss').format(waktu);
    final koordinat = latitude != null && longitude != null
        ? '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}'
        : 'Lokasi belum tersedia';
    final akurasiTeks = akurasi == null
        ? 'Akurasi: -'
        : 'Akurasi: ±${akurasi.toStringAsFixed(0)} m';
    final lines = [
      tanggal,
      'WITA • $namaLokasi',
      koordinat,
      akurasiTeks,
    ];

    final textStyle = ui.TextStyle(
      color: const Color(0xFFFFFFFF),
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
    );
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      maxLines: lines.length,
    );
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle);
    for (var index = 0; index < lines.length; index++) {
      paragraphBuilder.addText(lines[index]);
      if (index < lines.length - 1) paragraphBuilder.addText('\n');
    }
    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: ukuran.width - padding * 2));

    final boxHeight = paragraph.height + padding * 1.5;
    final boxTop = ukuran.height - boxHeight - padding;
    final boxRect = Rect.fromLTWH(
      padding,
      boxTop,
      ukuran.width - padding * 2,
      boxHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, Radius.circular(16 * skala)),
      Paint()..color = const Color(0xCC07111F),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, Radius.circular(16 * skala)),
      Paint()
        ..color = const Color(0x99FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * skala,
    );
    canvas.drawParagraph(
        paragraph, Offset(padding * 1.5, boxTop + padding * 0.75));

    final outputImage = await recorder.endRecording().toImage(
          image.width,
          image.height,
        );
    final outputData =
        await outputImage.toByteData(format: ui.ImageByteFormat.png);
    if (outputData == null) {
      throw StateError('Gagal membuat foto timemark.');
    }

    // PNG dari foto kamera sering melebihi batas payload. Kompres hasil akhir
    // menjadi JPEG agar upload absensi stabil dan tetap menyimpan timemark.
    final renderedPng = outputData.buffer.asUint8List();
    final renderedImage = img.decodePng(renderedPng);
    if (renderedImage == null) {
      throw StateError('Gagal membaca hasil foto timemark.');
    }
    final jpegBytes = img.encodeJpg(renderedImage, quality: 88);

    final directory = await getTemporaryDirectory();
    final output = File(
      '${directory.path}/absensi_timemark_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await output.writeAsBytes(jpegBytes, flush: true);
    image.dispose();
    outputImage.dispose();
    return output;
  }
}
