import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/extended_services.dart';

// ─── ProjectViewModel ─────────────────────────────────────────────────────────
class ProjectViewModel extends ChangeNotifier {
  final _projectSvc   = ProjectService();
  final _milestoneSvc = MilestoneService();

  List<ProjectModel>   _projects      = [];
  Map<String,dynamic>? _projectDetail;
  List<MilestoneModel> _milestones    = [];
  MilestoneModel?      _milestone;
  bool                 _isLoading     = false;
  bool                 _isSaving      = false;

  List<ProjectModel>   get projects       => _projects;
  Map<String,dynamic>? get projectDetail  => _projectDetail;
  List<MilestoneModel> get milestones     => _milestones;
  MilestoneModel?      get milestone      => _milestone;
  bool                 get isLoading      => _isLoading;
  bool                 get isSaving       => _isSaving;

  Future<void> loadProjects(int classId) async {
    _isLoading = true; notifyListeners();
    _projects  = await _projectSvc.getProjects(classId);
    _isLoading = false; notifyListeners();
  }

  Future<void> loadProjectDetail(int id) async {
    _isLoading     = true; notifyListeners();
    _projectDetail = await _projectSvc.getProjectDetail(id);
    _isLoading     = false; notifyListeners();
  }

  Future<void> loadMilestones(int projectId) async {
    _isLoading  = true; notifyListeners();
    _milestones = await _milestoneSvc.getMilestones(projectId);
    _isLoading  = false; notifyListeners();
  }

  Future<void> loadMilestoneDetail(int id) async {
    _isLoading = true; notifyListeners();
    _milestone = await _milestoneSvc.getMilestoneDetail(id);
    _isLoading = false; notifyListeners();
  }

  Future<String?> createProject({required int classId, required String title, String? description}) async {
    _isSaving = true; notifyListeners();
    final r = await _projectSvc.createProject(classId: classId, title: title, description: description);
    _isSaving = false;
    if (r.success) await loadProjects(classId);
    notifyListeners();
    return r.success ? null : r.error;
  }

  Future<String?> deleteProject(int id, int classId) async {
    final r = await _projectSvc.deleteProject(id);
    if (r.success) await loadProjects(classId);
    return r.success ? null : r.error;
  }

  Future<String?> createMilestone({
    required int projectId,
    required String title,
    String? description,
    String? dueDate,
  }) async {
    _isSaving = true; notifyListeners();
    final r = await _milestoneSvc.createMilestone(
      projectId: projectId, title: title, description: description, dueDate: dueDate,
    );
    _isSaving = false;
    if (r.success) await loadMilestones(projectId);
    notifyListeners();
    return r.success ? null : r.error;
  }

  Future<String?> deleteMilestone(int id, int projectId) async {
    final r = await _milestoneSvc.deleteMilestone(id);
    if (r.success) await loadMilestones(projectId);
    return r.success ? null : r.error;
  }

  Future<String?> submitMilestone({required int milestoneId, String? description, String? filePath}) async {
    _isSaving = true; notifyListeners();
    final r = await _milestoneSvc.submitMilestone(milestoneId: milestoneId, description: description, filePath: filePath);
    _isSaving = false; notifyListeners();
    return r.success ? null : r.error;
  }
}

// ─── ReviewViewModel ──────────────────────────────────────────────────────────
class ReviewViewModel extends ChangeNotifier {
  final _svc = ReviewService();

  List<ReviewSessionModel>  _sessions         = [];
  Map<String,dynamic>?      _sessionDetail;
  List<FeedbackModel>       _receivedFeedback = [];
  List<Map<String,dynamic>> _assignments      = [];
  bool                      _isLoading        = false;
  bool                      _isSaving         = false;

  List<ReviewSessionModel>  get sessions         => _sessions;
  Map<String,dynamic>?      get sessionDetail    => _sessionDetail;
  List<FeedbackModel>       get receivedFeedback => _receivedFeedback;
  List<Map<String,dynamic>> get assignments      => _assignments;
  bool                      get isLoading        => _isLoading;
  bool                      get isSaving         => _isSaving;

  Future<void> loadSessions(int classId) async {
    _isLoading = true; notifyListeners();
    _sessions  = await _svc.getReviewSessions(classId);
    _isLoading = false; notifyListeners();
  }

