import '../core/network/api_client.dart';
import 'service_error.dart';

class UserProfile {
  final String fullName;
  final String email;
  final String phone;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        fullName: (j['full_name'] ?? j['fullName'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        phone: (j['phone'] ?? '').toString(),
      );
}

class ProfileResult {
  final UserProfile? profile;
  final String? error;
  const ProfileResult({this.profile, this.error});
}

class UserService {
  UserService._();

  // GET /user/profile
  static Future<ProfileResult> getProfile() async {
    try {
      final res = await ApiClient.get('/user/profile');
      final data = res['data'];
      if (data is! Map) {
        return const ProfileResult(error: 'Respon profil tidak valid.');
      }
      return ProfileResult(
        profile: UserProfile.fromJson(Map<String, dynamic>.from(data)),
      );
    } catch (e) {
      return ProfileResult(error: pesanError(e));
    }
  }

  // PUT /user/profile -> null kalau sukses, atau pesan error
  static Future<String?> updateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    try {
      await ApiClient.put('/user/profile', data: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
      });
      return null;
    } catch (e) {
      return pesanError(e);
    }
  }

  // PUT /user/change-password -> null kalau sukses, atau pesan error
  static Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await ApiClient.put('/user/change-password', data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });
      return null;
    } catch (e) {
      return pesanError(e);
    }
  }
}