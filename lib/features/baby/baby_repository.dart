import '../../core/network/api_client.dart';
import '../../utils/json_utils.dart';
import 'baby_model.dart';

class BabyRepository {
  Future<List<Baby>> list() async =>
      dataList(await ApiClient.get('/babies')).map(Baby.fromJson).toList();

  Map<String, dynamic> _body({
    required String fullName,
    required String gender,
    required DateTime birthDate,
    required double weightKg,
    required double heightCm,
    required double headCircumferenceCm,
    required double lilaCm,
    String? conditionNote,
  }) =>
      {
        'fullName': fullName.trim(),
        'gender': gender, // 'L' / 'P'
        'birthDate': isoDate(birthDate),
        'weightKg': weightKg,
        'heightCm': heightCm,
        'headCircumferenceCm': headCircumferenceCm,
        'lilaCm': lilaCm,
        'conditionNote': conditionNote,
      };

  Future<void> create({
    required String fullName,
    required String gender,
    required DateTime birthDate,
    required double weightKg,
    required double heightCm,
    required double headCircumferenceCm,
    required double lilaCm,
    String? conditionNote,
  }) async {
    await ApiClient.post('/babies',
        data: _body(
          fullName: fullName, gender: gender, birthDate: birthDate, weightKg: weightKg,
          heightCm: heightCm, headCircumferenceCm: headCircumferenceCm,
          lilaCm: lilaCm, conditionNote: conditionNote,
        ));
  }

  Future<void> update(
    int id, {
    required String fullName,
    required String gender,
    required DateTime birthDate,
    required double weightKg,
    required double heightCm,
    required double headCircumferenceCm,
    required double lilaCm,
    String? conditionNote,
  }) async {
    await ApiClient.put('/babies/$id',
        data: _body(
          fullName: fullName, gender: gender, birthDate: birthDate, weightKg: weightKg,
          heightCm: heightCm, headCircumferenceCm: headCircumferenceCm,
          lilaCm: lilaCm, conditionNote: conditionNote,
        ));
  }

  Future<void> remove(int id) async {
    await ApiClient.delete('/babies/$id');
  }

  Future<List<Checkup>> checkups(int babyId) async =>
      dataList(await ApiClient.get('/babies/$babyId/checkups')).map(Checkup.fromJson).toList();
}