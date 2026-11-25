import '../core/network/api_client.dart';
import 'service_error.dart';

// ================= MODEL MENU (hasil urai teks AI) =================
// Format dari backend:
//   Nama Menu: ...
//   Bahan-bahan:
//   - ...
//   Cara Membuat:
//   1. ...
//   Tips Penting: ...
class AiMenu {
  final String nama;
  final List<String> bahan;
  final List<String> langkah;
  final List<String> tips;
  final String mentah;

  const AiMenu({
    required this.nama,
    required this.bahan,
    required this.langkah,
    required this.tips,
    required this.mentah,
  });

  bool get terbaca => nama.isNotEmpty || bahan.isNotEmpty || langkah.isNotEmpty;

  static final _headNama = RegExp(r'^nama\s*menu\s*:\s*(.*)$', caseSensitive: false);
  static final _headBahan =
      RegExp(r'^bahan(?:\s*-?\s*bahan)?\s*:\s*(.*)$', caseSensitive: false);
  static final _headCara =
      RegExp(r'^cara\s*(?:membuat|pembuatan)\s*:\s*(.*)$', caseSensitive: false);
  static final _headTips =
      RegExp(r'^tips(?:\s*penting)?\s*:\s*(.*)$', caseSensitive: false);
  static final _penandaBaris = RegExp(r'^(?:[-•]\s*|\d+\s*[.)]\s*)');

  static String _isi(String s) => s.replaceFirst(_penandaBaris, '').trim();

  factory AiMenu.parse(String teks) {
    String nama = '';
    final bahan = <String>[];
    final langkah = <String>[];
    final tips = <String>[];
    String bagian = '';

    void tambah(String isi) {
      if (isi.isEmpty) return;
      if (bagian == 'bahan') {
        bahan.add(isi);
      } else if (bagian == 'cara') {
        langkah.add(isi);
      } else if (bagian == 'tips') {
        tips.add(isi);
      }
    }

    for (final mentahBaris in teks.split('\n')) {
      // buang penanda markdown (**, #, `)
      final baris = mentahBaris.replaceAll(RegExp(r'[*#`]'), '').trim();
      if (baris.isEmpty) continue;

      final mNama = _headNama.firstMatch(baris);
      if (mNama != null) {
        nama = mNama.group(1)!.trim();
        bagian = 'nama';
        continue;
      }
      final mBahan = _headBahan.firstMatch(baris);
      if (mBahan != null) {
        bagian = 'bahan';
        tambah(_isi(mBahan.group(1)!));
        continue;
      }
      final mCara = _headCara.firstMatch(baris);
      if (mCara != null) {
        bagian = 'cara';
        tambah(_isi(mCara.group(1)!));
        continue;
      }
      final mTips = _headTips.firstMatch(baris);
      if (mTips != null) {
        bagian = 'tips';
        tambah(_isi(mTips.group(1)!));
        continue;
      }

      // baris isi biasa
      final isi = _isi(baris);
      if (bagian == 'nama' && nama.isEmpty) {
        nama = isi; // nama menu ada di baris berikutnya
      } else {
        tambah(isi);
      }
    }

    return AiMenu(
      nama: nama,
      bahan: bahan,
      langkah: langkah,
      tips: tips,
      mentah: teks.replaceAll(RegExp(r'[*#`]'), '').trim(),
    );
  }
}

// ================= MODEL HASIL =================
class AiRecommendResult {
  final String? text;
  final String? kondisi;
  final int? historyId;
  final String? error;
  const AiRecommendResult({this.text, this.kondisi, this.historyId, this.error});
}

class AiHistoryItem {
  final int id;
  final String bahan;
  final String response;
  final DateTime? createdAt;
  final AiMenu menu;

  const AiHistoryItem({
    required this.id,
    required this.bahan,
    required this.response,
    required this.createdAt,
    required this.menu,
  });

  String get menuTitle => menu.nama.isNotEmpty ? menu.nama : '-';

  // Riwayat lama menyimpan seluruh prompt di kolom query; ambil bagian bahannya saja.
  // Riwayat baru langsung berisi bahan yang diketik user.
  static String _bahanDariQuery(String query) {
    final m = RegExp(r'Bahan makanan yang tersedia di rumah:\s*([^\n]*)').firstMatch(query);
    final hasil = (m != null ? m.group(1)! : query).trim();
    return hasil.isEmpty ? '-' : hasil;
  }

