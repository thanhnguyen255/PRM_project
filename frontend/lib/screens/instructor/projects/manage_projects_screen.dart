import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I12/I13/I14 — Manage Projects & Milestones (Instructor)
// ════════════════════════════════════════════════════════════════════════════════
class ManageProjectsScreen extends StatefulWidget {
  final int classId;
  const ManageProjectsScreen({super.key, required this.classId});
  @override
  State<ManageProjectsScreen> createState() => _ManageProjectsScreenState();
}

class _ManageProjectsScreenState extends State<ManageProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().loadProjects(widget.classId);
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final y = picked.year;
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      controller.text = '$y-$m-$d';
    }
  }

  void _showAddProjectDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.folder_special_rounded, color: AppColors.warning),
          SizedBox(width: 8),
          Text('Tạo dự án mới'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: titleCtrl,
            decoration: InputDecoration(labelText: 'Tên dự án *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descCtrl,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Mô tả dự án', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ]),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final vm  = context.read<ProjectViewModel>();
                    final err = await vm.createProject(
                      classId: widget.classId,
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                    );
                    if (!context.mounted) return;
                    if (err == null) {
                      AppSnackBar.show(context, 'Tạo dự án thành công!', type: SnackType.success);
                    } else {
                      AppSnackBar.show(context, err, type: SnackType.error);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, 
                    foregroundColor: Colors.white, 
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Tạo dự án'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog(int projectId, String projectTitle) {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    final dueDateCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Thêm Milestone — $projectTitle', style: const TextStyle(fontSize: 15)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Tên milestone *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 12),
          TextField(
            controller: dueDateCtrl,
            readOnly: true,
            onTap: () => _selectDate(ctx, dueDateCtrl),
            decoration: InputDecoration(
              labelText: 'Hạn nộp (YYYY-MM-DD)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(controller: descCtrl, maxLines: 2, decoration: InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
        ]),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final vm  = context.read<ProjectViewModel>();
                    final err = await vm.createMilestone(
                      projectId: projectId,
                      title: titleCtrl.text.trim(),
                      dueDate: dueDateCtrl.text.trim().isEmpty ? null : dueDateCtrl.text.trim(),
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                    );
                    if (!context.mounted) return;
                    if (err == null) {
                      vm.loadProjects(widget.classId);
                      AppSnackBar.show(context, 'Thêm milestone thành công!', type: SnackType.success);
                    } else {
                      AppSnackBar.show(context, err, type: SnackType.error);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, 
                    foregroundColor: Colors.white, 
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Thêm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý dự án'),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_rounded, color: AppColors.primary),
            tooltip: 'Tạo dự án mới',
            onPressed: _showAddProjectDialog,
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.projects.isEmpty
              ? EmptyState(
                  icon: Icons.folder_outlined,
                  title: 'Chưa có dự án',
                  message: 'Tạo dự án để học viên làm việc theo nhóm.',
                  actionLabel: 'Tạo dự án',
                  onAction: _showAddProjectDialog,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.projects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final p = vm.projects[i];
                    return _ProjectCard(
                      project: p,
                      onAddMilestone: () => _showAddMilestoneDialog(p.id, p.title),
                      onDelete: () async {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          title: 'Xoá dự án',
                          message: 'Xoá "${p.title}"? Tất cả milestones sẽ bị xoá.',
                          confirmLabel: 'Xoá',
                          isDanger: true,
                        );
                        if (confirmed == true && context.mounted) {
                          await vm.deleteProject(p.id, widget.classId);
                        }
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProjectDialog,
        backgroundColor: AppColors.warning,
        icon: const Icon(Icons.create_new_folder_rounded, color: Colors.white),
        label: const Text('Tạo dự án', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final dynamic project;
  final VoidCallback onAddMilestone;
  final VoidCallback onDelete;
  const _ProjectCard({required this.project, required this.onAddMilestone, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final progress = project.milestoneCount == 0 ? 0.0 : project.completedMilestones / project.milestoneCount;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.warning.withAlpha(20), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.folder_special_rounded, color: AppColors.warning, size: 24),
          ),
          title: Text(project.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          subtitle: Text('${project.milestoneCount} milestones • ${project.completedMilestones} hoàn thành',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          trailing: PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'add') onAddMilestone();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'add', child: Row(children: [Icon(Icons.flag_rounded, size: 16, color: AppColors.primary), SizedBox(width: 8), Text('Thêm Milestone')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 16, color: AppColors.error), SizedBox(width: 8), Text('Xoá dự án', style: TextStyle(color: AppColors.error))])),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(children: [
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(progress >= 1.0 ? AppColors.success : AppColors.warning),
                  minHeight: 6,
                ),
              )),
              const SizedBox(width: 8),
              Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: progress >= 1.0 ? AppColors.success : AppColors.warning)),
            ]),
            if (project.milestones.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Danh sách Milestone:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 6),
              ...project.milestones.map<Widget>((m) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.flag_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            if (m.description != null && m.description!.isNotEmpty)
                              Text(
                                m.description!,
                                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                              ),
                            if (m.dueDate != null)
                              Text(
                                'Hạn nộp: ${m.dueDate!.year}-${m.dueDate!.month.toString().padLeft(2, '0')}-${m.dueDate!.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: onAddMilestone,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Thêm Milestone', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )),
          ]),
        ),
      ]),
    );
  }
}
