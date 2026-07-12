import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/services.dart';

// ─── AuthViewModel ────────────────────────────────────────────────────────────
class AuthViewModel extends ChangeNotifier {
  final _auth = AuthService();

  bool _isLoading = false;
  String? _error;
  int? _userId;

  AuthViewModel() {
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _userId = await _auth.getUserId();
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  String? get error  => _error;
  int? get userId    => _userId;

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? v) { _error = v; notifyListeners(); }
  void clearError() => _setError(null);

  Future<String?> login(String email, String password) async {
    _setLoading(true); _setError(null);
    final result = await _auth.login(email: email, password: password);
    _setLoading(false);
    if (!result.success) {
      _setError(result.error);
    } else if (result.data != null) {
      _userId = result.data!.userId;
      notifyListeners();
    }
    return result.success ? result.data!.role : null;
  }

  Future<String?> register(String fullName, String email, String password) async {
    _setLoading(true); _setError(null);
    final result = await _auth.register(fullName: fullName, email: email, password: password);
    _setLoading(false);
    if (!result.success) {
      _setError(result.error);
    } else if (result.data != null) {
      _userId = result.data!.userId;
      notifyListeners();
    }
    return result.success ? result.data!.role : null;
  }

  Future<void> logout() async {
    await _auth.logout();
    _userId = null;
    notifyListeners();
  }
}

// ─── HomeViewModel ────────────────────────────────────────────────────────────
class HomeViewModel extends ChangeNotifier {
  final _courseService = CourseService();
  final _activityService = ActivityService();
  final _notifService = NotificationService();
  final _auth = AuthService();
  final _profileService = ProfileService();

  List<CourseModel>   _courses    = [];
  List<ActivityModel> _upcoming   = [];
  int                 _unreadCount = 0;
  String              _greeting   = '';
  UserModel?          _profile;
  bool                _isLoading  = true;
  String?             _error;

  List<CourseModel>   get courses     => _courses;
  List<ActivityModel> get upcoming    => _upcoming;
  int                 get unreadCount => _unreadCount;
  String              get greeting    => _greeting;
  UserModel?          get profile     => _profile;
  bool                get isLoading   => _isLoading;
  String?             get error       => _error;

  Future<void> init() async {
    _isLoading = true; notifyListeners();
    final name = await _auth.getFullName();
    _greeting = name ?? 'Học viên';

    try {
      final data = await _profileService.getProfile();
      if (data != null) {
        _profile = UserModel.fromJson(data);
        _greeting = _profile!.fullName;
      }
    } catch (_) {}

    await Future.wait([
      _loadCourses(),
      _loadUnreadCount(),
    ]);
    _isLoading = false; notifyListeners();
  }

  Future<void> _loadCourses() async {
    _courses = await _courseService.getMyCourses();
    // Load toàn bộ upcoming activities của học viên
    _upcoming = await _activityService.getUpcoming();
  }

  Future<void> _loadUnreadCount() async {
    _unreadCount = await _notifService.getUnreadCount();
  }

  Future<void> refresh() async {
    _error = null;
    await init();
  }
}

// ─── CourseViewModel ──────────────────────────────────────────────────────────
class CourseViewModel extends ChangeNotifier {
  final _service = CourseService();

  List<CourseModel> _courses   = [];
  CourseModel?      _detail;
  bool              _isLoading = false;
  String?           _error;
  String            _search    = '';

  List<CourseModel> get courses  => _search.isEmpty ? _courses
      : _courses.where((c) => c.title.toLowerCase().contains(_search.toLowerCase())).toList();
  CourseModel?      get detail   => _detail;
  bool              get isLoading => _isLoading;
  String?           get error    => _error;

  void setSearch(String v) { _search = v; notifyListeners(); }

  Future<void> loadMyCourses() async {
    _isLoading = true; notifyListeners();
    _courses   = await _service.getMyCourses();
    _isLoading = false; notifyListeners();
  }

  Future<void> loadCourseDetail(int id) async {
    _isLoading = true; notifyListeners();
    _detail    = await _service.getCourseDetail(id);
    _isLoading = false; notifyListeners();
  }
}

// ─── ClassViewModel ───────────────────────────────────────────────────────────
class ClassViewModel extends ChangeNotifier {
  final _service = ClassService();

  ClassModel?            _detail;
  List<ClassModel>       _classes   = [];
  List<ClassMemberModel> _members   = [];
  bool                   _isLoading = false;

  ClassModel?            get detail    => _detail;
  List<ClassModel>       get classes   => _classes;
  List<ClassMemberModel> get members   => _members;
  bool                   get isLoading => _isLoading;

  Future<void> loadClass(int id) async {
    _isLoading = true; notifyListeners();
    _detail    = await _service.getClassDetail(id);
    _isLoading = false; notifyListeners();
  }

  Future<void> loadClassesByCourse(int courseId) async {
    _isLoading = true; notifyListeners();
    _classes   = await _service.getClassesByCourse(courseId);
    _isLoading = false; notifyListeners();
  }

  Future<void> loadMembers(int classId) async {
    _isLoading = true; notifyListeners();
    _members   = await _service.getMembers(classId);
    _isLoading = false; notifyListeners();
  }
}

// ─── LearningPathViewModel ─────────────────────────────────────────────────────
class LearningPathViewModel extends ChangeNotifier {
  final _service = LearningPathService();

