import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPayslipGenerator {
  static Future<String?> simpanKePerangkat({
    required dynamic periode,
    required dynamic nama,
    required dynamic username,
    required dynamic gajiPokok,
    required dynamic tunjangan,
    required dynamic potongan,
    required dynamic totalDiterima,
    dynamic status,
  }) async {
    final pdfBytes = await generatePdf(
      periode: periode,
      nama: nama,
      username: username,
      gajiPokok: gajiPokok,
      tunjangan: tunjangan,
      potongan: potongan,
      totalDiterima: totalDiterima,
      status: status,
    );

    final strPeriode = (periode ?? 'Periode_Gaji').toString().replaceAll(' ', '_');
    final strUsername = (username ?? 'Karyawan').toString();
    final fileName = 'Slip_Gaji_${strPeriode}_$strUsername.pdf';

    try {
      if (Platform.isAndroid) {
        
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (await downloadDir.exists()) {
          try {
            final filePath = '${downloadDir.path}/$fileName';
            final file = File(filePath);
            await file.writeAsBytes(pdfBytes);
            return filePath;
          } catch (_) {}
        }

        
        try {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            final filePath = '${extDir.path}/$fileName';
            final file = File(filePath);
            await file.writeAsBytes(pdfBytes);
            return filePath;
          }
        } catch (_) {}
      }

      
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      return filePath;
    } catch (_) {}
    return null;
  }
  static String _cleanText(dynamic text) {
    if (text == null) return '';
    return text
        .toString()
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll('•', '*')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
        .trim();
  }

  static num _parseNum(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val;
    if (val is String) return num.tryParse(val) ?? 0;
    return 0;
  }

  static String formatRupiah(dynamic number) {
    final val = _parseNum(number);
    final str = val.toInt().toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
    return 'Rp $str';
  }

  static Future<Uint8List> generatePdf({
    required dynamic periode,
    required dynamic nama,
    required dynamic username,
    required dynamic gajiPokok,
    required dynamic tunjangan,
    required dynamic potongan,
    required dynamic totalDiterima,
    dynamic status,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final strPeriode = _cleanText(periode ?? 'Periode Gaji');
    final strNama = _cleanText(nama ?? 'Karyawan');
    final strUsername = _cleanText(username ?? '-');
    final strStatus = _cleanText(status ?? 'DITERBITKAN');

    final gPokok = _parseNum(gajiPokok);
    final tJangan = _parseNum(tunjangan);
    final pTongan = _parseNum(potongan);
    final total = _parseNum(totalDiterima);

    pw.Font? ttfFont;
    pw.Font? ttfBold;
    try {
      ttfFont = await PdfGoogleFonts.robotoRegular();
      ttfBold = await PdfGoogleFonts.robotoBold();
    } catch (_) {}

    final pdf = pw.Document(
      theme: ttfFont != null
          ? pw.ThemeData.withFont(
              base: ttfFont,
              bold: ttfBold,
            )
          : null,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PT. TRIPUTRA JAYA SULTRA',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Sistem Penggajian & HR Digital (Absen TJS)',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      'SLIP GAJI RESMI',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.blue900, thickness: 1.5),
              pw.SizedBox(height: 12),

              
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Nama Karyawan', strNama),
                        pw.SizedBox(height: 4),
                        _buildInfoRow('NIK / Username', strUsername),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Periode Gaji', strPeriode),
                        pw.SizedBox(height: 4),
                        _buildInfoRow('Status Rilis', strStatus),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 18),
              pw.Text(
                'RINCIAN PENGGAJIAN',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 6),

              
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    _buildTableItem('Gaji Pokok', formatRupiah(gPokok)),
                    pw.Divider(color: PdfColors.grey200, height: 1),
                    _buildTableItem('Tunjangan Jabatan / Operasional', formatRupiah(tJangan)),
                    pw.Divider(color: PdfColors.grey200, height: 1),
                    _buildTableItem('Potongan BPJS / Pinjaman', '- ${formatRupiah(pTongan)}', isDeduction: true),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue900,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL GAJI DITERIMA (THP)',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      formatRupiah(total),
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber300,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Catatan:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        'Dokumen ini dicetak & diterbitkan secara sah oleh HR Portal Absen TJS.',
                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('Tim Manajemen HR', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
                      pw.SizedBox(height: 25),
                      pw.Container(
                        width: 90,
                        height: 1,
                        color: PdfColors.grey600,
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text('PT. Triputra Jaya Sultra', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 90,
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
        pw.Text(
          ':  $value',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
        ),
      ],
    );
  }

  static pw.Widget _buildTableItem(String label, String amount, {bool isDeduction = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 9.5,
              color: PdfColors.grey800,
            ),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: isDeduction ? PdfColors.red700 : PdfColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> unduhAtauCetakPdf({
    required dynamic periode,
    required dynamic nama,
    required dynamic username,
    required dynamic gajiPokok,
    required dynamic tunjangan,
    required dynamic potongan,
    required dynamic totalDiterima,
    dynamic status,
  }) async {
    final strPeriode = (periode ?? 'Periode_Gaji').toString().replaceAll(' ', '_');
    final strUsername = (username ?? 'Karyawan').toString();
    final fileName = 'Slip_Gaji_${strPeriode}_$strUsername.pdf';

    final pdfBytes = await generatePdf(
      periode: periode,
      nama: nama,
      username: username,
      gajiPokok: gajiPokok,
      tunjangan: tunjangan,
      potongan: potongan,
      totalDiterima: totalDiterima,
      status: status,
    );

    try {
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );
    } catch (_) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: fileName,
      );
    }
  }
}
