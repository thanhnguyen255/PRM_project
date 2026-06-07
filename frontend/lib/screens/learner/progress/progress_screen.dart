import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L20 — My Progress / Analytics (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class ProgressScreen extends StatefulWidget {
  final int? classId;
  const ProgressScreen({super.key, this.classId});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().loadMyProgress(classId: widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<AnalyticsViewModel>();
    final data = vm.myProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tiến độ học tập')),
      body: vm.isLoading
          ? const LoadingWidget()
          : data == null
              ? const EmptyState(icon: Icons.bar_chart_outlined, title: 'Chưa có dữ liệu', message: 'Hoàn thành một số hoạt động để xem tiến độ.')
              : RefreshIndicator(
                  onRefresh: () => vm.loadMyProgress(classId: widget.classId),
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Overall progress card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1E1B4B), AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Tiến độ tổng thể', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(
                              '${data['completionRate'] ?? 0}%',
                              style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 10),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('hoàn thành', style: TextStyle(color: Colors.white60, fontSize: 14)),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (data['completionRate'] as num? ?? 0) / 100,
                              backgroundColor: Colors.white30,
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(children: [
                            _WhiteStat('${data['completedActivities'] ?? 0}', 'HĐ\nhoàn thành'),
                            _divider(),
                            _WhiteStat('${data['totalActivities'] ?? 0}', 'Tổng\nhĐ'),
                            _divider(),
                            _WhiteStat('${data['approvedEvidence'] ?? 0}', 'Evidence\nduyệt'),
                            _divider(),
                            _WhiteStat('${data['pendingEvidence'] ?? 0}', 'Evidence\nchờ'),
                          ]),
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
                    ]),
                  ),
                ),
    );
  }

  Widget _WhiteStat(String value, String label) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10), textAlign: TextAlign.center),
    ]),
  );

  Widget _divider() => Container(width: 1, height: 36, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 4));
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
