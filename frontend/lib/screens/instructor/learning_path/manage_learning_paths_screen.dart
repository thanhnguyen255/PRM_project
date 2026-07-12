import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I06/I07 — Manage Learning Paths (Instructor)
// ════════════════════════════════════════════════════════════════════════════════
class ManageLearningPathsScreen extends StatefulWidget {
  final int classId;
  const ManageLearningPathsScreen({super.key, required this.classId});
  @override
  State<ManageLearningPathsScreen> createState() => _ManageLearningPathsState();
}

class _ManageLearningPathsState extends State<ManageLearningPathsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningPathViewModel>().loadPaths(widget.classId);
    });
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final weekCtrl  = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.add_circle_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Thêm lộ trình học'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: titleCtrl,
            decoration: InputDecoration(labelText: 'Tiêu đề *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: weekCtrl,
            decoration: InputDecoration(labelText: 'Tuần số *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            keyboardType: TextInputType.number,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final week = int.tryParse(weekCtrl.text.trim());
              if (week == null || titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final vm  = context.read<InstructorManageViewModel>();
              final err = await vm.createLearningPath(
                classId: widget.classId,
                title: titleCtrl.text.trim(),
                weekNumber: week,
              );
              if (!mounted) return;
              if (err == null) {
                context.read<LearningPathViewModel>().loadPaths(widget.classId);
                AppSnackBar.show(context, 'Tạo lộ trình thành công!', type: SnackType.success);
              } else {
                AppSnackBar.show(context, err, type: SnackType.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LearningPathViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lộ trình học'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            tooltip: 'Thêm tuần',
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.paths.isEmpty
              ? EmptyState(
                  icon: Icons.route_outlined,
                  title: 'Chưa có lộ trình',
                  message: 'Thêm các tuần học để tổ chức nội dung.',
                  actionLabel: 'Thêm tuần đầu tiên',
                  onAction: _showAddDialog,
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.paths.length,
                  itemBuilder: (_, i) {
                    final p = vm.paths[i];
                    return _PathCard(
                      key: Key('path_${p.id}'),
                      path: p,
                      index: i,
                      onManage: () => Navigator.pushNamed(context, '/instructor/paths/${p.id}/activities'),
                      onDelete: () async {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          title: 'Xoá lộ trình',
                          message: 'Xoá "${p.title}"? Tất cả hoạt động sẽ bị xoá.',
                          confirmLabel: 'Xoá',
                          isDanger: true,
                        );
                        if (confirmed == true && context.mounted) {
                          await context.read<InstructorManageViewModel>().deleteLearningPath(p.id);
                          if (context.mounted) context.read<LearningPathViewModel>().loadPaths(widget.classId);
                        }
                      },
                      onToggleLock: () async {
                        final m = context.read<InstructorManageViewModel>();
                        final err = await m.toggleLearningPathLock(p.id);
                        if (context.mounted) {
                          if (err == null) {
                            context.read<LearningPathViewModel>().loadPaths(widget.classId);
                          } else {
                            AppSnackBar.show(context, err, type: SnackType.error);
                          }
                        }
                      },
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    // TODO: call reorder API
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Thêm tuần', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  final dynamic path;
  final int index;
  final VoidCallback onManage;
  final VoidCallback onDelete;
  final VoidCallback onToggleLock;
  const _PathCard({super.key, required this.path, required this.index, required this.onManage, required this.onDelete, required this.onToggleLock});

  @override
  Widget build(BuildContext context) {
    final progress = path.progress as double;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(
              'W${path.weekNumber}',
              style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w800),
            )),
          ),
          title: Text(path.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 4),
            Text('${path.totalActivities} hoạt động • ${path.completedActivities} hoàn thành',
                style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(progress >= 1.0 ? AppColors.success : AppColors.primary),
                minHeight: 4,
              ),
            ),
          ]),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              icon: const Icon(Icons.folder_shared_rounded, color: AppColors.secondary, size: 22),
              tooltip: 'Quản lý tài liệu',
              onPressed: () => Navigator.pushNamed(context, '/instructor/paths/${path.id}/materials'),
            ),
            IconButton(
              icon: Icon(
                path.isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                color: path.isUnlocked ? AppColors.success : AppColors.textHint,
                size: 22,
              ),
              tooltip: path.isUnlocked ? 'Đang mở (Bấm để Khóa)' : 'Đang khóa (Bấm để Mở)',
              onPressed: onToggleLock,
            ),
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
              tooltip: 'Quản lý hoạt động',
              onPressed: onManage,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
              tooltip: 'Xoá',
              onPressed: onDelete,
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.drag_handle_rounded, color: AppColors.textHint),
              ),
            ),
          ]),
          onTap: onManage,
        ),
      ),
    );
  }
}
