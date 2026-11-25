import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/token_utils.dart';

class AuthRepository {
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required bool agreeToTerms,
  }) async {
    await ApiClient.post('/auth/register', auth: false, data: {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'password': password,
      'agreeToTerms': agreeToTerms,
    });
  }

  Future<void> verifyOtp(String email, String otpCode) async {
    await ApiClient.post('/auth/verify-otp',
        auth: false, data: {'email': email.trim(), 'otpCode': otpCode});
  }

  /// Mengembalikan jeda (detik) sebelum boleh minta kode lagi.
  Future<int> resendOtp(String email) async {
    final res = await ApiClient.post('/auth/resend-otp',
        auth: false, data: {'email': email.trim()});
    return (res['retryAfterSeconds'] as num?)?.toInt() ?? 60;
  }

  Future<void> login(String email, String password) async {
    final res = await ApiClient.post('/auth/login',
        auth: false, data: {'email': email.trim(), 'password': password});
    final token = res['token'] as String;

    // aplikasi mobile khusus orang tua; kader memakai website
    if (TokenUtils.decode(token)?.role != 'user') {
      throw const ApiException('Akun ini adalah akun kader. Silakan masuk melalui website Posyandu.');
    }
    await ApiClient.saveToken(token);
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout'); // mencabut token di server
    } catch (_) {/* tetap keluar walau gagal */}
    await ApiClient.clearToken();
  }

  Future<int> forgotPassword(String email) async {
    final res = await ApiClient.post('/auth/forgot-password',
        auth: false, data: {'email': email.trim()});
    return (res['retryAfterSeconds'] as num?)?.toInt() ?? 60;
  }

  Future<int> resendForgotPassword(String email) async {
    final res = await ApiClient.post('/auth/forgot-password/resend',
        auth: false, data: {'email': email.trim()});
    return (res['retryAfterSeconds'] as num?)?.toInt() ?? 60;
  }

  Future<void> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await ApiClient.post('/auth/reset-password', auth: false, data: {
      'email': email.trim(),
      'otpCode': otpCode,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }

  /// Untuk splash: ada token, belum kedaluwarsa, dan role user.
  Future<bool> hasValidSession() async {
    final info = await TokenUtils.current();
    if (info == null || info.isExpired || info.role != 'user') {
      await ApiClient.clearToken();
      return false;
    }
    return true;
  }
}