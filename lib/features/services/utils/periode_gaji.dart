String formatPeriodeGaji(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return 'Periode Gaji';

  final firstPart = raw.split(RegExp(r'\s+-\s+')).first.trim();
  final dateMatch =
      RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(firstPart);
  if (dateMatch != null) {
    return _namaBulan(int.parse(dateMatch.group(2)!)) +
        ' ${dateMatch.group(3)}';
  }

  final isoMatch = RegExp(r'^(\d{4})-(\d{1,2})-\d{1,2}').firstMatch(firstPart);
  if (isoMatch != null) {
    return _namaBulan(int.parse(isoMatch.group(2)!)) + ' ${isoMatch.group(1)}';
  }

  final normalized = firstPart.replaceAll(RegExp(r'\s+'), ' ');
  final monthYear = RegExp(
    r'^(Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember)\s+(\d{4})$',
    caseSensitive: false,
  ).firstMatch(normalized);
  if (monthYear != null) {
    return '${_kapitalisasi(monthYear.group(1)!)} ${monthYear.group(2)}';
  }

  return normalized;
}

String _namaBulan(int bulan) {
  const nama = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return bulan >= 1 && bulan <= 12 ? nama[bulan - 1] : 'Periode Gaji';
}

String _kapitalisasi(String value) {
  final lower = value.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}
