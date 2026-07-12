import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';
import '../../../models/models.dart';

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
  final ProjectModel project;
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
              if (project.nextMilestoneTitle != null) ...[
                const Divider(height: 16),
                Row(children: [
                  const Icon(Icons.flag_circle_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Mục tiêu: ${project.nextMilestoneTitle}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ]),
                if (project.nextMilestoneDueDate != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.event_rounded, size: 16, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Text(
                      'Hạn nộp: ${project.nextMilestoneDueDate!.day.toString().padLeft(2, '0')}/${project.nextMilestoneDueDate!.month.toString().padLeft(2, '0')}/${project.nextMilestoneDueDate!.year} ${project.nextMilestoneDueDate!.hour.toString().padLeft(2, '0')}:${project.nextMilestoneDueDate!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: project.nextMilestoneDueDate!.isBefore(DateTime.now()) ? AppColors.error : AppColors.textHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]),
                ],
              ] else ...[
                const Row(children: [
                  Icon(Icons.flag_rounded, size: 14, color: AppColors.textHint),
                  SizedBox(width: 4),
                  Text('Xem milestones →', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ]),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L27 — Project Detail (Learner)
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
    });
  }

  Future<void> _refresh() =>
      context.read<ProjectViewModel>().loadProjectDetail(widget.projectId);

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<ProjectViewModel>();
    final detail = vm.projectDetail;
    final title  = detail?['title'] as String? ?? 'Dự án';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, overflow: TextOverflow.ellipsis),
        elevation: 0,
        backgroundColor: const Color(0xFFD97706),
        foregroundColor: Colors.white,
      ),
      body: (vm.isLoading || detail == null)
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                children: [
                  _ProjectHeader(detail: detail, milestones: vm.milestones),
                  const SizedBox(height: 24),
                  _MilestoneTimeline(
                    milestones: vm.milestones,
                    projectId: widget.projectId,
                  ),
                ],
              ),
            ),
    );
  }
}

// ── Project Header Card ────────────────────────────────────────────────────────
class _ProjectHeader extends StatelessWidget {
  final Map<String, dynamic> detail;
  final List<MilestoneModel> milestones;

  const _ProjectHeader({required this.detail, required this.milestones});

  @override
  Widget build(BuildContext context) {
    final title       = detail['title'] as String? ?? '';
    final description = detail['description'] as String?;
    final total       = milestones.length;
    final done        = milestones.where((m) => m.isSubmitted).length;
    final pct         = total == 0 ? 0.0 : done / total;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Icon + Title
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.folder_special_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700, height: 1.3,
                ),
              ),
            ),
          ]),

          // Description
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),

          // Progress bar
          Row(children: [
            const Icon(Icons.flag_rounded, size: 15, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              '$done/$total milestone hoàn thành',
              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(50),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(pct * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Milestone Timeline ─────────────────────────────────────────────────────────
class _MilestoneTimeline extends StatelessWidget {
  final List<MilestoneModel> milestones;
  final int projectId;

  const _MilestoneTimeline({required this.milestones, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danh sách Milestone',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
            final m    = milestones[i];
            final isLast = i == milestones.length - 1;
            return _MilestoneStepRow(
              milestone: m,
              index: i + 1,
              isLast: isLast,
              onTap: () async {
                await Navigator.pushNamed(context, '/milestones/${m.id}');
                if (context.mounted) {
                  context.read<ProjectViewModel>().loadProjectDetail(projectId);
                }
              },
            );
          }),
      ],
    );
  }
}

// ── Milestone Step Row (stepper style) ────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    final done       = milestone.isSubmitted;
    final stepColor  = done ? AppColors.success : AppColors.warning;
    final stepBg     = done ? AppColors.successLight : AppColors.warningLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left column: circle + vertical line
        SizedBox(
          width: 48,
          child: Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: stepBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done ? AppColors.success : AppColors.warning,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded, color: AppColors.success, size: 20)
                      : Text(
                          '$index',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: stepColor,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
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

        // ── Right column: card content
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
                  border: Border.all(
                    color: done ? AppColors.success.withAlpha(80) : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + status badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            milestone.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(isSubmitted: done),
                      ],
                    ),

                    // Due date
                    if (milestone.dueDate != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.event_rounded, size: 13, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(
                            'Hạn: ${_fmt(milestone.dueDate!)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                          ),
                          if (milestone.submittedAt != null) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.upload_rounded, size: 13, color: AppColors.success),
                            const SizedBox(width: 3),
                            Text(
                              'Nộp: ${_fmt(milestone.submittedAt!)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.success),
                            ),
                          ],
                        ],
                      ),
                    ],

                    // Action hint
                    if (!done) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_file_rounded, size: 13, color: AppColors.warning),
                            SizedBox(width: 4),
                            Text(
                              'Nhấn để xem & nộp',
                              style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
                            ),
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

  static String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ── Status Chip ───────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final bool isSubmitted;
  const _StatusChip({required this.isSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSubmitted ? AppColors.successLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSubmitted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 11,
            color: isSubmitted ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 3),
          Text(
            isSubmitted ? 'Đã nộp' : 'Chưa nộp',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSubmitted ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
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
