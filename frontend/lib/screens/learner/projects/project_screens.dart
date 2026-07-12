import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L21/L22 — My Projects & Project Detail (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class LearnerProjectsScreen extends StatefulWidget {
  final int classId;
  const LearnerProjectsScreen({super.key, required this.classId});
  @override
  State<LearnerProjectsScreen> createState() => _LearnerProjectsState();
}

class _LearnerProjectsState extends State<LearnerProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().loadProjects(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Dự án lớp học')),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.projects.isEmpty
              ? const EmptyState(icon: Icons.folder_outlined, title: 'Chưa có dự án', message: 'Giảng viên chưa tạo dự án cho lớp này.')
              : RefreshIndicator(
                  onRefresh: () => vm.loadProjects(widget.classId),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.projects.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = vm.projects[i];
                      return _ProjectCard(
                        project: p,
                        onTap: () => Navigator.pushNamed(context, '/projects/${p.id}'),
                      );
                    },
                  ),
                ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final dynamic project;
  final VoidCallback onTap;
  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = project.milestoneCount == 0 ? 0.0 : project.completedMilestones / project.milestoneCount;
    final isComplete = pct >= 1.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isComplete ? AppColors.success.withAlpha(80) : AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8)],
        ),
        child: Column(children: [
          // Header gradient
          Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              gradient: LinearGradient(
                colors: isComplete ? [const Color(0xFF059669), AppColors.success] : [const Color(0xFFD97706), AppColors.warning],
              ),
            ),
            child: Center(child: Icon(isComplete ? Icons.check_circle_rounded : Icons.folder_special_rounded, size: 32, color: Colors.white70)),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(project.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                Text('${project.completedMilestones}/${project.milestoneCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHint)),
              ]),
              if ((project.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(project.description!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(isComplete ? AppColors.success : AppColors.warning),
                    minHeight: 7,
                  ),
                )),
                const SizedBox(width: 8),
                Text('${(pct * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isComplete ? AppColors.success : AppColors.warning)),
              ]),
              const SizedBox(height: 8),
              const Row(children: [
                Icon(Icons.flag_rounded, size: 14, color: AppColors.textHint),
                SizedBox(width: 4),
                Text('Xem milestones →', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L22 — Project Detail & Milestones (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class LearnerProjectDetailScreen extends StatefulWidget {
  final int projectId;
  const LearnerProjectDetailScreen({super.key, required this.projectId});
  @override
  State<LearnerProjectDetailScreen> createState() => _LearnerProjectDetailState();
}

class _LearnerProjectDetailState extends State<LearnerProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().loadProjectDetail(widget.projectId);
      context.read<ProjectViewModel>().loadMilestones(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<ProjectViewModel>();
    final detail = vm.projectDetail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(detail?['title'] as String? ?? 'Dự án')),
      body: vm.isLoading
          ? const LoadingWidget()
          : CustomScrollView(
              slivers: [
                // Overview card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFD97706), AppColors.warning]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Icon(Icons.folder_special_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 10),
                          Expanded(child: Text(detail?['title'] as String? ?? '', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700))),
                        ]),
                        if ((detail?['description'] as String? ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(detail!['description'] as String, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                        ],
                        const SizedBox(height: 14),
                        Row(children: [
                          _InfoBadge(Icons.flag_rounded, '${vm.milestones.where((m) => m.isSubmitted).length}/${vm.milestones.length} milestone'),
                        ]),
                      ]),
                    ),
                  ),
                ),

                // Milestones header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text('Danh sách Milestone', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ),
                ),

                // Milestones list
                if (vm.milestones.isEmpty)
                  const SliverFillRemaining(child: EmptyState(icon: Icons.flag_outlined, title: 'Chưa có milestone', message: 'Giảng viên chưa tạo milestone cho dự án này.'))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverList.separated(
                      itemCount: vm.milestones.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final m = vm.milestones[i];
                        return _MilestoneCard(
                          milestone: m,
                          index: i + 1,
                          onSubmit: () async {
                            await Navigator.pushNamed(context, '/milestones/${m.id}');
                            if (context.mounted) {
                              context.read<ProjectViewModel>().loadMilestones(widget.projectId);
                              context.read<ProjectViewModel>().loadProjectDetail(widget.projectId);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final dynamic milestone;
  final int index;
  final VoidCallback onSubmit;
  const _MilestoneCard({required this.milestone, required this.index, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final bool done = milestone.isSubmitted as bool;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: done ? AppColors.success.withAlpha(80) : AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: done ? AppColors.successLight : AppColors.warning.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: done
              ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22)
              : Center(child: Text('#$index', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.warning, fontSize: 14))),
        ),
        title: Text(milestone.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: milestone.dueDate != null
            ? Text('Hạn: ${_fmt(milestone.dueDate!)}', style: const TextStyle(fontSize: 12, color: AppColors.textHint))
            : const Text('Chưa có hạn', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
        trailing: done
            ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Nộp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
        onTap: onSubmit,
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoBadge(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: Colors.white),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L29 — Milestone Detail + SCR-L30 — Submit Milestone
// ════════════════════════════════════════════════════════════════════════════════
class MilestoneDetailScreen extends StatefulWidget {
  final int milestoneId;
  const MilestoneDetailScreen({super.key, required this.milestoneId});
  @override
  State<MilestoneDetailScreen> createState() => _MilestoneDetailScreenState();
}

class _MilestoneDetailScreenState extends State<MilestoneDetailScreen> {
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().loadMilestoneDetail(widget.milestoneId);
    });
  }

  @override
  void dispose() { _descCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final vm  = context.read<ProjectViewModel>();
    final err = await vm.submitMilestone(milestoneId: widget.milestoneId, description: _descCtrl.text.trim());
    if (!mounted) return;
    if (err == null) {
      AppSnackBar.show(context, 'Nộp milestone thành công!', type: SnackType.success);
      Navigator.pop(context);
    } else {
      AppSnackBar.show(context, err, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectViewModel>();
    final m  = vm.milestone;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Chi tiết Milestone')),
      body: vm.isLoading
          ? const LoadingWidget()
          : m == null
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Không tìm thấy', message: '')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text('Milestone ${m.stepNumber}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                          const Spacer(),
                          StatusBadge(status: m.isSubmitted ? BadgeStatus.approved : BadgeStatus.pending),
                        ]),
                        const SizedBox(height: 8),
                        Text(m.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        if (m.dueDate != null) ...[
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.event_rounded, size: 14, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Text(
                              'Hạn: ${m.dueDate!.day.toString().padLeft(2,'0')}/${m.dueDate!.month.toString().padLeft(2,'0')}/${m.dueDate!.year}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textHint),
                            ),
                          ]),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 16),

                    if ((m.description ?? '').isNotEmpty) ...[
                      const Text('Mô tả & Yêu cầu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(m.description!, style: const TextStyle(fontSize: 14, height: 1.7, color: AppColors.textSecondary)),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Submit form (nếu chưa nộp)
                    if (!m.isSubmitted) ...[
                      const Text('Nộp báo cáo Milestone', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Mô tả kết quả',
                        hint: 'Nhập mô tả về những gì nhóm đã hoàn thành...',
                        controller: _descCtrl,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(children: [
                          const Icon(Icons.attach_file_rounded, color: AppColors.textHint),
                          const SizedBox(width: 10),
                          const Expanded(child: Text('Chọn file báo cáo', style: TextStyle(color: AppColors.textSecondary))),
                          AppButton(label: 'Chọn file', onPressed: () {}, variant: ButtonVariant.outline, isFullWidth: false),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'NỘP MILESTONE',
                        onPressed: _submit,
                        isLoading: vm.isSaving,
                        icon: Icons.upload_rounded,
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success.withAlpha(80)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                          const SizedBox(width: 10),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Đã nộp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.success)),
                            if (m.submittedAt != null)
                              Text(
                                'Nộp: ${m.submittedAt!.day.toString().padLeft(2,'0')}/${m.submittedAt!.month.toString().padLeft(2,'0')}/${m.submittedAt!.year}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                              ),
                          ]),
                        ]),
                      ),
                  ]),
                ),
    );
  }
}
