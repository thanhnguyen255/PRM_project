import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  // ── Base URL ───────────────────────────────────────────────────────────────
  static const String _pcIpAddress = '192.168.1.15';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5111/api';

    if (Platform.isAndroid) {
      // 1. Chạy trên thiết bị Android thật bằng cáp USB (đã chạy adb reverse tcp:5111 tcp:5111):
      return 'http://localhost:5111/api';

      // 2. Chạy trên máy ảo Android (Emulator) thông thường:
      // return 'http://10.0.2.2:5111/api';

      // 3. Chạy qua mạng Wi-Fi cục bộ không dùng cáp:
      // return 'http://$_pcIpAddress:5111/api';
    }

    // Mặc định cho iOS Simulator, Desktop, Web và các nền tảng khác
    return 'http://localhost:5111/api';
  }

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login    = '/auth/login';
  static const String register = '/auth/register';
  static const String me       = '/users/me';
  static const String updateMe = '/users/me';

  // ── Courses ────────────────────────────────────────────────────────────────
  static const String myCourses  = '/courses/my';
  static String courseDetail(int id) => '/courses/$id';
  static const String createCourse = '/courses';
  static String updateCourse(int id) => '/courses/$id';
  static String deleteCourse(int id) => '/courses/$id';

  // ── Classes ────────────────────────────────────────────────────────────────
  static const String myClasses                = '/classes/my';
  static String classesByCourse(int courseId) => '/classes?courseId=$courseId';
  static String classDetail(int id)            => '/classes/$id';
  static const String createClass              = '/classes';
  static String updateClass(int id)            => '/classes/$id';
  static String deleteClass(int id)            => '/classes/$id';
  static String classMembers(int id)           => '/classes/$id/members';
  static String removeMember(int classId, int userId) => '/classes/$classId/members/$userId';


  // ── Learning Paths ─────────────────────────────────────────────────────────
  static String learningPaths(int classId) => '/learning-paths?classId=$classId';
  static String learningPathDetail(int id)  => '/learning-paths/$id';
  static const String createLearningPath    = '/learning-paths';
  static String updateLearningPath(int id)  => '/learning-paths/$id';
  static String deleteLearningPath(int id)  => '/learning-paths/$id';

  // ── Materials ──────────────────────────────────────────────────────────────
  static String materials(int pathId) => '/materials?pathId=$pathId';
  static String materialDetail(int id) => '/materials/$id';
  static const String createMaterial   = '/materials';
  static String updateMaterial(int id) => '/materials/$id';
  static String deleteMaterial(int id) => '/materials/$id';

  // ── Activities ─────────────────────────────────────────────────────────────
  static String activities(int pathId, {String? type}) =>
      '/activities?pathId=$pathId${type != null ? '&type=$type' : ''}';
  static String activityDetail(int id)   => '/activities/$id';
  static String upcomingActivities(int classId, {int limit = 5}) =>
      '/activities/upcoming?classId=$classId&limit=$limit';
  static const String createActivity     = '/activities';
  static String updateActivity(int id)   => '/activities/$id';
  static String deleteActivity(int id)   => '/activities/$id';

  // ── Evidences ──────────────────────────────────────────────────────────────
  static const String evidences          = '/evidences';
  static String evidencesByClass(int? classId, {String? status}) =>
      '/evidences?${classId != null ? 'classId=$classId' : ''}${status != null ? '&status=$status' : ''}';
  static String evidencesByActivity(int activityId) =>
      '/evidences?activityId=$activityId&userId=me';
  static String evidenceDetail(int id)   => '/evidences/$id';
  static String approveEvidence(int id)  => '/evidences/$id/approve';
  static String rejectEvidence(int id)   => '/evidences/$id/reject';
  static String evidenceComments(int id) => '/evidences/$id/comments';
  static const String pendingCount       = '/evidences/pending-count';

  // ── Projects & Milestones ──────────────────────────────────────────────────
  static String projects(int classId)    => '/projects?classId=$classId';
  static String projectDetail(int id)    => '/projects/$id';
  static const String createProject      = '/projects';
  static String updateProject(int id)    => '/projects/$id';
  static String deleteProject(int id)    => '/projects/$id';

  static String milestones(int projectId) => '/milestones?projectId=$projectId';
  static String milestoneDetail(int id)   => '/milestones/$id';
  static const String createMilestone     = '/milestones';
  static String updateMilestone(int id)   => '/milestones/$id';
  static String deleteMilestone(int id)   => '/milestones/$id';

  static String milestoneSubmission(int milestoneId) =>
      '/milestone-submissions?milestoneId=$milestoneId&userId=me';
  static const String submitMilestone = '/milestone-submissions';

  // ── Reviews & Feedback ─────────────────────────────────────────────────────
  static String reviewSessions(int classId)     => '/review-sessions?classId=$classId';
  static String reviewSessionDetail(int id)      => '/review-sessions/$id';
  static const String createReviewSession        = '/review-sessions';
  static String deleteReviewSession(int id)      => '/review-sessions/$id';

  static String myAssignments(int sessionId) =>
      '/review-assignments?sessionId=$sessionId&reviewerId=me';
  static String allAssignments(int sessionId) =>
      '/review-assignments?sessionId=$sessionId';

  static const String createFeedback            = '/feedbacks';
  static String receivedFeedback(int sessionId) => '/feedbacks/received?sessionId=$sessionId';
  static String sessionFeedbacks(int sessionId) => '/feedbacks?sessionId=$sessionId';

  // ── Analytics ──────────────────────────────────────────────────────────────
  static const String myProgress                = '/analytics/my-progress';
  static String classAnalytics(int classId)     => '/analytics/class/$classId';
  static String studentAnalytics(int userId, int classId) =>
      '/analytics/student/$userId?classId=$classId';

  // ── Notifications ──────────────────────────────────────────────────────────
  static const String notifications             = '/notifications';
  static const String unreadCount               = '/notifications/unread-count';
  static String markRead(int id)                => '/notifications/$id/read';
  static const String markAllRead               = '/notifications/read-all';
}
