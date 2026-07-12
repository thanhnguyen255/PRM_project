import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'config/app_colors.dart';
import 'services/api_service.dart';
import 'viewmodels/viewmodels.dart';
import 'viewmodels/extended_viewmodels.dart';

// Screens — Auth
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

// Learner — Home
import 'screens/learner/home_screen.dart';

// Learner — Notifications
import 'screens/learner/notifications/notifications_screen.dart';

// Learner — Classes
import 'screens/learner/classes/class_detail_screen.dart';
import 'screens/learner/classes/members_screen.dart';

// Learner — Courses
import 'screens/learner/course/course_screen.dart';
import 'screens/learner/course/course_detail_screen.dart';

// Learner — Learning Paths
import 'screens/learner/learning_path/learning_path_overview_screen.dart';
import 'screens/learner/learning_path/learning_path_screen.dart';

// Learner — Activities
import 'screens/learner/activities/activity_list_screen.dart';
import 'screens/learner/activities/activity_screens.dart';

// Learner — Evidence
import 'screens/learner/evidence/evidence_screens.dart';
import 'screens/learner/evidence/submit_evidence_screen.dart';
import 'screens/learner/evidence/evidence_comments_screen.dart';

// Learner — Projects
import 'screens/learner/projects/project_screens.dart';

// Learner — Review
import 'screens/learner/review/review_screens.dart';

// Learner — Progress, Profile, Materials, Media
import 'screens/learner/progress/progress_screen.dart';
import 'screens/learner/profile/profile_screen.dart';
import 'screens/learner/materials/materials_screen.dart';
import 'screens/learner/materials/material_detail_screen.dart';
import 'screens/learner/materials/video_player_screen.dart';
import 'screens/learner/materials/document_viewer_screen.dart';
import 'screens/learner/activities/pre_class_list_screen.dart';
import 'screens/learner/activities/pre_class_detail_screen.dart';

import 'screens/learner/activities/in_class/in_class_list_screen.dart';
import 'screens/learner/activities/in_class/in_class_detail_screen.dart';
import 'screens/learner/activities/post_class/post_class_list_screen.dart';
import 'screens/learner/activities/post_class/post_class_detail_screen.dart';
// Screens — Instructor
import 'screens/instructor/instructor_screens.dart';
import 'screens/instructor/courses/manage_courses_screen.dart';
import 'screens/instructor/classes/manage_classes_screen.dart';
import 'screens/instructor/learning_path/manage_learning_paths_screen.dart';
import 'screens/instructor/activities/manage_activities_screen.dart';
import 'screens/instructor/projects/manage_projects_screen.dart';
import 'screens/instructor/review/instructor_review_screen.dart';
import 'screens/instructor/analytics/class_analytics_screen.dart';
import 'screens/instructor/evidence_review/evidence_detail_screen.dart';
import 'screens/instructor/materials/materials_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.instance.init();
  runApp(const FlippedClassroomApp());
}

