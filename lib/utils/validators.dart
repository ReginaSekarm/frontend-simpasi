final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validateEmail(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Email wajib diisi';
  if (!_emailRegex.hasMatch(s)) return 'Format email tidak valid';
  return null;
}

String? validatePhone(String? v) {
  final s = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
  if (s.isEmpty) return 'Nomor HP wajib diisi';
  if (!RegExp(r'^\+?\d+$').hasMatch(s)) return 'Nomor HP hanya boleh berisi angka';
  final digits = s.replaceAll('+', '').length;
  if (digits < 10) return 'Nomor HP minimal 10 digit';
  if (digits > 15) return 'Nomor HP maksimal 15 digit';
  return null;
}

String? validatePassword(String? v) {
  final s = v ?? '';
  if (s.length < 8 || !RegExp(r'[A-Z]').hasMatch(s) || !RegExp(r'\d').hasMatch(s)) {
    return 'Kata sandi minimal 8 karakter, 1 huruf besar, dan 1 angka';
  }
  return null;
}