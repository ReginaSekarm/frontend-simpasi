import 'package:flutter/material.dart';

/// Store global untuk menyimpan anak yang sedang aktif dipilih.
/// Dipakai lintas halaman (Home, Menu, Koleksi, dll).
class ChildStore {
  ChildStore._();

  /// Nama anak yang sedang aktif. Default kosong.
  static final ValueNotifier<String> currentName =
      ValueNotifier<String>('');

  /// ID anak yang sedang aktif. Default null.
  /// Dipakai untuk memilih anak secara akurat (lebih andal daripada nama).
  static final ValueNotifier<int?> currentId =
      ValueNotifier<int?>(null);

  /// Set anak aktif (dipanggil dari Home saat switch/tambah).
  /// Sertakan [id] jika tersedia agar halaman lain memilih anak yang tepat.
  static void setCurrent(String name, {int? id}) {
    currentName.value = name;
    currentId.value = id;
  }

  /// Reset (misal ketika semua anak dihapus).
  static void clear() {
    currentName.value = '';
    currentId.value = null;
  }
}