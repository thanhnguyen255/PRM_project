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
          _DashboardTab(onTabChanged: (i) => setState(() => _currentIndex = i)),
          const ManageCoursesTab(),
          const EvidenceListTab(),
          const _AnalyticsTab(),
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
  final Function(int) onTabChanged;
  const _DashboardTab({required this.onTabChanged});
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().init();
      context.read<EvidenceViewModel>().loadEvidencesByClass(1);
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
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
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
              Expanded(child: StatCard(value: '${evidenceVm.evidences.length}', label: 'Evidence\nchờ duyệt', color: AppColors.warning, icon: Icons.pending_actions_rounded)),
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
                _QuickLink('Quản lý\nKhóa học', Icons.book_rounded, AppColors.primary, () => widget.onTabChanged(1)),
                const SizedBox(width: 10),
                _QuickLink('Duyệt\nEvidence', Icons.task_alt_rounded, AppColors.warning, () => widget.onTabChanged(2)),
                const SizedBox(width: 10),
                _QuickLink('Peer\nReview', Icons.rate_review_rounded, AppColors.secondary, () => Navigator.pushNamed(context, '/instructor/review/1')),
                const SizedBox(width: 10),
                _QuickLink('Analytics', Icons.bar_chart_rounded, AppColors.info, () => Navigator.pushNamed(context, '/instructor/analytics/1')),
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
              separatorBuilder: (_, __) => const SizedBox(height: 10),
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
              onAction: () => widget.onTabChanged(2),
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
                    onTap: () => Navigator.pushNamed(context, '/instructor/evidence/${e.id}'),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}

// ─── Placeholder tabs (real implementations in subfolders) ────────────────────
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('→ analytics/class_analytics_screen.dart', style: TextStyle(color: AppColors.textHint)),
  );
}

// EvidenceDetailScreen → screens/instructor/evidence_review/evidence_detail_screen.dart
