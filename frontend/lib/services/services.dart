import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class CourseService {
  final _api = ApiService.instance;

  Future<List<CourseModel>> getMyCourses() async {
    final res = await _api.get(ApiConfig.myCourses);
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => CourseModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<CourseModel?> getCourseDetail(int id) async {
    final res = await _api.get(ApiConfig.courseDetail(id));
    if (res['success'] == true) {
      return CourseModel.fromJson(res['data'] as Map<String, dynamic>);
    }
    return null;
  }
}

class ClassService {
  final _api = ApiService.instance;

  Future<List<ClassModel>> getMyClasses() async {
    final res = await _api.get(ApiConfig.myClasses);
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => ClassModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<ClassModel>> getClassesByCourse(int courseId) async {
    final res = await _api.get(ApiConfig.classesByCourse(courseId));
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => ClassModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<ClassModel?> getClassDetail(int id) async {
    final res = await _api.get(ApiConfig.classDetail(id));
    if (res['success'] == true) {
      return ClassModel.fromJson(res['data'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<ClassMemberModel>> getMembers(int classId) async {
    final res = await _api.get(ApiConfig.classMembers(classId));
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => ClassMemberModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}


class LearningPathService {
  final _api = ApiService.instance;

  Future<List<LearningPathModel>> getLearningPaths(int classId) async {
    final res = await _api.get(ApiConfig.learningPaths(classId));
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => LearningPathModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getLearningPathDetail(int id) async {
    final res = await _api.get(ApiConfig.learningPathDetail(id));
    if (res['success'] == true) return res['data'] as Map<String, dynamic>;
    return null;
  }
}

class ActivityService {
  final _api = ApiService.instance;

  Future<List<ActivityModel>> getActivities(int pathId, {String? type}) async {
    final res = await _api.get(ApiConfig.activities(pathId, type: type));
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<ActivityModel>> getUpcoming(int classId) async {
    final res = await _api.get(ApiConfig.upcomingActivities(classId));
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>?> getActivityDetail(int id) async {
    final res = await _api.get(ApiConfig.activityDetail(id));
    if (res['success'] == true) return res['data'] as Map<String, dynamic>;
    return null;
  }
}

class EvidenceService {
  final _api = ApiService.instance;

  Future<List<EvidenceModel>> getEvidencesByClass(int classId, {String? status}) async {
    final res = await _api.get(ApiConfig.evidencesByClass(classId, status: status));
    if (res['success'] == true) {
      final data = res['data'];
      final items = data is Map ? data['items'] as List<dynamic> : data as List<dynamic>;
      return items.map((e) => EvidenceModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<EvidenceModel?> getEvidenceDetail(int id) async {
    final res = await _api.get(ApiConfig.evidenceDetail(id));
    if (res['success'] == true) {
      return EvidenceModel.fromJson(res['data'] as Map<String, dynamic>);
    }
    return null;
  }

  Future<({bool success, String? error})> submitEvidence({
    required int activityId,
    String? note,
    String? filePath,
    String? fileName,
  }) async {
    try {
      final Map<String, dynamic> data = {'ActivityId': activityId};
      if (note != null && note.isNotEmpty) data['Note'] = note;

      if (filePath != null && filePath.isNotEmpty) {
        data['File'] = await MultipartFile.fromFile(
          filePath,
          filename: fileName ?? filePath.split('/').last,
        );
      }

      final formData = FormData.fromMap(data);
      final res = await _api.postForm(ApiConfig.evidences, formData);
      return (
        success: res['success'] == true,
        error: res['message'] as String?,
      );
    } catch (e) {
      return (success: false, error: e.toString());
    }
  }

  Future<({bool success, String? error})> approveEvidence(int id, {String? comment}) async {
    final res = await _api.put(ApiConfig.approveEvidence(id), data: {'comment': comment});
    return (success: res['success'] == true, error: res['message'] as String?);
  }

  Future<({bool success, String? error})> rejectEvidence(int id, {String? comment}) async {
    final res = await _api.put(ApiConfig.rejectEvidence(id), data: {'comment': comment});
    return (success: res['success'] == true, error: res['message'] as String?);
  }

  Future<List<EvidenceCommentModel>> getComments(int evidenceId) async {
    final res = await _api.get(ApiConfig.evidenceComments(evidenceId));
    if (res['success'] == true) {
      final list = res['data'] as List<dynamic>;
      return list.map((e) => EvidenceCommentModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<({bool success, String? error})> addComment(int evidenceId, String content) async {
    final res = await _api.post(ApiConfig.evidenceComments(evidenceId), data: {'content': content});
    return (success: res['success'] == true, error: res['message'] as String?);
  }
}

class NotificationService {
  final _api = ApiService.instance;

  Future<List<NotificationModel>> getNotifications() async {
    final res = await _api.get(ApiConfig.notifications);
    if (res['success'] == true) {
      final data = res['data'];
      final items = data is Map ? data['items'] as List<dynamic> : data as List<dynamic>;
      return items.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<int> getUnreadCount() async {
    final res = await _api.get(ApiConfig.unreadCount);
    if (res['success'] == true) {
      return (res['data'] as Map<String, dynamic>)['count'] as int? ?? 0;
    }
    return 0;
  }

  Future<void> markRead(int id) => _api.put(ApiConfig.markRead(id));
  Future<void> markAllRead() => _api.put(ApiConfig.markAllRead);
}

class ProfileService {
  final _api = ApiService.instance;

  Future<Map<String, dynamic>?> getProfile() async {
    final res = await _api.get('/profile');
    if (res['success'] == true) return res['data'] as Map<String, dynamic>;
    return null;
  }

  Future<({bool success, String? error})> updateProfile({
    required String fullName,
    String? avatarUrl,
  }) async {
    final res = await _api.put('/profile', data: {
      'fullName': fullName,
      'avatarUrl': avatarUrl,
    });
    if (res['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fullName', fullName);
      if (avatarUrl != null) {
        await prefs.setString('avatarUrl', avatarUrl);
      } else {
        await prefs.remove('avatarUrl');
      }
    }
    return (success: res['success'] == true, error: res['message'] as String?);
  }
}
