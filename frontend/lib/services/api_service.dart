import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  late final Dio _dio;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    // Request interceptor — đính kèm JWT token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final data = e.response?.data;
          final msg = (data is Map && data['message'] != null) ? data['message'].toString() : '';
          
          // Tránh xóa token nếu lỗi 401 thực chất là lỗi phân quyền từ backend (Backend trả nhầm 401 thay vì 403)
          if (!msg.contains('không có quyền')) {
            // Token hết hạn — xóa local data
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
          }
        }
        handler.next(e);
      },
    ));
  }

  Dio get dio {
    if (!_initialized) init();
    return _dio;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Trích `data` từ wrapper response `{success, data, message}`
  dynamic _unwrap(Response res) {
    final body = res.data;
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  String _errorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'] as String;
    switch (e.response?.statusCode) {
      case 400: return 'Dữ liệu không hợp lệ.';
      case 401: return 'Phiên đăng nhập hết hạn.';
      case 403: return 'Bạn không có quyền thực hiện.';
      case 404: return 'Không tìm thấy dữ liệu.';
      case 409: return 'Dữ liệu đã tồn tại.';
      case 500: return 'Lỗi hệ thống. Vui lòng thử lại.';
      default:  return 'Không thể kết nối. Kiểm tra lại mạng.';
    }
  }

  // ── Public Methods ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final query = params ?? <String, dynamic>{};
      query['_t'] = DateTime.now().millisecondsSinceEpoch; // Ngăn browser cache (đặc biệt trên Web)
      final res = await dio.get(path, queryParameters: query);
      return {'success': true, 'data': _unwrap(res)};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final res = await dio.post(path, data: data);
      return {'success': true, 'data': _unwrap(res)};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    try {
      final res = await dio.put(path, data: data);
      return {'success': true, 'data': _unwrap(res)};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    try {
      final res = await dio.patch(path, data: data);
      return {'success': true, 'data': _unwrap(res)};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      await dio.delete(path);
      return {'success': true};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> postForm(String path, FormData formData) async {
    try {
      final res = await dio.post(path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return {'success': true, 'data': _unwrap(res)};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> putForm(String path, FormData formData) async {
    try {
      final res = await dio.put(path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return {'success': true, 'data': _unwrap(res)};
    } on DioException catch (e) {
      return {'success': false, 'message': _errorMessage(e)};
    }
  }
}
