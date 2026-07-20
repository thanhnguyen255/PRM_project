import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class AuthService {
  final _api = ApiService.instance;

  static const _keyToken    = 'token';
  static const _keyUserId   = 'userId';
  static const _keyFullName = 'fullName';
  static const _keyRole     = 'role';
  static const _keyAvatar   = 'avatarUrl';
  static const _keyInstTabs = 'instructor_tabs';

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<({bool success, String? error, AuthResponse? data})> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(ApiConfig.login, data: {
      'email': email.trim(),
      'password': password,
    });

    if (res['success'] == true) {
      final auth = AuthResponse.fromJson(res['data'] as Map<String, dynamic>);
      await _saveSession(auth);
      return (success: true, error: null, data: auth);
    }
    return (success: false, error: res['message'] as String?, data: null);
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<({bool success, String? error, AuthResponse? data})> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await _api.post(ApiConfig.register, data: {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'password': password,
    });

    if (res['success'] == true) {
      final auth = AuthResponse.fromJson(res['data'] as Map<String, dynamic>);
      await _saveSession(auth);
      return (success: true, error: null, data: auth);
    }
    return (success: false, error: res['message'] as String?, data: null);
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Check session ──────────────────────────────────────────────────────────
  Future<({String? token, String? role})> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      token: prefs.getString(_keyToken),
      role:  prefs.getString(_keyRole),
    );
  }

  Future<String?> getToken()  async => (await SharedPreferences.getInstance()).getString(_keyToken);
  Future<String?> getRole()   async => (await SharedPreferences.getInstance()).getString(_keyRole);
  Future<int?>    getUserId() async => (await SharedPreferences.getInstance()).getInt(_keyUserId);
  Future<String?> getFullName() async => (await SharedPreferences.getInstance()).getString(_keyFullName);

  // ── Get current user profile ───────────────────────────────────────────────
  Future<UserModel?> getMe() async {
    final res = await _api.get(ApiConfig.me);
    if (res['success'] == true) {
      return UserModel.fromJson(res['data'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<String>> getInstructorTabs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyInstTabs) ?? ['Dashboard', 'Courses', 'Evidence', 'Analytics'];
  }

  Future<void> saveInstructorTabs(List<String> tabs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyInstTabs, tabs);
  }

  // ── Private helpers ────────────────────────────────────────────────────────
  Future<void> _saveSession(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken,    auth.token);
    await prefs.setInt(_keyUserId,      auth.userId);
    await prefs.setString(_keyFullName, auth.fullName);
    await prefs.setString(_keyRole,     auth.role);
    if (auth.avatarUrl != null) await prefs.setString(_keyAvatar, auth.avatarUrl!);
  }
}
