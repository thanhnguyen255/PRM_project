import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/viewmodels.dart';

import 'home_screen.dart';
import 'profile/profile_screen.dart';
import 'progress/progress_screen.dart';
import 'notifications/notifications_screen.dart';
import 'classes/class_detail_screen.dart';
import 'classes/members_screen.dart';
import 'course/course_detail_screen.dart';
import 'learning_path/learning_path_overview_screen.dart';
import 'learning_path/learning_path_screen.dart';
import 'activities/activity_list_screen.dart';
import 'activities/activity_screens.dart';
import 'activities/pre_class_list_screen.dart';
import 'activities/pre_class_detail_screen.dart';
import 'activities/in_class/in_class_list_screen.dart';
import 'activities/in_class/in_class_detail_screen.dart';
import 'activities/post_class/post_class_list_screen.dart';
import 'activities/post_class/post_class_detail_screen.dart';
import 'evidence/evidence_screens.dart';
import 'evidence/submit_evidence_screen.dart';
import 'evidence/evidence_comments_screen.dart';
import 'projects/project_screens.dart';
import 'projects/milestone_list_screen.dart';
import 'projects/milestone_detail_screen.dart';
import 'review/review_screens.dart';
import 'materials/materials_screen.dart';
import 'materials/material_detail_screen.dart';
import 'materials/video_player_screen.dart';
import 'materials/document_viewer_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
// LearnerShell — Persistent BottomNav wrapper for SCR-L05 to SCR-L41
// ══════════════════════════════════════════════════════════════════════════════
class LearnerShell extends StatefulWidget {
  const LearnerShell({super.key});
  @override
  State<LearnerShell> createState() => _LearnerShellState();
}

