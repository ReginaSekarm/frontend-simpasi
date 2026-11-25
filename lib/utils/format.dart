const _bulan = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
];

String formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

/// 3.4 -> '3,4'   |   13.0 -> '13'
String formatAngka(num? n) {
  if (n == null) return '-';
  return n % 1 == 0 ? n.toInt().toString() : n.toString().replaceAll('.', ',');
}

int umurBulan(DateTime lahir, [DateTime? sekarang]) {
  final now = sekarang ?? DateTime.now();
  var bulan = (now.year - lahir.year) * 12 + (now.month - lahir.month);
  if (now.day < lahir.day) bulan -= 1;
  return bulan < 0 ? 0 : bulan;
}

/// '2 jam lalu', '3 hari lalu', dst.
String timeAgo(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 30) return '${diff.inDays} hari lalu';
  return formatTanggal(t);
}