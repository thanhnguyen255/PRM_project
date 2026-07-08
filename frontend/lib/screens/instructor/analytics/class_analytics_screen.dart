import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I20/I21 — Learning Analytics (Class Overview + Per-Student)
// ════════════════════════════════════════════════════════════════════════════════
class ClassAnalyticsScreen extends StatefulWidget {
  final int classId;
  const ClassAnalyticsScreen({super.key, required this.classId});
  @override
  State<ClassAnalyticsScreen> createState() => _ClassAnalyticsScreenState();
}

class _ClassAnalyticsScreenState extends State<ClassAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().loadClassAnalytics(widget.classId);
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<AnalyticsViewModel>();
    final data = vm.classAnalytics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics lớp học'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Tổng quan'),
            Tab(icon: Icon(Icons.person_search_rounded), text: 'Từng học viên'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : data == null
              ? const EmptyState(icon: Icons.bar_chart_outlined, title: 'Chưa có dữ liệu', message: 'Chưa có hoạt động nào hoàn thành.')
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(data: data),
                    _StudentListTab(classId: widget.classId, data: data),
                  ],
                ),
    );
  }
}

// ─── Tab 1: Overview ──────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OverviewTab({required this.data});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Summary stat cards
      Row(children: [
        Expanded(child: StatCard(value: '${data['totalStudents'] ?? 0}', label: 'Tổng\nhọc viên', icon: Icons.people_rounded)),
        const SizedBox(width: 10),
        Expanded(child: StatCard(value: '${data['activeStudents'] ?? 0}', label: 'Đang\nhoạt động', color: AppColors.success, icon: Icons.trending_up_rounded)),
        const SizedBox(width: 10),
        Expanded(child: StatCard(value: '${data['avgCompletion'] ?? 0}%', label: 'TB hoàn\nthành', color: AppColors.secondary, icon: Icons.bar_chart_rounded)),
      ]),
      const SizedBox(height: 20),

      // Evidence stats
      Row(children: [
        Expanded(child: StatCard(value: '${data['pendingEvidence'] ?? 0}', label: 'Evidence\nchờ duyệt', color: AppColors.warning, icon: Icons.pending_actions_rounded)),
        const SizedBox(width: 10),
        Expanded(child: StatCard(value: '${data['approvedEvidence'] ?? 0}', label: 'Evidence\nApproved', color: AppColors.success, icon: Icons.check_circle_rounded)),
        const SizedBox(width: 10),
        Expanded(child: StatCard(value: '${data['rejectedEvidence'] ?? 0}', label: 'Evidence\nRejected', color: AppColors.error, icon: Icons.cancel_rounded)),
      ]),
      const SizedBox(height: 20),

      // Progress distribution
      const Text('Phân bổ tiến độ học viên', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(children: [
          ...['0-25%', '25-50%', '50-75%', '75-100%'].asMap().entries.map((e) {
            final pct = ((data['distribution'] as List<dynamic>?)?[e.key] as num?)?.toDouble() ?? 0.0;
            final colors = [AppColors.error, AppColors.warning, AppColors.info, AppColors.success];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(children: [
                SizedBox(width: 60, child: Text(e.value, style: const TextStyle(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w600))),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(colors[e.key]),
                    minHeight: 12,
                  ),
                )),
                const SizedBox(width: 8),
                SizedBox(width: 40, child: Text('${pct.toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors[e.key]), textAlign: TextAlign.right)),
              ]),
            );
          }),
        ]),
      ),
      const SizedBox(height: 20),

      // Activity completion by type
      const Text('Hoàn thành theo loại hoạt động', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 12),
      Row(children: [
        _ActivityTypeStat('Pre-Class', data['preClassRate'] as num? ?? 0, AppColors.preClass),
        const SizedBox(width: 10),
        _ActivityTypeStat('In-Class', data['inClassRate'] as num? ?? 0, AppColors.inClass),
        const SizedBox(width: 10),
        _ActivityTypeStat('Post-Class', data['postClassRate'] as num? ?? 0, AppColors.postClass),
      ]),
    ]),
  );

  Widget _ActivityTypeStat(String label, num rate, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(children: [
        Text('${rate.toInt()}%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate / 100,
            backgroundColor: color.withAlpha(40),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ]),
    ),
  );
}

// ─── Tab 2: Per-Student ───────────────────────────────────────────────────────
class _StudentListTab extends StatelessWidget {
  final int classId;
  final Map<String, dynamic> data;
  const _StudentListTab({required this.classId, required this.data});

  @override
  Widget build(BuildContext context) {
    final students = (data['students'] as List<dynamic>?) ?? [];
    if (students.isEmpty) {
      return const EmptyState(icon: Icons.person_off_rounded, title: 'Chưa có dữ liệu học viên', message: '');
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = students[i] as Map<String, dynamic>;
        final pct = (s['completionRate'] as num? ?? 0).toDouble();
        final color = pct >= 75 ? AppColors.success : pct >= 50 ? AppColors.info : pct >= 25 ? AppColors.warning : AppColors.error;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                (s['name'] as String? ?? '').isNotEmpty ? (s['name'] as String)[0] : '?',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
            title: Text(s['name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 7,
                  ),
                )),
                const SizedBox(width: 8),
                Text('${pct.toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
              ]),
              const SizedBox(height: 4),
              Text(
                '✓ ${s['completedActivities'] ?? 0} hoạt động  •  ${s['pendingEvidence'] ?? 0} evidence chờ',
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            ]),
            onTap: () => Navigator.pushNamed(context, '/instructor/students/${s['userId']}/progress',
                arguments: {'classId': classId, 'studentName': s['name']}),
          ),
        );
      },
    );
  }
}