class FlippedClassroomApp extends StatelessWidget {
  const FlippedClassroomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => CourseViewModel()),
        ChangeNotifierProvider(create: (_) => ClassViewModel()),
        ChangeNotifierProvider(create: (_) => LearningPathViewModel()),
        ChangeNotifierProvider(create: (_) => ActivityViewModel()),
        ChangeNotifierProvider(create: (_) => EvidenceViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        // Extended
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
        ChangeNotifierProvider(create: (_) => MaterialViewModel()),
        ChangeNotifierProvider(create: (_) => ExtendedActivityViewModel()),
        ChangeNotifierProvider(create: (_) => InstructorManageViewModel()),
      ],
      child: MaterialApp(
        title: 'Flipped Classroom',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: '/login',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  static Route<dynamic>? _generateRoute(RouteSettings settings) {
    final name = settings.name ?? '';
    final args = settings.arguments as Map<String, dynamic>?;

    // ── Auth ─────────────────────────────────────────────────────────────────
    if (name == '/splash') return _page(const SplashScreen(), settings);
    if (name == '/login') return _page(const LoginScreen(), settings);
    if (name == '/register') return _page(const RegisterScreen(), settings);
    if (name == '/forgot-password')
      return _page(const ForgotPasswordScreen(), settings);

    // Link from LoginScreen
    // /login → /forgot-password

    // ── Learner Core ──────────────────────────────────────────────────────────
    if (name == '/home') return _page(const HomeScreen(), settings);
    if (name == '/notifications')
      return _page(const NotificationsScreen(), settings);

    // /courses/:id
    if (_matches(name, '/courses/') &&
        !name.contains('/classes') &&
        !name.contains('/edit')) {
      final id = _parseId(name, '/courses/');
      if (id != null)
        return _page(LearnerCourseDetailScreen(courseId: id), settings);
    }

    // /classes/:id
    if (_matchesExact(name, r'^/classes/\d+$')) {
      final id = _parseLastSegment(name);
      if (id != null) return _page(ClassDetailScreen(classId: id), settings);
    }

    // /classes/:id/members
    if (name.contains('/members') && name.startsWith('/classes/')) {
      final id = _parseSegment(name, 1);
      if (id != null) return _page(MembersScreen(classId: id), settings);
    }

    // /classes/:id/learning-path
    if (name.contains('/learning-path') && name.startsWith('/classes/')) {
      final id = _parseSegment(name, 1);
      if (id != null) return _page(LearningPathScreen(classId: id), settings);
    }

    // /paths/:id → Week Detail
    if (_matches(name, '/paths/') &&
        !name.contains('/activities') &&
        !name.contains('/materials')) {
      final id = _parseId(name, '/paths/');
      // Also support new subfolder LearningPathDetailScreen
      if (id != null)
        return _page(LearningPathDetailScreen(pathId: id), settings);
    }

    // /paths/:id/materials
    if (name.contains('/materials') && _matches(name, '/paths/')) {
      final id = _parseSegment(name, 1);
      if (id != null) return _page(MaterialsScreen(pathId: id), settings);
    }

    // /activities/:id/materials
    if (name.contains('/materials') && _matches(name, '/activities/')) {
      final id = _parseSegment(name, 1);
      // Not typically used with pathId now, but keeping if needed (though materials uses pathId)
      // We updated MaterialsScreen to take pathId. If this is activities/id/materials, this route might be obsolete.
    }

    // /learning-paths/:id
    if (_matches(name, '/learning-paths/')) {
      final id = _parseId(name, '/learning-paths/');
      if (id != null)
        return _page(LearningPathDetailScreen(pathId: id), settings);
    }

    // /activities?pathId=X&type=Y
    if (name.startsWith('/activities') && name.contains('?')) {
      final uri = Uri.parse(name);
      final pathId = int.tryParse(uri.queryParameters['pathId'] ?? '');
      final type = uri.queryParameters['type'] ?? 'PreClass';
      if (pathId != null)
        return _page(ActivityListScreen(pathId: pathId, type: type), settings);
    }

    // /activities/:id — route by type from args
    if (_matches(name, '/activities/') && !name.contains('/materials')) {
      final id = _parseId(name, '/activities/');
      if (id != null) {
        final type = args?['type'] as String? ?? 'PreClass';
        if (type == 'InClass')
          return _page(InClassActivityScreen(activityId: id), settings);
        if (type == 'PostClass')
          return _page(PostClassActivityScreen(activityId: id), settings);
        return _page(PreClassActivityScreen(activityId: id), settings);
      }
    }

    // /submit-evidence
    if (name == '/submit-evidence' && args != null) {
      return _page(
        SubmitEvidenceScreen(
          activityId: args['activityId'] as int,
          activityTitle: args['activityTitle'] as String? ?? '',
        ),
        settings,
      );
    }

    // /video-player
    if (name == '/video-player' && args != null) {
      return _page(
        VideoPlayerScreen(
          url: args['url'] as String,
          title: args['title'] as String? ?? 'Video',
        ),
        settings,
      );
    }

    // /document-viewer
    if (name == '/document-viewer' && args != null) {
      return _page(
        DocumentViewerScreen(
          url: args['url'] as String,
          title: args['title'] as String? ?? 'Tài liệu',
        ),
        settings,
      );
    }

    // /material-detail
    if (name == '/material-detail' && args != null) {
      return _page(
        MaterialDetailScreen(materialId: args['id'] as int),
        settings,
      );
    }

    // /pre-class-list
    if (name == '/pre-class-list' && args != null) {
      return _page(
        PreClassListScreen(pathId: args['id'] as int),
        settings,
      );
    }

    // /pre-class-detail
    if (name == '/pre-class-detail' && args != null) {
      return _page(
        PreClassDetailScreen(activityId: args['id'] as int),
        settings,
      );
    }

    // /in-class-list
    if (name == '/in-class-list' && args != null) {
      return _page(InClassListScreen(pathId: args['id'] as int), settings);
    }

    // /in-class-detail
    if (name == '/in-class-detail' && args != null) {
      return _page(InClassDetailScreen(activityId: args['id'] as int), settings);
    }

    // /post-class-list
    if (name == '/post-class-list' && args != null) {
      return _page(PostClassListScreen(pathId: args as int), settings);
    }

    // /post-class-detail
    if (name == '/post-class-detail' && args != null) {
      return _page(PostClassDetailScreen(activityId: args as int), settings);
    }

    // /evidences/:id
    if (_matchesExact(name, r'^/evidences/\d+$')) {
      final id = _parseLastSegment(name);
      if (id != null)
        return _page(LearnerEvidenceDetailScreen(evidenceId: id), settings);
    }

    // /evidences/:id/comments
    if (name.contains('/comments') && _matches(name, '/evidences/')) {
      final id = _parseSegment(name, 1);
      if (id != null)
        return _page(EvidenceCommentsScreen(evidenceId: id), settings);
    }

    // /projects
    if (name == '/projects' && args != null) {
      final classId = args['classId'] as int;
      return _page(LearnerProjectsScreen(classId: classId), settings);
    }

    // /projects/:id
    if (_matchesExact(name, r'^/projects/\d+$')) {
      final id = _parseLastSegment(name);
      if (id != null)
        return _page(LearnerProjectDetailScreen(projectId: id), settings);
    }

    // /milestones/:id
    if (_matches(name, '/milestones/')) {
      final id = _parseId(name, '/milestones/');
      if (id != null)
        return _page(MilestoneDetailScreen(milestoneId: id), settings);
    }

    // /review-sessions
    if (name == '/review-sessions' && args != null) {
      return _page(
        ReviewSessionsScreen(classId: args['classId'] as int),
        settings,
      );
    }

    // /review-sessions/:id
    if (_matchesExact(name, r'^/review-sessions/\d+$')) {
      final id = _parseLastSegment(name);
      if (id != null) return _page(ReviewDetailScreen(sessionId: id), settings);
    }

    // /submit-feedback
    if (name == '/submit-feedback' && args != null) {
      return _page(
        SubmitFeedbackScreen(
          assignmentId: args['assignmentId'] as int,
          revieweeName: args['revieweeName'] as String? ?? '',
        ),
        settings,
      );
    }

    // /progress
    if (name == '/progress') {
      return _page(ProgressScreen(classId: args?['classId'] as int?), settings);
    }

    // /profile
    if (name == '/profile')
      return _page(const ProfileScreen(), settings);

    // /edit-profile
    if (name == '/edit-profile')
      return _page(const EditProfileScreen(), settings);

    // ── Instructor ────────────────────────────────────────────────────────────
    if (name == '/instructor/dashboard')
      return _page(const InstructorDashboardScreen(), settings);

    // /instructor/evidence/:id
    if (_matches(name, '/instructor/evidence/')) {
      final id = _parseId(name, '/instructor/evidence/');
      if (id != null)
        return _page(EvidenceDetailScreen(evidenceId: id), settings);
    }

    // /instructor/courses/create
    if (name == '/instructor/courses/create')
      return _page(const CreateEditCourseScreen(), settings);

    // /instructor/courses/:id/edit
    if (name.contains('/edit') &&
        _matches(name, '/instructor/courses/') &&
        args != null) {
      final id = _parseSegment(name, 2);
      return _page(
        CreateEditCourseScreen(
          courseId: id,
          initialTitle: args['title'] as String?,
          initialDesc: args['description'] as String?,
        ),
        settings,
      );
    }

    // /instructor/courses/:id/classes
    if (name.contains('/classes') &&
        _matches(name, '/instructor/courses/') &&
        args != null) {
      final id = _parseSegment(name, 2);
      if (id != null)
        return _page(
          ManageClassesScreen(
            courseId: id,
            courseTitle: args['courseTitle'] as String? ?? '',
          ),
          settings,
        );
    }

    // /instructor/classes/:id
    if (_matches(name, '/instructor/classes/') &&
        !name.contains('/members') &&
        !name.contains('/paths')) {
      final id = _parseId(name, '/instructor/classes/');
      if (id != null) return _page(ClassDetailScreen(classId: id), settings);
    }

    // /instructor/classes/:id/members
    if (_matches(name, '/instructor/classes/') && name.contains('/members')) {
      final id = _parseSegment(name, 2);
      if (id != null)
        return _page(ClassMembersManageScreen(classId: id), settings);
    }

    // /instructor/classes/:id/paths
    if (_matches(name, '/instructor/classes/') && name.contains('/paths')) {
      final id = _parseSegment(name, 2);
      if (id != null)
        return _page(ManageLearningPathsScreen(classId: id), settings);
    }

    // /instructor/paths/:id/activities
    if (_matches(name, '/instructor/paths/') && name.contains('/activities')) {
      final id = _parseSegment(name, 2);
      if (id != null)
        return _page(ManageActivitiesScreen(pathId: id), settings);
    }

    // /instructor/paths/:id/materials
    if (_matches(name, '/instructor/paths/') && name.contains('/materials')) {
      final id = _parseSegment(name, 2);
      if (id != null)
        return _page(ManageMaterialsScreen(pathId: id), settings);
    }

    // /instructor/classes/:id/projects
    if (_matches(name, '/instructor/classes/') && name.contains('/projects')) {
      final id = _parseSegment(name, 2);
      if (id != null) return _page(ManageProjectsScreen(classId: id), settings);
    }

    // /instructor/review/:classId
    if (_matches(name, '/instructor/review/') && !name.contains('/monitor')) {
      final id = _parseId(name, '/instructor/review/');
      if (id != null)
        return _page(InstructorReviewScreen(classId: id), settings);
    }

    // /instructor/review/:sessionId/monitor
    if (_matches(name, '/instructor/review/') && name.contains('/monitor')) {
      final id = _parseSegment(name, 2);
      if (id != null)
        return _page(ReviewMonitorScreen(sessionId: id), settings);
    }

    // /instructor/analytics/:classId
    if (_matches(name, '/instructor/analytics/')) {
      final id = _parseId(name, '/instructor/analytics/');
      if (id != null) return _page(ClassAnalyticsScreen(classId: id), settings);
    }

    // 404
    return _page(_NotFoundScreen(path: name), settings);
  }

  // Helpers
  static bool _matches(String name, String prefix) => name.startsWith(prefix);
  static bool _matchesExact(String name, String pattern) =>
      RegExp(pattern).hasMatch(name);

  static int? _parseId(String name, String prefix) {
    final rest = name
        .replaceFirst(prefix, '')
        .split('/')
        .first
        .split('?')
        .first;
    return int.tryParse(rest);
  }

  static int? _parseLastSegment(String name) {
    final segments = name.split('/').where((s) => s.isNotEmpty).toList();
    return int.tryParse(segments.last);
  }

  static int? _parseSegment(String name, int index) {
    final segments = name.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length > index) return int.tryParse(segments[index]);
    return null;
  }

  static MaterialPageRoute _page(Widget w, RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => w, settings: settings);
}

// ─── Screens ─────────────────────────────────────────────────────────────────
class _NotFoundScreen extends StatelessWidget {
  final String path;
  const _NotFoundScreen({required this.path});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Không tìm thấy')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            '404',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trang "$path" không tồn tại',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
        ],
      ),
    ),
  );
}
