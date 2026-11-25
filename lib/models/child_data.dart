class ChildData {
  final int? id;
  String nama;
  String gender;
  String umur;
  String status;
  String berat;
  String tinggi;
  String kepala;
  String lila;
  String alergi;
  String tempat;
  String tanggalLahir;

  ChildData({
    this.id,
    required this.nama,
    required this.gender,
    required this.umur,
    required this.status,
    required this.berat,
    required this.tinggi,
    required this.kepala,
    required this.lila,
    this.alergi = '',
    this.tempat = '',
    this.tanggalLahir = '',
  });

  static String _pickString(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final val = json[key];
      if (val != null && val.toString().trim().isNotEmpty && val.toString().toLowerCase() != 'null') {
        return val.toString().trim();
      }
    }
    return fallback;
  }

  static String _formatNumber(dynamic raw, {String fallback = '-'}) {
    if (raw == null) return fallback;
    final str = raw.toString().trim();
    if (str.isEmpty || str.toLowerCase() == 'null') return fallback;
    return str.replaceAll('.', ',');
  }

  static String _formatBirthDate(dynamic raw) {
    if (raw == null) return '';
    final str = raw.toString().trim();
    if (str.isEmpty || str.toLowerCase() == 'null') return '';

    // Jika sudah dd/MM/yyyy
    if (str.contains('/')) return str;

    // Jika format ISO / yyyy-MM-dd
    final parsed = DateTime.tryParse(str);
    if (parsed != null) {
      final dd = parsed.day.toString().padLeft(2, '0');
      final mm = parsed.month.toString().padLeft(2, '0');
      final yyyy = parsed.year.toString();
      return '$dd/$mm/$yyyy';
    }
    return str;
  }

  static String _normalizeGender(String raw) {
    final lower = raw.toLowerCase();
    if (lower == 'p' || lower == 'perempuan' || lower == 'f' || lower == 'female') return 'P';
    if (lower == 'l' || lower == 'laki-laki' || lower == 'laki' || lower == 'm' || lower == 'male') return 'L';
    return raw.isEmpty ? 'L' : raw.substring(0, 1).toUpperCase();
  }

  factory ChildData.fromJson(Map<String, dynamic> json, {String Function(String)? hitungUmur}) {
    final rawId = json['id'] ?? json['baby_id'] ?? json['babyId'];
    final parsedId = rawId is int
        ? rawId
        : rawId != null
            ? int.tryParse(rawId.toString())
            : null;

    final tglLahir = _formatBirthDate(json['birth_date'] ?? json['birthDate'] ?? json['tanggalLahir']);
    final nama = _pickString(json, ['full_name', 'fullName', 'nama', 'name'], fallback: 'Anak');
    final gender = _normalizeGender(_pickString(json, ['gender', 'jenis_kelamin', 'jenisKelamin'], fallback: 'L'));
    final status = _pickString(json, ['status', 'nutritional_status', 'status_gizi', 'condition_note', 'conditionNote'], fallback: 'Normal');
    final alergi = _pickString(json, ['allergies', 'alergi'], fallback: '');
    final tempat = _pickString(json, ['birth_place', 'birthPlace', 'tempat'], fallback: '');

    final berat = _formatNumber(json['weight_kg'] ?? json['weightKg'] ?? json['berat']);
    final tinggi = _formatNumber(json['height_cm'] ?? json['heightCm'] ?? json['tinggi']);
    final kepala = _formatNumber(json['head_circumference_cm'] ?? json['headCircumferenceCm'] ?? json['kepala']);
    final lila = _formatNumber(json['lila_cm'] ?? json['lilaCm'] ?? json['lila']);

    final umur = _pickString(
      json,
      ['umur', 'age_label'],
      fallback: hitungUmur != null && tglLahir.isNotEmpty ? hitungUmur(tglLahir) : '-',
    );

    return ChildData(
      id: parsedId,
      nama: nama,
      gender: gender,
      umur: umur,
      status: status,
      berat: berat,
      tinggi: tinggi,
      kepala: kepala,
      lila: lila,
      alergi: alergi,
      tempat: tempat,
      tanggalLahir: tglLahir,
    );
  }
}