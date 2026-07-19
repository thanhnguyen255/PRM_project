import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/app_colors.dart';
import '../../../models/models.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

class MilestoneListScreen extends StatefulWidget {
  final int projectId;
  const MilestoneListScreen({super.key, required this.projectId});

  @override
  State<MilestoneListScreen> createState() => _MilestoneListScreenState();
}

class _MilestoneListScreenState extends State<MilestoneListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().loadProjectDetail(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectViewModel>();
    final milestones = vm.milestones;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Danh sách Milestone')),
      body: vm.isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Milestones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  if (milestones.isEmpty)
                    const EmptyState(
                      icon: Icons.flag_outlined,
                      title: 'Chưa có milestone',
                      message: 'Giảng viên chưa tạo milestone cho dự án này.',
                    )
                  else
                    ...List.generate(milestones.length, (i) {
                      final m = milestones[i];
                      final isLast = i == milestones.length - 1;
                      return _MilestoneStepRow(
                        milestone: m,
                        index: i + 1,
                        isLast: isLast,
                        onTap: () async {
                          await Navigator.pushNamed(context, '/milestones/${m.id}');
                          if (context.mounted) {
                            context.read<ProjectViewModel>().loadProjectDetail(widget.projectId);
                          }
                        },
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

class _MilestoneStepRow extends StatelessWidget {
  final MilestoneModel milestone;
  final int index;
  final bool isLast;
  final VoidCallback onTap;

  const _MilestoneStepRow({
    required this.milestone,
    required this.index,
    required this.isLast,
    required this.onTap,
  });

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final done       = milestone.isSubmitted;
    final stepColor  = done ? AppColors.success : AppColors.warning;
    final stepBg     = done ? AppColors.successLight : AppColors.warningLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: stepBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: done ? AppColors.success : AppColors.warning, width: 2),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded, color: AppColors.success, size: 20)
                      : Text('$index', style: TextStyle(fontWeight: FontWeight.w800, color: stepColor, fontSize: 15)),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2, height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: done ? AppColors.success.withAlpha(60) : AppColors.border,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: done ? AppColors.success.withAlpha(80) : AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(milestone.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary, height: 1.3)),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(isSubmitted: done, isLate: milestone.isLate),
                      ],
                    ),
                    if (milestone.dueDate != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.event_rounded, size: 13, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text('Hạn: ${_fmt(milestone.dueDate!)}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                          if (milestone.submittedAt != null) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.upload_rounded, size: 13, color: AppColors.success),
                            const SizedBox(width: 3),
                            Text('Nộp: ${_fmt(milestone.submittedAt!)}', style: const TextStyle(fontSize: 12, color: AppColors.success)),
                          ],
                        ],
                      ),
                    ],
                    if (!done) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_file_rounded, size: 13, color: AppColors.warning),
                            SizedBox(width: 4),
                            Text('Nhấn để xem & nộp', style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isSubmitted;
  final bool isLate;

  const _StatusChip({required this.isSubmitted, required this.isLate});

  @override
  Widget build(BuildContext context) {
    if (!isSubmitted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.border.withAlpha(50), borderRadius: BorderRadius.circular(12)),
        child: const Text('Chưa nộp', style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.bold)),
      );
    }
    if (isLate) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12)),
        child: const Text('Nộp muộn', style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
      child: const Text('Đã nộp', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
    );
  }
}
