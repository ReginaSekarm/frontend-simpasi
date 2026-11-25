double? asDouble(dynamic v) {
  if (v == null) return null;
  return v is num ? v.toDouble() : double.tryParse(v.toString());
}

int? asInt(dynamic v) {
  if (v == null) return null;
  return v is num ? v.toInt() : int.tryParse(v.toString());
}

bool asBool(dynamic v) => v == true || v == 1 || v == '1';

DateTime? asDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString())?.toLocal();
}

/// DateTime -> 'YYYY-MM-DD' (format tanggal yang diterima backend)
String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

List<Map<String, dynamic>> dataList(Map<String, dynamic> res) =>
    ((res['data'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();