  factory AiHistoryItem.fromJson(Map<String, dynamic> j) {
    final query = (j['query'] ?? '').toString();
    final response = (j['response'] ?? '').toString();
    return AiHistoryItem(
      id: int.tryParse('${j['id']}') ?? 0,
      bahan: _bahanDariQuery(query),
      response: response,
      createdAt: DateTime.tryParse('${j['created_at'] ?? ''}')?.toLocal(),
      menu: AiMenu.parse(response),
    );
  }
}

class AiHistoryResult {
  final List<AiHistoryItem> items;
  final String? error;
  const AiHistoryResult({this.items = const [], this.error});
}

class AiHistoryDetailResult {
  final AiHistoryItem? item;
  final String? error;
  const AiHistoryDetailResult({this.item, this.error});
}

class BabyIdResult {
  final int? id;
  final String? error;
  const BabyIdResult({this.id, this.error});
}

// ================= SERVICE =================
class AiService {
  AiService._();

  // Cari id anak berdasarkan nama (dipakai kalau layar dibuka tanpa id anak)
  static Future<BabyIdResult> cariBabyId(String nama) async {
    try {
      final res = await ApiClient.get('/babies');
      final data = res['data'];
      final list = data is List ? data : const [];
      final target = nama.trim().toLowerCase();

      int? found;
      for (final e in list) {
        if (e is! Map) continue;
        final nm = '${e['full_name'] ?? e['fullName'] ?? ''}'.trim().toLowerCase();
        if (nm == target) {
          found = int.tryParse('${e['id']}');
          break;
        }
      }
      // hanya punya satu anak -> pakai anak itu
      if (found == null && list.length == 1 && list.first is Map) {
        found = int.tryParse('${(list.first as Map)['id']}');
      }
      if (found == null) {
        return BabyIdResult(error: 'Data anak "$nama" tidak ditemukan di akun ini.');
      }
      return BabyIdResult(id: found);
    } catch (e) {
      return BabyIdResult(error: pesanError(e));
    }
  }

  // POST /ai/recommend-menu
  static Future<AiRecommendResult> rekomendasi({
    required int babyId,
    required String bahan,
    String alergi = '',
  }) async {
    try {
      final res = await ApiClient.post('/ai/recommend-menu', data: {
        'babyId': babyId,
        'availableIngredients': bahan,
        'allergies': alergi, // string kosong = alergi dihapus
      });
      final data = res['data'];
      if (data is! Map) {
        return const AiRecommendResult(error: 'Respon AI tidak valid.');
      }
      final text = (data['recommendation'] ?? '').toString();
      if (text.trim().isEmpty) {
        return const AiRecommendResult(error: 'AI tidak memberikan jawaban. Coba lagi.');
      }
      return AiRecommendResult(
        text: text,
        kondisi: data['conditionStatus']?.toString(),
        historyId: int.tryParse('${data['historyId']}'),
      );
    } catch (e) {
      return AiRecommendResult(error: pesanError(e));
    }
  }

  // GET /ai/history
  static Future<AiHistoryResult> riwayat() async {
    try {
      final res = await ApiClient.get('/ai/history');
      final data = res['data'];
      final list = data is List ? data : const [];
      final items = <AiHistoryItem>[];
      for (final e in list) {
        if (e is Map) items.add(AiHistoryItem.fromJson(Map<String, dynamic>.from(e)));
      }
      return AiHistoryResult(items: items);
    } catch (e) {
      return AiHistoryResult(error: pesanError(e));
    }
  }

  // GET /ai/history/:id
  static Future<AiHistoryDetailResult> detailRiwayat(int id) async {
    try {
      final res = await ApiClient.get('/ai/history/$id');
      final data = res['data'];
      if (data is! Map) {
        return const AiHistoryDetailResult(error: 'Riwayat tidak ditemukan.');
      }
      return AiHistoryDetailResult(
        item: AiHistoryItem.fromJson(Map<String, dynamic>.from(data)),
      );
    } catch (e) {
      return AiHistoryDetailResult(error: pesanError(e));
    }
  }

  // DELETE /ai/history/:id -> null kalau sukses, atau pesan error
  static Future<String?> hapusRiwayat(int id) async {
    try {
      await ApiClient.delete('/ai/history/$id');
      return null;
    } catch (e) {
      return pesanError(e);
    }
  }
}