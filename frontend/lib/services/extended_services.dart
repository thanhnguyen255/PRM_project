import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

// ─── ProjectService ────────────────────────────────────────────────────────────
class ProjectService {
  final _api = ApiService.instance;

  Future<List<ProjectModel>> getProjects(int classId) async {
    final res = await _api.get(ApiConfig.projects(classId));
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getProjectDetail(int id) async {
    final res = await _api.get(ApiConfig.projectDetail(id));
    if (res['success'] == true) return res['data'] as Map<String, dynamic>;
    return null;
  }

  Future<({bool success, String? error})> createProject({
    required int classId,
    required String title,
    String? description,
  }) async {
    final res = await _api.post(ApiConfig.createProject, data: {
      'classId': classId,
      'title': title,
      'description': description,
    });
    return (success: res['success'] == true, error: res['message'] as String?);
  }

  Future<({bool success, String? error})> updateProject(int id, {required String title, String? description}) async {
    final res = await _api.put(ApiConfig.updateProject(id), data: {'title': title, 'description': description});
    return (success: res['success'] == true, error: res['message'] as String?);
  }

  Future<({bool success, String? error})> deleteProject(int id) async {
    final res = await _api.delete(ApiConfig.deleteProject(id));
    return (success: res['success'] == true, error: res['message'] as String?);
  }
}

// ─── MilestoneService ─────────────────────────────────────────────────────────
class MilestoneService {
  final _api = ApiService.instance;

  Future<List<MilestoneModel>> getMilestones(int projectId) async {
    final res = await _api.get(ApiConfig.milestones(projectId));
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => MilestoneModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<MilestoneModel?> getMilestoneDetail(int id) async {
    final res = await _api.get(ApiConfig.milestoneDetail(id));
    if (res['success'] == true) return MilestoneModel.fromJson(res['data'] as Map<String, dynamic>);
    return null;
  }

  Future<({bool success, String? error})> createMilestone({
    required int projectId,
    required String title,
    String? description,
    String? dueDate,
  }) async {
    final res = await _api.post(ApiConfig.createMilestone, data: {
      'projectId': projectId,
      'title': title,
      'description': description,
      'dueDate': dueDate,
    });
    return (success: res['success'] == true, error: res['message'] as String?);
  }

  Future<({bool success, String? error})> updateMilestone(int id, {
    required String title,
    String? description,
    String? dueDate,
  }) async {
    final res = await _api.put(ApiConfig.updateMilestone(id), data: {
      'title': title,
      'description': description,
      'dueDate': dueDate,
    });
    return (success: res['success'] == true, error: res['message'] as String?);
  }

  Future<({bool success, String? error})> deleteMilestone(int id) async {
    final res = await _api.delete(ApiConfig.deleteMilestone(id));
    return (success: res['success'] == true, error: res['message'] as String?);
  }

  Future<({bool success, String? error})> submitMilestone({
    required int milestoneId,
    String? description,
  }) async {
    final res = await _api.post(ApiConfig.submitMilestone, data: {
      'milestoneId': milestoneId,
      'description': description,
    });
    return (success: res['success'] == true, error: res['message'] as String?);
  }
}

// ─── ReviewService ────────────────────────────────────────────────────────────
class ReviewService {
  final _api = ApiService.instance;

  Future<List<ReviewSessionModel>> getReviewSessions(int classId) async {
    final res = await _api.get(ApiConfig.reviewSessions(classId));
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => ReviewSessionModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getSessionDetail(int id) async {
    final res = await _api.get(ApiConfig.reviewSessionDetail(id));
    if (res['success'] == true) return res['data'] as Map<String, dynamic>;
    return null;
  }

  Future<({bool success, String? error})> createSession({
    required int classId,
    required String title,
    required String startDate,
    required String endDate,
  }) async {
    final res = await _api.post(ApiConfig.createReviewSession, data: {
      'classId': classId,
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'autoAssign': true,
    });
    return (success: res['success'] == true, error: res['message'] as String?);
  }

  Future<List<Map<String, dynamic>>> getAssignments(int sessionId) async {
    final res = await _api.get(ApiConfig.allAssignments(sessionId));
    if (res['success'] == true) {
      return (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<List<FeedbackModel>> getReceivedFeedback(int sessionId) async {
    final res = await _api.get(ApiConfig.receivedFeedback(sessionId));
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => FeedbackModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<({bool success, String? error})> submitFeedback({
    required int assignmentId,
    required String content,
    required int rating,
  }) async {
    final res = await _api.post(ApiConfig.createFeedback, data: {
      'assignmentId': assignmentId,
      'content': content,
      'rating': rating,
    });
    return (success: res['success'] == true, error: res['message'] as String?);
  }
}

// ─── AnalyticsService ──────────────────────────────────────────────────────────
class AnalyticsService {
  final _api = ApiService.instance;

  Future<Map<String, dynamic>?> getMyProgress({int? classId}) async {
    final url = classId != null
        ? '${ApiConfig.myProgress}?classId=$classId'
        : ApiConfig.myProgress;
    final res = await _api.get(url);
    if (res['success'] == true) return res['data'] as Map<String, dynamic>;
    return null;
  }

  Future<Map<String, dynamic>?> getClassAnalytics(int classId) async {
    final res = await _api.get(ApiConfig.classAnalytics(classId));
    if (res['success'] == true) return res['data'] as Map<String, dynamic>;
    return null;
  }

  Future<Map<String, dynamic>?> getStudentAnalytics(int userId, int classId) async {
    final res = await _api.get(ApiConfig.studentAnalytics(userId, classId));
    if (res['success'] == true) return res['data'] as Map<String, dynamic>;
    return null;
  }
}

// ─── MaterialService ──────────────────────────────────────────────────────────
class MaterialService {
  final _api = ApiService.instance;

  Future<List<Map<String, dynamic>>> getMaterials(int pathId) async {
    final res = await _api.get(ApiConfig.materials(pathId));
    if (res['success'] == true) {
      return (res['data'] as List<dynamic>).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<({bool success, String? error})> createMaterial({
    required int learningPathId,
    required String title,
    required String type,
    String? linkUrl,
  }) async {
    final res = await _api.post(ApiConfig.createMaterial, data: {
      'learningPathId': learningPathId,
      'title': title,
      'type': type,
      'linkUrl': linkUrl,
    });
    return (success: res['success'] == true, error: res['message'] as String?);
  }

  Future<({bool success, String? error})> deleteMaterial(int id) async {
    final res = await _api.delete(ApiConfig.deleteMaterial(id));
    return (success: res['success'] == true, error: res['message'] as String?);
  }
}