class _LearnerShellState extends State<LearnerShell> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navKeys = [
    GlobalKey<NavigatorState>(), // 0 - Home
    GlobalKey<NavigatorState>(), // 1 - Courses
    GlobalKey<NavigatorState>(), // 2 - Progress
    GlobalKey<NavigatorState>(), // 3 - Profile
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
    });
  }

  void _switchTab(int index) {
    if (_currentIndex == index) {
      _navKeys[index].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.learnerTheme,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (!didPop) {
            final nav = _navKeys[_currentIndex].currentState;
            if (nav != null && nav.canPop()) nav.pop();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _TabNavigator(navigatorKey: _navKeys[0], initialRoute: '/home-tab', onSwitchTab: _switchTab),
              _TabNavigator(navigatorKey: _navKeys[1], initialRoute: '/courses-tab', onSwitchTab: _switchTab),
              _TabNavigator(navigatorKey: _navKeys[2], initialRoute: '/progress-tab', onSwitchTab: _switchTab),
              _TabNavigator(navigatorKey: _navKeys[3], initialRoute: '/profile-tab', onSwitchTab: _switchTab),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _switchTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textHint,
            backgroundColor: AppColors.surface,
            elevation: 12,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Courses'),
              BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Progress'),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── _TabNavigator ─────────────────────────────────────────────────────────────
class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String initialRoute;
  final void Function(int) onSwitchTab;

  const _TabNavigator({
    required this.navigatorKey,
    required this.initialRoute,
    required this.onSwitchTab,
  });

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';
    final args = settings.arguments as Map<String, dynamic>?;

    // Tab roots
    if (name == '/home-tab') return _p(HomeTab(onViewAllCourses: () => onSwitchTab(1)), settings);
    if (name == '/courses-tab') return _p(const CoursesTab(), settings);
    if (name == '/progress-tab') return _p(const ProgressScreen(), settings);
    if (name == '/profile-tab') return _p(const ProfileScreen(), settings);

    // Notifications
    if (name == '/notifications') return _p(const NotificationsScreen(), settings);

    // Courses
    if (name.startsWith('/courses/') && !name.contains('/classes') && !name.contains('/edit')) {
      final id = _id(name, '/courses/');
      if (id != null) return _p(LearnerCourseDetailScreen(courseId: id), settings);
    }

    // Classes
    if (RegExp(r'^/classes/\d+$').hasMatch(name)) {
      final id = _last(name);
      if (id != null) return _p(ClassDetailScreen(classId: id), settings);
    }
    if (name.contains('/members') && name.startsWith('/classes/')) {
      final id = _seg(name, 1);
      if (id != null) return _p(MembersScreen(classId: id), settings);
    }
    if (name.contains('/learning-path') && name.startsWith('/classes/')) {
      final id = _seg(name, 1);
      if (id != null) return _p(LearningPathScreen(classId: id), settings);
    }

    // Learning Paths
    if (name.startsWith('/paths/') && !name.contains('/activities') && !name.contains('/materials')) {
      final id = _id(name, '/paths/');
      if (id != null) return _p(LearningPathDetailScreen(pathId: id), settings);
    }
    if (name.contains('/materials') && name.startsWith('/paths/')) {
      final id = _seg(name, 1);
      if (id != null) return _p(MaterialsScreen(pathId: id), settings);
    }
    if (name.startsWith('/learning-paths/')) {
      final id = _id(name, '/learning-paths/');
      if (id != null) return _p(LearningPathDetailScreen(pathId: id), settings);
    }

    // Activities list
    if (name.startsWith('/activities') && name.contains('?')) {
      final uri = Uri.parse(name);
      final pathId = int.tryParse(uri.queryParameters['pathId'] ?? '');
      final type = uri.queryParameters['type'] ?? 'PreClass';
      if (pathId != null) return _p(ActivityListScreen(pathId: pathId, type: type), settings);
    }
    if (name.startsWith('/activities/') && !name.contains('/materials')) {
      final id = _id(name, '/activities/');
      if (id != null) {
        final type = args?['type'] as String? ?? 'PreClass';
        if (type == 'InClass') return _p(InClassActivityScreen(activityId: id), settings);
        if (type == 'PostClass') return _p(PostClassActivityScreen(activityId: id), settings);
        return _p(PreClassActivityScreen(activityId: id), settings);
      }
    }

    // Activity sub-screens
    if (name == '/pre-class-list' && args != null)
      return _p(PreClassListScreen(pathId: args['id'] as int), settings);
    if (name == '/pre-class-detail' && args != null)
      return _p(PreClassDetailScreen(activityId: args['id'] as int), settings);
    if (name == '/in-class-list' && args != null)
      return _p(InClassListScreen(pathId: args['id'] as int), settings);
    if (name == '/in-class-detail' && args != null)
      return _p(InClassDetailScreen(activityId: args['id'] as int), settings);
    if (name == '/post-class-list' && args != null)
      return _p(PostClassListScreen(pathId: args['id'] as int), settings);
    if (name == '/post-class-detail' && args != null)
      return _p(PostClassDetailScreen(activityId: args['id'] as int), settings);

    // Evidence
    if (name == '/submit-evidence' && args != null) {
      return _p(SubmitEvidenceScreen(
        activityId: args['activityId'] as int,
        activityTitle: args['activityTitle'] as String? ?? '',
      ), settings);
    }
    if (RegExp(r'^/evidences/\d+$').hasMatch(name)) {
      final id = _last(name);
      if (id != null) return _p(LearnerEvidenceDetailScreen(evidenceId: id), settings);
    }
    if (name.contains('/comments') && name.startsWith('/evidences/')) {
      final id = _seg(name, 1);
      if (id != null) return _p(EvidenceCommentsScreen(evidenceId: id), settings);
    }

    // Projects
    if (name == '/projects' && args != null)
      return _p(LearnerProjectsScreen(classId: args['classId'] as int), settings);
    if (RegExp(r'^/projects/\d+$').hasMatch(name)) {
      final id = _last(name);
      if (id != null) return _p(LearnerProjectDetailScreen(projectId: id), settings);
    }
    if (name.contains('/milestones') && name.startsWith('/projects/')) {
      final id = _seg(name, 1);
      if (id != null) return _p(MilestoneListScreen(projectId: id), settings);
    }
    if (name.startsWith('/milestones/')) {
      final id = _id(name, '/milestones/');
      if (id != null) return _p(MilestoneDetailScreen(milestoneId: id), settings);
    }

    // Review
    if (name == '/review-sessions' && args != null)
      return _p(ReviewSessionsScreen(classId: args['classId'] as int), settings);
    if (RegExp(r'^/review-sessions/\d+$').hasMatch(name)) {
      final id = _last(name);
      if (id != null) return _p(ReviewDetailScreen(sessionId: id), settings);
    }
    if (name == '/submit-feedback' && args != null) {
      return _p(SubmitFeedbackScreen(
        assignment: args['assignment'] as Map<String, dynamic>,
      ), settings);
    }

    // Progress & Profile
    if (name == '/progress')
      return _p(ProgressScreen(classId: args?['classId'] as int?), settings);
    if (name == '/profile') return _p(const ProfileScreen(), settings);
    if (name == '/edit-profile') return _p(const EditProfileScreen(), settings);

    // Materials / Media
    if (name == '/material-detail' && args != null)
      return _p(MaterialDetailScreen(materialId: args['id'] as int), settings);
    if (name == '/video-player' && args != null) {
      return _p(VideoPlayerScreen(
        url: args['url'] as String,
        title: args['title'] as String? ?? 'Video',
      ), settings);
    }
    if (name == '/document-viewer' && args != null) {
      return _p(DocumentViewerScreen(
        url: args['url'] as String,
        title: args['title'] as String? ?? 'Tai lieu',
      ), settings);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: initialRoute,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static int? _id(String n, String prefix) {
    final rest = n.replaceFirst(prefix, '').split('/').first.split('?').first;
    return int.tryParse(rest);
  }
  static int? _last(String n) {
    final segs = n.split('/').where((s) => s.isNotEmpty).toList();
    return int.tryParse(segs.last);
  }
  static int? _seg(String n, int i) {
    final segs = n.split('/').where((s) => s.isNotEmpty).toList();
    return segs.length > i ? int.tryParse(segs[i]) : null;
  }
  static MaterialPageRoute _p(Widget w, RouteSettings s) =>
      MaterialPageRoute(builder: (_) => w, settings: s);
}
