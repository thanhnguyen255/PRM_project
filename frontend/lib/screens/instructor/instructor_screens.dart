import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/viewmodels.dart';
import '../../widgets/widgets.dart';
import 'courses/manage_courses_screen.dart';
import 'evidence_review/evidence_detail_screen.dart';

import '../learner/notifications/notifications_screen.dart';
import '../learner/profile/profile_screen.dart';
import 'classes/manage_classes_screen.dart';
import 'classes/instructor_class_detail_screen.dart';
import 'learning_path/manage_learning_paths_screen.dart';
import 'activities/manage_activities_screen.dart';
import 'materials/materials_screen.dart';
import 'projects/manage_projects_screen.dart';
import 'review/instructor_review_screen.dart';
import 'analytics/class_analytics_screen.dart';
import 'analytics/student_progress_screen.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I01 — Instructor Dashboard Shell
// ════════════════════════════════════════════════════════════════════════════════
class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});
  @override
  State<InstructorDashboardScreen> createState() => _InstructorDashboardState();
}


class _InstructorDashboardState extends State<InstructorDashboardScreen> {
  int _currentIndex = 0;

  // One persistent nav key per possible tab (order: Dashboard, Courses, Evidence, Analytics)
  static const _allTabKeys = ['Dashboard', 'Courses', 'Evidence', 'Analytics'];
  final Map<String, GlobalKey<NavigatorState>> _navKeys = {
    'Dashboard': GlobalKey<NavigatorState>(),
    'Courses':   GlobalKey<NavigatorState>(),
    'Evidence':  GlobalKey<NavigatorState>(),
    'Analytics': GlobalKey<NavigatorState>(),
  };

