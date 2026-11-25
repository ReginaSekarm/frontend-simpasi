import '../core/network/api_client.dart';
import 'service_error.dart';

class AuthService {
  AuthService._();

  // Mengembalikan null kalau sukses, atau pesan error
  static Future<String?> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    try {
      final res = await ApiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        auth: false,
      );
      final token = res['token'];
      if (token is! String || token.isEmpty) return 'Respon login tidak valid.';
      await ApiClient.saveToken(token, remember: remember);
      return null;
    } catch (e) {
      return pesanError(e);
    }
  }

  static Future<String?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      await ApiClient.post(
        '/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'agreeToTerms': true,
        },
        auth: false,
      );
      return null;
    } catch (e) {
      return pesanError(e);
    }
  }

  static Future<String?> verifyOtp(String email, String otpCode) async {
    try {
      await ApiClient.post(
        '/auth/verify-otp',
        data: {'email': email, 'otpCode': otpCode},
        auth: false,
      );
      return null;
    } catch (e) {
      return pesanError(e);
    }
  }

  static Future<String?> resendOtp(
    String email, {
    String purpose = 'register',
  }) async {
    try {
      await ApiClient.post(
        '/auth/resend-otp',
        data: {
          'email': email,
          'purpose': purpose,
        },
        auth: false,
      );
      return null;
    } catch (e) {
      return pesanError(e);
    }
  }

  // Lupa kata sandi: minta backend mengirim kode OTP reset ke email.
  // Mengembalikan null kalau sukses, atau pesan error.
  static Future<String?> forgotPassword(String email) async {
    try {
      await ApiClient.post(
        '/auth/forgot-password',
        data: {'email': email},
        auth: false,
      );
      return null;
    } catch (e) {
      return pesanError(e);
    }
  }

  // Reset kata sandi setelah verifikasi OTP
  static Future<String?> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      await ApiClient.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'otpCode': otpCode,
          'newPassword': newPassword,
        },
        auth: false,
      );
      return null;
    } catch (e) {
      return pesanError(e);
    }
  }

  static Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout'); // token masuk blacklist di backend
    } catch (_) {}
    await ApiClient.clearToken();
  }
}