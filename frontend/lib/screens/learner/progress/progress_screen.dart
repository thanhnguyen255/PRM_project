import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../models/models.dart';
import '../../../services/services.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L37 — Learning Progress (Track overall learning progress)
// ════════════════════════════════════════════════════════════════════════════════
class ProgressScreen extends StatefulWidget {
  final int? classId;
  const ProgressScreen({super.key, this.classId});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int? _selectedClassId;
  List<ClassModel> _classes = [];

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.classId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClasses();
      context.read<AnalyticsViewModel>().loadMyProgress(classId: _selectedClassId);
    });
  }

  Future<void> _loadClasses() async {
    final classes = await ClassService().getMyClasses();
    if (!mounted) return;
    setState(() => _classes = classes);
  }

  void _onClassChanged(int? classId) {
    setState(() => _selectedClassId = classId);
    context.read<AnalyticsViewModel>().loadMyProgress(classId: classId);
  }

  Widget _buildClassSelector() {
    // Đảm bảo value luôn khớp đúng một item (null = tất cả các lớp)
    final validValue = (_selectedClassId == null || _classes.any((c) => c.id == _selectedClassId))
        ? _selectedClassId
        : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        const Icon(Icons.filter_list_rounded, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              isExpanded: true,
              value: validValue,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Tất cả các lớp')),
                ..._classes.map((c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(
                        c.courseTitle != null ? '${c.courseTitle} · ${c.name}' : c.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
              ],
              onChanged: _onClassChanged,
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<AnalyticsViewModel>();
    final data = vm.myProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tiến độ học tập')),
      body: Column(children: [
        _buildClassSelector(),
        Expanded(
          child: vm.isLoading
          ? const LoadingWidget()
          : data == null
              ? const EmptyState(icon: Icons.bar_chart_outlined, title: 'Chưa có dữ liệu', message: 'Hoàn thành một số hoạt động để xem tiến độ.')
              : RefreshIndicator(
                  onRefresh: () => vm.loadMyProgress(classId: _selectedClassId),
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Overall progress — Donut (SCR-L37: Tổng quan)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E1B4B), AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Tổng quan', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: 20),
                          _DonutProgress(percent: (data['completionRate'] as num? ?? 0).toDouble()),
                          const SizedBox(height: 12),
                          Text(
                            '${data['completedActivities'] ?? 0}/${data['totalActivities'] ?? 0} hoạt động đã hoàn thành',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),

                      // Activity type breakdown
                      const Text('Tiến độ theo loại hoạt động', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _TypeCard('Pre-Class', data['preClassRate'] as num? ?? 0, AppColors.preClass, Icons.menu_book_rounded)),
                        const SizedBox(width: 10),
                        Expanded(child: _TypeCard('In-Class', data['inClassRate'] as num? ?? 0, AppColors.inClass, Icons.class_rounded)),
                        const SizedBox(width: 10),
                        Expanded(child: _TypeCard('Post-Class', data['postClassRate'] as num? ?? 0, AppColors.postClass, Icons.assignment_rounded)),
                      ]),
                      const SizedBox(height: 20),

                      // Weekly progress
                      const Text('Tiến độ từng tuần', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      if ((data['weeklyProgress'] as List?)?.isNotEmpty ?? false)
                        ...(data['weeklyProgress'] as List).asMap().entries.map((e) {
                          final week = e.value as Map<String, dynamic>;
                          final pct  = (week['rate'] as num? ?? 0).toDouble();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(children: [
                              SizedBox(width: 50, child: Text('Tuần ${e.key + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHint))),
                              Expanded(child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: pct / 100,
                                  backgroundColor: AppColors.border,
                                  valueColor: AlwaysStoppedAnimation(pct >= 100 ? AppColors.success : AppColors.primary),
                                  minHeight: 10,
                                ),
                              )),
                              const SizedBox(width: 8),
                              SizedBox(width: 40, child: Text('${pct.toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
                            ]),
                          );
                        })
                      else
                        const EmptyState(icon: Icons.timeline_rounded, title: 'Chưa có dữ liệu tuần', message: ''),
                      const SizedBox(height: 20),

                      // Activity status counts (SCR-L37: Hoạt động)
                      const Text('Hoạt động', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(children: [
                          _ActivityStatusRow(
                            icon: Icons.check_circle_rounded,
                            color: AppColors.success,
                            label: 'Đã hoàn thành',
                            count: (data['completedActivities'] as num? ?? 0).toInt(),
                          ),
                          const Divider(height: 1),
                          _ActivityStatusRow(
                            icon: Icons.hourglass_top_rounded,
                            color: AppColors.warning,
                            label: 'Đang chờ duyệt',
                            count: (data['pendingEvidence'] as num? ?? 0).toInt(),
                          ),
                          const Divider(height: 1),
                          _ActivityStatusRow(
                            icon: Icons.cancel_rounded,
                            color: AppColors.error,
                            label: 'Chưa nộp',
                            count: ((data['totalActivities'] as num? ?? 0) -
                                    (data['completedActivities'] as num? ?? 0) -
                                    (data['pendingEvidence'] as num? ?? 0))
                                .toInt()
                                .clamp(0, 1000000),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                ),
        ),
      ]),
    );
  }

}

// Donut hiển thị tiến độ tổng quan (dựng bằng widget có sẵn, không cần thêm package)
class _DonutProgress extends StatelessWidget {
  final double percent; // 0 - 100
  const _DonutProgress({required this.percent});

  @override
  Widget build(BuildContext context) {
    final v = (percent / 100).clamp(0.0, 1.0);
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(
            value: v,
            strokeWidth: 14,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${percent.toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
          const Text('Hoàn thành', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ]),
    );
  }
}

// Một dòng trạng thái hoạt động trong khối "Hoạt động"
class _ActivityStatusRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  const _ActivityStatusRow({required this.icon, required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
      Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
    ]),
  );
}

class _TypeCard extends StatelessWidget {
  final String label;
  final num rate;
  final Color color;
  final IconData icon;
  const _TypeCard(this.label, this.rate, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withAlpha(15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withAlpha(60)),
    ),
    child: Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text('${rate.toInt()}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
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
  );
}