  Future<void> loadReviewDetail(int sessionId) async {
    _isLoading     = true;
    _sessionDetail = null;
    _assignments   = [];
    notifyListeners();
    final results = await Future.wait([
      _svc.getSessionDetail(sessionId),
      _svc.getAssignments(sessionId),
    ]);
    _sessionDetail = results[0] as Map<String, dynamic>?;
    _assignments   = results[1] as List<Map<String, dynamic>>;
    _isLoading     = false;
    notifyListeners();
  }

  // Keep individual methods for backward compat
  Future<void> loadSessionDetail(int id) async {
    _isLoading     = true; notifyListeners();
    _sessionDetail = await _svc.getSessionDetail(id);
    _isLoading     = false; notifyListeners();
  }

  Future<void> loadAssignments(int sessionId) async {
    _isLoading   = true; notifyListeners();
    _assignments = await _svc.getAssignments(sessionId);
    _isLoading   = false; notifyListeners();
  }

  Future<void> loadReceivedFeedback(int sessionId) async {
    _receivedFeedback = await _svc.getReceivedFeedback(sessionId);
    notifyListeners();
  }

  Future<String?> submitFeedback({
    required int assignmentId,
    required String content,
    required int rating,
  }) async {
    _isSaving = true; notifyListeners();
    final r = await _svc.submitFeedback(assignmentId: assignmentId, content: content, rating: rating);
    _isSaving = false; notifyListeners();
    return r.success ? null : r.error;
  }

  Future<String?> createSession({
    required int classId,
    required String title,
    required String startDate,
    required String endDate,
  }) async {
    _isSaving = true; notifyListeners();
    final r = await _svc.createSession(classId: classId, title: title, startDate: startDate, endDate: endDate);
    _isSaving = false;
    if (r.success) await loadSessions(classId);
    notifyListeners();
    return r.success ? null : r.error;
  }
}

// ─── AnalyticsViewModel ───────────────────────────────────────────────────────
class AnalyticsViewModel extends ChangeNotifier {
  final _svc  = AnalyticsService();

  Map<String,dynamic>? _myProgress;
  Map<String,dynamic>? _classAnalytics;
  Map<String,dynamic>? _studentAnalytics;
  bool                 _isLoading = false;

  Map<String,dynamic>? get myProgress       => _myProgress;
  Map<String,dynamic>? get classAnalytics   => _classAnalytics;
  Map<String,dynamic>? get studentAnalytics => _studentAnalytics;
  bool                 get isLoading        => _isLoading;

  Future<void> loadMyProgress({int? classId}) async {
    _isLoading  = true; notifyListeners();
    _myProgress = await _svc.getMyProgress(classId: classId);
    _isLoading  = false; notifyListeners();
  }

  Future<void> loadClassAnalytics(int classId) async {
    _isLoading      = true; notifyListeners();
    _classAnalytics = await _svc.getClassAnalytics(classId);
    _isLoading      = false; notifyListeners();
  }

  Future<void> loadStudentAnalytics(int userId, int classId) async {
    _isLoading        = true; notifyListeners();
    _studentAnalytics = await _svc.getStudentAnalytics(userId, classId);
    _isLoading        = false; notifyListeners();
  }
}

// ─── MaterialViewModel ────────────────────────────────────────────────────────
class MaterialViewModel extends ChangeNotifier {
  final _svc = MaterialService();

  List<Map<String,dynamic>> _materials = [];
  Map<String,dynamic>?      _materialDetail;
  bool                      _isLoading = false;
  bool                      _isSaving  = false;

  List<Map<String,dynamic>> get materials      => _materials;
  Map<String,dynamic>?      get materialDetail => _materialDetail;
  bool                      get isLoading      => _isLoading;
  bool                      get isSaving       => _isSaving;

  Future<void> loadMaterialDetail(int id) async {
    _isLoading      = true; notifyListeners();
    _materialDetail = await _svc.getMaterialDetail(id);
    _isLoading      = false; notifyListeners();
  }

  Future<void> loadMaterials(int pathId) async {
    _isLoading = true; notifyListeners();
    _materials = await _svc.getMaterials(pathId);
    _isLoading = false; notifyListeners();
  }

  Future<String?> createMaterial({
    required int learningPathId,
    required String title,
    required String type,
    String? linkUrl,
    String? filePath,
  }) async {
    _isSaving = true; notifyListeners();
    final r = await _svc.createMaterial(
      learningPathId: learningPathId, title: title, type: type, linkUrl: linkUrl, filePath: filePath,
    );
    _isSaving = false;
    if (r.success) await loadMaterials(learningPathId);
    notifyListeners();
    return r.success ? null : r.error;
  }