  void _switchTab(int index) {
    if (_currentIndex == index) {
      final activeTabs = context.read<AuthViewModel>().instructorTabs;
      _navKeys[activeTabs[index]]?.currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  // ── Tab metadata ────────────────────────────────────────────────────────────
  static const _tabRoutes = {
    'Dashboard': '/dashboard-tab',
    'Courses':   '/courses-tab',
    'Evidence':  '/evidence-tab',
    'Analytics': '/analytics-tab',
  };
  static const _tabIcons = {
    'Dashboard': Icons.dashboard_rounded,
    'Courses':   Icons.school_rounded,
    'Evidence':  Icons.task_alt_rounded,
    'Analytics': Icons.bar_chart_rounded,
  };
  static const _tabLabels = {
    'Dashboard': 'Dashboard',
    'Courses':   'Khóa học',
    'Evidence':  'Evidence',
    'Analytics': 'Analytics',
  };

  // ── Customize dialog ────────────────────────────────────────────────────────
  void _showCustomizeDialog(BuildContext context, List<String> currentTabs) {
    // orderedItems: list of {key, visible}. Always has all 4 tabs.
    // Items in currentTabs are visible; the rest are hidden at the end.
    final hiddenTabs = _allTabKeys.where((k) => !currentTabs.contains(k)).toList();
    final orderedItems = [
      ...currentTabs.map((k) => {'key': k, 'visible': true}),
      ...hiddenTabs.map((k) => {'key': k, 'visible': false}),
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final activeCount = orderedItems.where((e) => e['visible'] == true).length;
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.tune_rounded, color: Color(0xFF6366F1)),
                SizedBox(width: 8),
                Flexible(
                  child: Text('Tuỳ chỉnh thanh điều hướng',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kéo ☰ để sắp xếp lại vị trí. Bật/tắt để ẩn/hiện tab.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 4 * 64.0,
                    child: ReorderableListView(
                      shrinkWrap: true,
                      onReorder: (oldIndex, newIndex) {
                        setS(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = orderedItems.removeAt(oldIndex);
                          orderedItems.insert(newIndex, item);
                        });
                      },
                      children: [
                        for (final entry in orderedItems)
                          _buildTabReorderItem(
                            key: ValueKey(entry['key']),
                            tabKey: entry['key'] as String,
                            isVisible: entry['visible'] as bool,
                            canToggle: entry['key'] != 'Dashboard' &&
                                (entry['visible'] == false || activeCount > 2),
                            onToggle: (v) {
                              if (entry['key'] == 'Dashboard') return;
                              if (!v && activeCount <= 2) return;
                              setS(() => entry['visible'] = v);
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hiển thị: $activeCount tab  •  Tối thiểu 2 tab',
                    style: TextStyle(
                      fontSize: 11,
                      color: activeCount < 2 ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Huỷ'),
              ),
              FilledButton(
                onPressed: activeCount < 2 ? null : () {
                  Navigator.pop(ctx);
                  final newTabs = orderedItems
                      .where((e) => e['visible'] == true)
                      .map((e) => e['key'] as String)
                      .toList();
                  // Keep current active tab if still present, else go to 0
                  final currentKey = currentTabs.length > _currentIndex
                      ? currentTabs[_currentIndex]
                      : 'Dashboard';
                  final newIndex = newTabs.indexOf(currentKey);
                  setState(() => _currentIndex = newIndex < 0 ? 0 : newIndex);
                  context.read<AuthViewModel>().updateInstructorTabs(newTabs);
                },
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                child: const Text('Lưu'),
              ),
            ],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        },
      ),
    );
  }

  Widget _buildTabReorderItem({
    required Key key,
    required String tabKey,
    required bool isVisible,
    required bool canToggle,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      key: key,
      height: 60,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isVisible
            ? const Color(0xFF6366F1).withValues(alpha: 0.06)
            : const Color(0xFF94A3B8).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isVisible
              ? const Color(0xFF6366F1).withValues(alpha: 0.2)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // Drag handle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.drag_handle_rounded, color: Color(0xFF94A3B8), size: 22),
          ),
          // Icon
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: isVisible
                  ? const Color(0xFF6366F1).withValues(alpha: 0.12)
                  : const Color(0xFF94A3B8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _tabIcons[tabKey],
              color: isVisible ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          // Label
          Expanded(
            child: Text(
              _tabLabels[tabKey]!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isVisible ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
              ),
            ),
          ),
          // Toggle switch
          Switch(
            value: isVisible,
            onChanged: canToggle ? onToggle : null,
            activeColor: const Color(0xFF6366F1),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final activeTabs = context.watch<AuthViewModel>().instructorTabs;

    // Clamp index in case tabs list shrank
    final safeIndex = _currentIndex.clamp(0, activeTabs.length - 1);
    if (safeIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = safeIndex);
      });
    }

    return Theme(
      data: AppTheme.instructorTheme,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (!didPop) {
            final key = activeTabs[_currentIndex];
            final nav = _navKeys[key]?.currentState;
            if (nav != null && nav.canPop()) nav.pop();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.instructorBackground,
          body: IndexedStack(
            index: _currentIndex,
            children: activeTabs.map((tab) => _TabNavigator(
              navigatorKey: _navKeys[tab]!,
              initialRoute: _tabRoutes[tab]!,
              onSwitchTab: _switchTab,
              onCustomizeNav: () => _showCustomizeDialog(context, activeTabs),
            )).toList(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _switchTab,
            destinations: activeTabs.map((tab) => NavigationDestination(
              icon: Icon(_tabIcons[tab]),
              label: _tabLabels[tab]!,
            )).toList(),
          ),
        ),
      ),
    );
  }
}



class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String initialRoute;
  final void Function(int) onSwitchTab;
  final VoidCallback onCustomizeNav;

  const _TabNavigator({
    required this.navigatorKey,
    required this.initialRoute,
    required this.onSwitchTab,
    required this.onCustomizeNav,
  });

  static Route<dynamic>? _p(Widget w, RouteSettings s) =>
      MaterialPageRoute(builder: (_) => w, settings: s);

  static int? _id(String n, String prefix) {
    final rest = n.replaceFirst(prefix, '').split('/').first.split('?').first;
    return int.tryParse(rest);
  }

