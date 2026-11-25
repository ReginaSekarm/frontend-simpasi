import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._();

  static const baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:5000/api');

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'simpasi_token';

  // Token di memori: dipakai kalau "Ingat Saya" tidak dicentang (hilang saat aplikasi ditutup)
  static String? _memoryToken;

  /// Dipanggil saat token ditolak/kedaluwarsa. Diisi di app untuk mengarahkan ke login.
  static void Function()? onSessionExpired;

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 60), // rekomendasi AI bisa 10 detik lebih
    headers: {'Content-Type': 'application/json'},
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.extra['auth'] != false) {
          final token = await getToken();
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        final status = e.response?.statusCode;
        final data = e.response?.data;
        final msg = data is Map ? (data['message'] ?? '').toString() : '';
        final usedAuth = e.requestOptions.extra['auth'] != false;
        final expired = usedAuth &&
            (status == 401 ||
                (status == 403 && RegExp('sesi|token', caseSensitive: false).hasMatch(msg)));
        if (expired) {
          await clearToken();
          onSessionExpired?.call();
        }
        handler.next(e);
      },
    ));

  static Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool auth = true,
  }) async {
    try {
      final res = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method, extra: {'auth': auth}),
      );
      final body = res.data;
      return body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  static Future<Map<String, dynamic>> get(String path,
          {Map<String, dynamic>? query, bool auth = true}) =>
      _send('GET', path, query: query, auth: auth);

  static Future<Map<String, dynamic>> post(String path, {Object? data, bool auth = true}) =>
      _send('POST', path, data: data, auth: auth);

  static Future<Map<String, dynamic>> put(String path, {Object? data}) =>
      _send('PUT', path, data: data);

  static Future<Map<String, dynamic>> delete(String path) => _send('DELETE', path);

  // remember = true  -> token disimpan permanen (aplikasi dibuka lagi tetap login)
  // remember = false -> token hanya di memori (hilang saat aplikasi ditutup)
  static Future<void> saveToken(String token, {bool remember = true}) async {
    _memoryToken = token;
    if (remember) {
      await _storage.write(key: _tokenKey, value: token);
    } else {
      await _storage.delete(key: _tokenKey);
    }
  }

  static Future<String?> getToken() async =>
      _memoryToken ?? await _storage.read(key: _tokenKey);

  static Future<void> clearToken() async {
    _memoryToken = null;
    await _storage.delete(key: _tokenKey);
  }
}