  List<LearningPathModel> _paths     = [];
  Map<String, dynamic>?   _detail;
  bool                    _isLoading = false;

  List<LearningPathModel> get paths     => _paths;
  Map<String, dynamic>?   get detail    => _detail;
  bool                    get isLoading => _isLoading;

  Future<void> loadPaths(int classId) async {
    _isLoading = true; notifyListeners();
    _paths     = await _service.getLearningPaths(classId);
    _isLoading = false; notifyListeners();
  }

  Future<void> loadPathDetail(int id) async {
    _isLoading = true; notifyListeners();
    _detail    = await _service.getLearningPathDetail(id);
    _isLoading = false; notifyListeners();
  }
}

// ─── ActivityViewModel ────────────────────────────────────────────────────────
class ActivityViewModel extends ChangeNotifier {
  final _service = ActivityService();

  List<ActivityModel>   _activities = [];
  Map<String, dynamic>? _detail;
  bool                  _isLoading  = false;
  String                _typeFilter = 'PreClass';

  List<ActivityModel>   get activities => _activities;
  Map<String, dynamic>? get detail     => _detail;
  bool                  get isLoading  => _isLoading;
  String                get typeFilter => _typeFilter;

  void setTypeFilter(String t) { _typeFilter = t; notifyListeners(); }

  Future<void> loadActivities(int pathId, {String? type}) async {
    _isLoading  = true; notifyListeners();
    _activities = await _service.getActivities(pathId, type: type ?? _typeFilter);
    _isLoading  = false; notifyListeners();
  }

  Future<void> loadDetail(int id) async {
    _isLoading = true; notifyListeners();
    _detail    = await _service.getActivityDetail(id);
    _isLoading = false; notifyListeners();
  }
}

// ─── EvidenceViewModel ────────────────────────────────────────────────────────
class EvidenceViewModel extends ChangeNotifier {
  final _service = EvidenceService();

  List<EvidenceModel>        _evidences  = [];
  EvidenceModel?             _detail;
  List<EvidenceCommentModel> _comments   = [];
  bool                       _isLoading  = false;
  bool                       _isSubmitting = false;
  String?                    _error;
  String                     _statusFilter = 'All';
  int?                       _currentClassId;

  List<EvidenceModel>        get evidences    => _evidences;
  EvidenceModel?             get detail       => _detail;
  List<EvidenceCommentModel> get comments     => _comments;
  bool                       get isLoading    => _isLoading;
  bool                       get isSubmitting => _isSubmitting;
  String?                    get error        => _error;
  String                     get statusFilter => _statusFilter;
  int?                       get currentClassId => _currentClassId;

  void setStatusFilter(String v) { _statusFilter = v; notifyListeners(); }

  Future<void> loadEvidencesByClass(int? classId) async {
    _currentClassId = classId;
    _isLoading = true; notifyListeners();
    _evidences = await _service.getEvidencesByClass(classId, status: _statusFilter == 'All' ? null : _statusFilter);
    _isLoading = false; notifyListeners();
  }

  Future<void> loadDetail(int id) async {
    _isLoading = true; notifyListeners();
    _detail    = await _service.getEvidenceDetail(id);
    _isLoading = false; notifyListeners();
  }

  Future<void> loadComments(int evidenceId) async {
    _comments  = await _service.getComments(evidenceId);
    notifyListeners();
  }

  Future<String?> submitEvidence({required int activityId, String? note, String? filePath, List<int>? fileBytes, String? fileName}) async {
    _isSubmitting = true; notifyListeners();
    final result = await _service.submitEvidence(activityId: activityId, note: note, filePath: filePath, fileBytes: fileBytes, fileName: fileName);
    _isSubmitting = false; notifyListeners();
    return result.success ? null : result.error;
  }

  Future<String?> approve(int id, {String? comment}) async {
    final r = await _service.approveEvidence(id, comment: comment);
    if (r.success) {
      await loadDetail(id);
      await loadEvidencesByClass(_currentClassId);
    }
    return r.success ? null : r.error;
  }

  Future<String?> reject(int id, {String? comment}) async {
    final r = await _service.rejectEvidence(id, comment: comment);
    if (r.success) {
      await loadDetail(id);
      await loadEvidencesByClass(_currentClassId);
    }
    return r.success ? null : r.error;
  }

  Future<String?> addComment(int evidenceId, String content) async {
    final r = await _service.addComment(evidenceId, content);
    if (r.success) await loadComments(evidenceId);
    return r.success ? null : r.error;
  }
}

// ─── NotificationViewModel ─────────────────────────────────────────────────────
class NotificationViewModel extends ChangeNotifier {
  final _service = NotificationService();

  List<NotificationModel> _notifications = [];
  bool                    _isLoading     = false;

  List<NotificationModel> get notifications => _notifications;
  bool                    get isLoading     => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> load() async {
    _isLoading     = true; notifyListeners();
    _notifications = await _service.getNotifications();
    _isLoading     = false; notifyListeners();
  }

  Future<void> markRead(int id) async {
    await _service.markRead(id);
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notifications[idx] = NotificationModel(
        id: _notifications[idx].id,
        title: _notifications[idx].title,
        body: _notifications[idx].body,
        isRead: true,
        createdAt: _notifications[idx].createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    await _service.markAllRead();
    await load();
  }
}
