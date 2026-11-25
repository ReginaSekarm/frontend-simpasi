import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, String> fieldErrors; // pesan per kolom (400), misalnya {'email': '...'}
  final int? retryAfterSeconds;          // hitung mundur kirim ulang OTP (200 dan 429)
  final bool needsVerification;          // registrasi: email ada tapi belum verifikasi

  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
    this.retryAfterSeconds,
    this.needsVerification = false,
  });

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final errors = <String, String>{};
      final raw = data['errors'];
      if (raw is Map) {
        raw.forEach((k, v) => errors[k.toString()] = v.toString());
      }
      final retry = data['retryAfterSeconds'];
      return ApiException(
        (data['message'] ?? 'Terjadi kesalahan pada server.').toString(),
        statusCode: e.response?.statusCode,
        fieldErrors: errors,
        retryAfterSeconds: retry is num ? retry.toInt() : null,
        needsVerification: data['needsVerification'] == true,
      );
    }
    if (e.response == null) {
      return const ApiException('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    }
    return ApiException('Terjadi kesalahan.', statusCode: e.response?.statusCode);
  }

  @override
  String toString() => message;
}