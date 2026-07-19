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
                  const SizedBox(height: 16),
                  _ProjectHeader(detail: detail, milestones: vm.milestones),
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Xem danh sách Milestones',
                          onPressed: () {
                            Navigator.pushNamed(context, '/projects/${detail['id']}/milestones');
                          },
                          icon: Icons.flag_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
