import '../../utils/format.dart';
import '../../utils/json_utils.dart';

class Baby {
  final int id;
  final String fullName;
  final String gender; // 'L' atau 'P'
  final DateTime birthDate;
  final double weightKg, heightCm, headCircumferenceCm, lilaCm;
  final String? conditionNote, allergies;
  final String? latestStatus; // normal / berisiko / stunting (null = belum diperiksa)

  const Baby({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.birthDate,
    required this.weightKg,
    required this.heightCm,
    required this.headCircumferenceCm,
    required this.lilaCm,
    this.conditionNote,
    this.allergies,
    this.latestStatus,
  });

  factory Baby.fromJson(Map<String, dynamic> j) => Baby(
        id: asInt(j['id'])!,
        fullName: j['full_name'] as String,
        gender: j['gender'] as String,
        birthDate: asDate(j['birth_date'])!,
        weightKg: asDouble(j['weight_kg']) ?? 0,
        heightCm: asDouble(j['height_cm']) ?? 0,
        headCircumferenceCm: asDouble(j['head_circumference_cm']) ?? 0,
        lilaCm: asDouble(j['lila_cm']) ?? 0,
        conditionNote: j['condition_note'] as String?,
        allergies: j['allergies'] as String?,
        latestStatus: j['latest_condition_status'] as String?, // diisi setelah backend ditambah (lihat daftar kekurangan)
      );

  int get ageMonths => umurBulan(birthDate);
  String get genderLabel => gender == 'L' ? 'Laki-laki' : 'Perempuan';
}

class Checkup {
  final int id;
  final int babyId;
  final int babyAgeMonths;
  final DateTime checkupDate;
  final double weightKg, heightCm;
  final double? headCircumferenceCm, lilaCm;
  final String? kaderNotes, recommendedFood, followUp;
  final String conditionStatus; // normal / berisiko / stunting
  final DateTime? nextCheckupDate;

  const Checkup({
    required this.id,
    required this.babyId,
    required this.babyAgeMonths,
    required this.checkupDate,
    required this.weightKg,
    required this.heightCm,
    this.headCircumferenceCm,
    this.lilaCm,
    this.kaderNotes,
    this.recommendedFood,
    this.followUp,
    required this.conditionStatus,
    this.nextCheckupDate,
  });

  factory Checkup.fromJson(Map<String, dynamic> j) => Checkup(
        id: asInt(j['id'])!,
        babyId: asInt(j['baby_id'])!,
        babyAgeMonths: asInt(j['baby_age_months']) ?? 0,
        checkupDate: asDate(j['checkup_date'])!,
        weightKg: asDouble(j['weight_kg']) ?? 0,
        heightCm: asDouble(j['height_cm']) ?? 0,
        headCircumferenceCm: asDouble(j['head_circumference_cm']),
        lilaCm: asDouble(j['lila_cm']),
        kaderNotes: j['kader_notes'] as String?,
        recommendedFood: j['recommended_food'] as String?,
        followUp: j['follow_up'] as String?,
        conditionStatus: j['condition_status'] as String,
        nextCheckupDate: asDate(j['next_checkup_date']),
      );

  /// 'Ikan, Seafood, Telur' -> ['Ikan', 'Seafood', 'Telur'] (untuk chip)
  List<String> get foodChips => (recommendedFood ?? '')
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}