  Future<String?> deleteMaterial(int id, int pathId) async {
    final r = await _svc.deleteMaterial(id);
    if (r.success) await loadMaterials(pathId);
    return r.success ? null : r.error;
  }
}

// ─── ExtendedActivityViewModel ────────────────────────────────────────────────────────
class ExtendedActivityViewModel extends ChangeNotifier {
  final _svc = ActivityService();

  List<Map<String, dynamic>> _activities = [];
  Map<String, dynamic>? _activityDetail;
  bool _isLoading = false;

  List<Map<String, dynamic>> get activities => _activities;
  Map<String, dynamic>? get activityDetail => _activityDetail;
  bool get isLoading => _isLoading;

  Future<void> loadActivities(int pathId, {String? type}) async {
    _isLoading = true;
    notifyListeners();
    _activities = await _svc.getActivities(pathId, type: type);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadActivityDetail(int id) async {
    _isLoading = true;
    notifyListeners();
    _activityDetail = await _svc.getActivityDetail(id);
    _isLoading = false;
    notifyListeners();
  }
}

// ─── InstructorManageViewModel ────────────────────────────────────────────────
class InstructorManageViewModel extends ChangeNotifier {
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<String?> createCourse({required String title, String? description}) async {
    _isSaving = true; notifyListeners();
    final res = await ApiService.instance.post('/courses', data: {'title': title, 'description': description});
    _isSaving = false; notifyListeners();
    return res['success'] == true ? null : res['message'] as String?;
  }

  Future<String?> updateCourse(int id, {required String title, String? description}) async {
    _isSaving = true; notifyListeners();
    final res = await ApiService.instance.put('/courses/$id', data: {'title': title, 'description': description});
    _isSaving = false; notifyListeners();
    return res['success'] == true ? null : res['message'] as String?;
  }

  Future<String?> deleteCourse(int id) async {
    final res = await ApiService.instance.delete('/courses/$id');
    return res['success'] == true ? null : res['message'] as String?;
  }

  Future<String?> createClass({
    required int courseId,
    required String name,
    String? startDate,
    String? endDate,
  }) async {
    _isSaving = true; notifyListeners();
    final res = await ApiService.instance.post('/classes', data: {
      'courseId': courseId, 'name': name, 'startDate': startDate, 'endDate': endDate,
    });
    _isSaving = false; notifyListeners();
    return res['success'] == true ? null : res['message'] as String?;
  }

  Future<String?> addMemberByEmail(int classId, String email) async {
    final res = await ApiService.instance.post('/classes/$classId/members', data: {'email': email});
    return res['success'] == true ? null : res['message'] as String?;
  }

  Future<String?> removeMember(int classId, int userId) async {
    final res = await ApiService.instance.delete('/classes/$classId/members/$userId');
    return res['success'] == true ? null : res['message'] as String?;
  }

  Future<String?> createLearningPath({
    required int classId,
    required String title,
    required int weekNumber,
  }) async {
    _isSaving = true; notifyListeners();
    final res = await ApiService.instance.post('/learning-paths', data: {
      'classId': classId, 'title': title, 'weekNumber': weekNumber,
    });
    _isSaving = false; notifyListeners();
    return res['success'] == true ? null : res['message'] as String?;
  }

  Future<String?> deleteLearningPath(int id) async {
    final res = await ApiService.instance.delete('/learning-paths/$id');
    return res['success'] == true ? null : res['message'] as String?;
  }

  Future<String?> toggleLearningPathLock(int id) async {
    final res = await ApiService.instance.patch('/learning-paths/$id/toggle-lock');
    return res['success'] == true ? null : res['message'] as String?;
  }

  Future<String?> createActivity({
    required int learningPathId,
    required String title,
    required String type,
    String? description,
    String? deadline,
  }) async {
    _isSaving = true; notifyListeners();
    final res = await ApiService.instance.post('/activities', data: {
      'learningPathId': learningPathId,
      'title': title,
      'type': type,
      'description': description,
      'deadline': deadline,
    });
    _isSaving = false; notifyListeners();
    return res['success'] == true ? null : res['message'] as String?;
  }

  Future<String?> deleteActivity(int id) async {
    final res = await ApiService.instance.delete('/activities/$id');
    return res['success'] == true ? null : res['message'] as String?;
  }
}
