import '../core/network/api_exception.dart';

/// Pesan error yang aman ditampilkan ke pengguna.
String pesanError(Object e) {
  if (e is ApiException) {
    final dynamic err = e;
    try {
      final m = err.message;
      if (m != null && m.toString().trim().isNotEmpty) return m.toString();
    } catch (_) {}
  }
  return 'Terjadi kesalahan. Silakan coba lagi.';
}