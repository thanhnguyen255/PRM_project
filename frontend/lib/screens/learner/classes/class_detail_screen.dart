import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L09 — Class Detail (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class ClassDetailScreen extends StatefulWidget {
  final int classId;
  const ClassDetailScreen({super.key, required this.classId});
  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassViewModel>().loadClass(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm  = context.watch<ClassViewModel>();
    final cls = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: vm.isLoading
          ? const LoadingWidget()
          : cls == null
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Không tìm thấy', message: '')
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 140,
                      pinned: true,
                      backgroundColor: AppColors.primary,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(cls.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, Color(0xFF7C3AED)],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Stats row
                          Row(children: [
                            Expanded(child: StatCard(value: '${cls.memberCount}', label: 'Học viên', icon: Icons.group_rounded)),
                            const SizedBox(width: 10),
                            Expanded(child: StatCard(value: '${cls.weekCount}', label: 'Tuần học', icon: Icons.calendar_today_rounded)),
                            const SizedBox(width: 10),
                            Expanded(child: StatCard(
                              value: '${(cls.progressPercent * 100).toInt()}%',
                              label: 'Hoàn thành',
                              color: AppColors.success,
                              icon: Icons.check_circle_rounded,
                            )),
                          ]),
                          const SizedBox(height: 20),

                          // Progress bar
                          const Text('Tiến độ học tập', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: cls.progressPercent,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(AppColors.success),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Quick actions
                          const Text('Truy cập nhanh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Wrap(spacing: 10, runSpacing: 10, children: [
                            _actionChip(Icons.route_rounded, 'Lộ trình', AppColors.primary, () =>
                                Navigator.pushNamed(context, '/classes/${widget.classId}/learning-path')),
                            _actionChip(Icons.group_rounded, 'Thành viên', AppColors.secondary, () =>
                                Navigator.pushNamed(context, '/classes/${widget.classId}/members')),
                            _actionChip(Icons.folder_special_rounded, 'Dự án', AppColors.warning, () =>
                                Navigator.pushNamed(context, '/projects', arguments: {'classId': widget.classId})),
                            _actionChip(Icons.rate_review_rounded, 'Review', AppColors.success, () =>
                                Navigator.pushNamed(context, '/review-sessions', arguments: {'classId': widget.classId})),
                            _actionChip(Icons.insights_rounded, 'Tiến độ', AppColors.info, () =>
                                Navigator.pushNamed(context, '/progress', arguments: {'classId': widget.classId})),
                          ]),

                          if (cls.startDate != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(children: [
                                _infoRow(Icons.calendar_today_rounded, 'Bắt đầu',
                                    '${cls.startDate!.day.toString().padLeft(2,'0')}/${cls.startDate!.month.toString().padLeft(2,'0')}/${cls.startDate!.year}'),
                                if (cls.endDate != null) ...[
                                  const Divider(height: 16),
                                  _infoRow(Icons.event_rounded, 'Kết thúc',
                                      '${cls.endDate!.day.toString().padLeft(2,'0')}/${cls.endDate!.month.toString().padLeft(2,'0')}/${cls.endDate!.year}'),
                                ],
                              ]),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _actionChip(IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      );

  Widget _infoRow(IconData icon, String label, String value) => Row(children: [
    Icon(icon, size: 16, color: AppColors.textHint),
    const SizedBox(width: 8),
    Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
    Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
  ]);
}
