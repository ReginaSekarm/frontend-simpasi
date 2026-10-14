import 'package:flutter/material.dart';

/// Store global untuk menyimpan anak yang sedang aktif dipilih.
/// Dipakai lintas halaman (Home, Menu, Koleksi, dll).
class ChildStore {
  ChildStore._();

  /// Nama anak yang sedang aktif. Default kosong.
  static final ValueNotifier<String> currentName =
      ValueNotifier<String>('');

  /// Set nama anak aktif (dipanggil dari Home saat switch/tambah).
  static void setCurrent(String name) {
    currentName.value = name;
  }

  /// Reset (misal ketika semua anak dihapus).
  static void clear() {
    currentName.value = '';
  }
}