  static int? _seg(String n, int i) {
    final segs = n.split('/').where((s) => s.isNotEmpty).toList();
    return segs.length > i ? int.tryParse(segs[i]) : null;
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';
    final args = settings.arguments as Map<String, dynamic>?;

    if (name == '/dashboard-tab') {
      return _p(_DashboardTab(onTabSelected: onSwitchTab, onCustomizeNav: onCustomizeNav), settings);
    }
    if (name == '/courses-tab') {
      return _p(const ManageCoursesTab(), settings);
    }
    if (name == '/evidence-tab') {
      return _p(const EvidenceListTab(), settings);
    }
    if (name == '/analytics-tab') {
      return _p(const InstructorAnalyticsTab(), settings);
    }

    if (name == '/notifications') {
      return _p(const NotificationsScreen(), settings);
    }
    if (name == '/profile') {
      return _p(const ProfileScreen(), settings);
    }
    if (name == '/edit-profile') {
      return _p(const EditProfileScreen(), settings);
    }

    // /instructor/evidence/:id
    if (name.startsWith('/instructor/evidence/')) {
      final id = _id(name, '/instructor/evidence/');
      if (id != null) return _p(EvidenceDetailScreen(evidenceId: id), settings);
    }

    // /instructor/courses/create
    if (name == '/instructor/courses/create') {
      return _p(const CreateEditCourseScreen(), settings);
    }

    // /instructor/courses/:id/edit
    if (name.contains('/edit') && name.startsWith('/instructor/courses/') && args != null) {
      final id = _seg(name, 2);
      if (id != null) {
        return _p(CreateEditCourseScreen(
          courseId: id,
          initialTitle: args['title'] as String?,
          initialDesc: args['description'] as String?,
        ), settings);
      }
    }

    // /instructor/courses/:id/classes
    if (name.contains('/classes') && name.startsWith('/instructor/courses/') && args != null) {
      final id = _seg(name, 2);
      if (id != null) {
        return _p(ManageClassesScreen(
          courseId: id,
          courseTitle: args['courseTitle'] as String? ?? '',
        ), settings);
      }
    }

    // /instructor/classes/:id
    if (name.startsWith('/instructor/classes/') &&
        !name.contains('/members') &&
        !name.contains('/paths') &&
        !name.contains('/projects')) {
      final id = _id(name, '/instructor/classes/');
      if (id != null) return _p(InstructorClassDetailScreen(classId: id), settings);
    }

    // /instructor/classes/:id/members
    if (name.startsWith('/instructor/classes/') && name.contains('/members')) {
      final id = _seg(name, 2);
      if (id != null) return _p(ClassMembersManageScreen(classId: id), settings);
    }

    // /instructor/classes/:id/paths
    if (name.startsWith('/instructor/classes/') && name.contains('/paths')) {
      final id = _seg(name, 2);
      if (id != null) return _p(ManageLearningPathsScreen(classId: id), settings);
    }

    // /instructor/paths/:id/activities
    if (name.startsWith('/instructor/paths/') && name.contains('/activities')) {
      final id = _seg(name, 2);
      if (id != null) return _p(ManageActivitiesScreen(pathId: id), settings);
    }

    // /instructor/paths/:id/materials
    if (name.startsWith('/instructor/paths/') && name.contains('/materials')) {
      final id = _seg(name, 2);
      if (id != null) return _p(ManageMaterialsScreen(pathId: id), settings);
    }

    // /instructor/classes/:id/projects
    if (name.startsWith('/instructor/classes/') && name.contains('/projects')) {
      final id = _seg(name, 2);
      if (id != null) return _p(ManageProjectsScreen(classId: id), settings);
    }

    // /instructor/review/:classId
    if (name.startsWith('/instructor/review/') && !name.contains('/monitor')) {
      final id = _id(name, '/instructor/review/');
      if (id != null) return _p(InstructorReviewScreen(classId: id), settings);
    }

    // /instructor/review/:sessionId/monitor
    if (name.startsWith('/instructor/review/') && name.contains('/monitor')) {
      final id = _seg(name, 2);
      if (id != null) return _p(ReviewMonitorScreen(sessionId: id), settings);
    }

    // /instructor/analytics/:classId
    if (name.startsWith('/instructor/analytics/')) {
      final id = _id(name, '/instructor/analytics/');
      if (id != null) return _p(ClassAnalyticsScreen(classId: id), settings);
    }

    // /instructor/students/:userId/progress
    if (name.startsWith('/instructor/students/') && name.contains('/progress') && args != null) {
      final userId = _seg(name, 2);
      if (userId != null) {
        return _p(StudentProgressAnalyticsScreen(
          userId: userId,
          classId: args['classId'] as int,
          studentName: args['studentName'] as String? ?? 'Học viên',
        ), settings);
      }
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
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────
class _DashboardTab extends StatefulWidget {
  final Function(int) onTabSelected;
  final VoidCallback onCustomizeNav;
  const _DashboardTab({required this.onTabSelected, required this.onCustomizeNav});
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
      context.read<EvidenceViewModel>().loadEvidencesByClass(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeVm     = context.watch<HomeViewModel>();
    final evidenceVm = context.watch<EvidenceViewModel>();

    return CustomScrollView(
      slivers: [
        // Header gradient
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1B4B), AppColors.primary],
              ),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  'Xin chào, GV ${homeVm.greeting} 👋',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text('Tổng quan hoạt động giảng dạy', style: TextStyle(fontSize: 13, color: Color(0xCCFFFFFF))),
              ])),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications').then((_) {
                  if (mounted) {
                    context.read<HomeViewModel>().init();
                  }
                }),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                    ),
                    if (homeVm.unreadCount > 0)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '${homeVm.unreadCount}',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onCustomizeNav,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                ),
              ),
            ]),
          ),
        ),

        // Stat cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Expanded(child: StatCard(value: '${homeVm.courses.length}', label: 'Lớp\nđang dạy', icon: Icons.groups_rounded)),
              const SizedBox(width: 10),
              Expanded(child: StatCard(
                value: '${evidenceVm.evidences.where((e) => e.status.toLowerCase() == 'pending').length}',
                label: 'Evidence\nchờ duyệt',
                color: AppColors.warning,
                icon: Icons.pending_actions_rounded,
              )),
              const SizedBox(width: 10),
              Expanded(child: StatCard(value: '0', label: 'Review\nchờ duyệt', color: AppColors.secondary, icon: Icons.rate_review_rounded)),
            ]),
          ),
        ),

        // Quick links
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionHeader(title: 'Truy cập nhanh'),
              const SizedBox(height: 8),
              Row(children: [
                _QuickLink('Quản lý\nKhóa học', Icons.book_rounded, AppColors.primary, () => widget.onTabSelected(1)),
                const SizedBox(width: 10),
                _QuickLink('Duyệt\nEvidence', Icons.task_alt_rounded, AppColors.warning, () => widget.onTabSelected(2)),
                const SizedBox(width: 10),
                _QuickLink('Tạo\nKhóa học', Icons.add_box_rounded, AppColors.secondary, () => Navigator.pushNamed(context, '/instructor/courses/create')),
                const SizedBox(width: 10),
                _QuickLink('Thống kê\nLớp học', Icons.bar_chart_rounded, AppColors.info, () => widget.onTabSelected(3)),
              ]),
            ]),
          ),
        ),

        // Recent courses
        if (homeVm.courses.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionHeader(title: 'Lớp đang dạy')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: homeVm.courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = homeVm.courses[i];
                return CourseCard(
                  title: c.title,
                  instructorName: c.instructorName,
                  coverImageUrl: c.coverImageUrl,
                  progressPercent: c.progressPercent,
                  onTap: () => Navigator.pushNamed(
                    context, '/instructor/courses/${c.id}/classes',
                    arguments: {'courseTitle': c.title},
                  ),
                );
              },
            ),
          ),
        ],

        // Pending evidence
        if (evidenceVm.evidences.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Evidence cần duyệt',
              actionLabel: 'Xem tất cả',
              onAction: () => widget.onTabSelected(2),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: evidenceVm.evidences.take(3).length,
              itemBuilder: (_, i) {
                final e = evidenceVm.evidences[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text(e.learnerName.isNotEmpty ? e.learnerName[0] : '?',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                    title: Text(e.learnerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(e.activityTitle, style: const TextStyle(fontSize: 12)),
                    trailing: StatusBadge(status: StatusBadge.fromString(e.status)),
                    onTap: () => Navigator.pushNamed(context, '/instructor/evidence/${e.id}').then((_) {
                      if (mounted) {
                        context.read<EvidenceViewModel>().loadEvidencesByClass(null);
                      }
                    }),
                  ),
                );
              },
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _QuickLink(String label, IconData icon, Color color, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}

// ─── Instructor Analytics Tab ──────────────────────────────────────────────────
class InstructorAnalyticsTab extends StatelessWidget {
  const InstructorAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final coursesWithClasses = homeVm.courses.where((c) => c.activeClassId != null).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Thống kê Lớp học')),
      body: homeVm.isLoading
          ? const LoadingWidget()
          : coursesWithClasses.isEmpty
              ? const EmptyState(
                  icon: Icons.bar_chart_outlined,
                  title: 'Chưa có lớp học',
                  message: 'Không có lớp học hoạt động nào để thống kê.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: coursesWithClasses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = coursesWithClasses[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppColors.info.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.analytics_rounded, color: AppColors.info, size: 24),
                          ),
                          title: Text(c.activeClassName ?? 'Lớp học', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Khóa học: ${c.title}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/instructor/analytics/${c.activeClassId}',
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// EvidenceDetailScreen → screens/instructor/evidence_review/evidence_detail_screen.dart
