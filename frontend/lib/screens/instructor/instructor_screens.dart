import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../viewmodels/viewmodels.dart';
import '../../widgets/widgets.dart';
import 'courses/manage_courses_screen.dart';
import 'evidence_review/evidence_detail_screen.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I01 — Instructor Dashboard
// ════════════════════════════════════════════════════════════════════════════════
class InstructorDashboardScreen extends StatefulWidget {
  const InstructorDashboardScreen({super.key});
  @override
  State<InstructorDashboardScreen> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(onTabSelected: (i) => setState(() => _currentIndex = i)),
          const ManageCoursesTab(),
          const EvidenceListTab(),
          const InstructorAnalyticsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.school_rounded), label: 'Khóa học'),
          NavigationDestination(icon: Icon(Icons.task_alt_rounded), label: 'Evidence'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Analytics'),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────
class _DashboardTab extends StatefulWidget {
  final Function(int) onTabSelected;
  const _DashboardTab({required this.onTabSelected});
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
                    );
                  },
                ),
    );
  }
}

// EvidenceDetailScreen → screens/instructor/evidence_review/evidence_detail_screen.dart
