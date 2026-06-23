import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../viewmodels/viewmodels.dart';
import '../../viewmodels/extended_viewmodels.dart';
import '../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I03 — Create/Edit Course
// ════════════════════════════════════════════════════════════════════════════════
class CreateEditCourseScreen extends StatefulWidget {
  final int? courseId;
  final String? initialTitle;
  final String? initialDesc;
  const CreateEditCourseScreen({super.key, this.courseId, this.initialTitle, this.initialDesc});
  @override
  State<CreateEditCourseScreen> createState() => _CreateEditCourseScreenState();
}

class _CreateEditCourseScreenState extends State<CreateEditCourseScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  bool get _isEdit => widget.courseId != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl.text = widget.initialTitle ?? '';
    _descCtrl.text  = widget.initialDesc  ?? '';
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final vm  = context.read<InstructorManageViewModel>();
    String?   err;
    if (_isEdit) {
      err = await vm.updateCourse(widget.courseId!, title: _titleCtrl.text.trim(), description: _descCtrl.text.trim());
    } else {
      err = await vm.createCourse(title: _titleCtrl.text.trim(), description: _descCtrl.text.trim());
    }
    if (!mounted) return;
    if (err == null) {
      AppSnackBar.show(context, _isEdit ? 'Cập nhật khóa học thành công!' : 'Tạo khóa học thành công!', type: SnackType.success);
      // Reload course list
      context.read<CourseViewModel>().loadMyCourses();
      Navigator.pop(context);
    } else {
      AppSnackBar.show(context, err, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InstructorManageViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Chỉnh sửa khóa học' : 'Tạo khóa học mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            AppTextField(
              label: 'Tên khóa học *',
              hint: 'VD: Lập trình Flutter nâng cao',
              controller: _titleCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên khóa học' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Mô tả',
              hint: 'Mô tả nội dung, mục tiêu khóa học...',
              controller: _descCtrl,
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            AppButton(label: _isEdit ? 'LƯU THAY ĐỔI' : 'TẠO KHÓA HỌC', onPressed: _save, isLoading: vm.isSaving, icon: Icons.save_rounded),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I04 — Manage Classes
// ════════════════════════════════════════════════════════════════════════════════
class ManageClassesScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  const ManageClassesScreen({super.key, required this.courseId, required this.courseTitle});
  @override
  State<ManageClassesScreen> createState() => _ManageClassesScreenState();
}

class _ManageClassesScreenState extends State<ManageClassesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassViewModel>().loadClassesByCourse(widget.courseId);
    });
  }

  void _showCreateDialog() {
    final nameCtrl  = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl   = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo lớp học kỳ mới'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên lớp *')),
            const SizedBox(height: 8),
            TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Ngày bắt đầu (YYYY-MM-DD)')),
            const SizedBox(height: 8),
            TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'Ngày kết thúc (YYYY-MM-DD)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final vm  = context.read<InstructorManageViewModel>();
              final err = await vm.createClass(
                courseId: widget.courseId,
                name:      nameCtrl.text.trim(),
                startDate: startCtrl.text.trim().isEmpty ? null : startCtrl.text.trim(),
                endDate:   endCtrl.text.trim().isEmpty ? null : endCtrl.text.trim(),
              );
              if (!mounted) return;
              if (err == null) {
                context.read<ClassViewModel>().loadClassesByCourse(widget.courseId);
                AppSnackBar.show(context, 'Tạo lớp thành công!', type: SnackType.success);
              } else {
                AppSnackBar.show(context, err, type: SnackType.error);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClassViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Lớp — ${widget.courseTitle}', overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.primary), onPressed: _showCreateDialog),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.classes.isEmpty
              ? EmptyState(
                  icon: Icons.class_outlined,
                  title: 'Chưa có lớp học kỳ',
                  message: 'Tạo lớp mới để bắt đầu.',
                  actionLabel: 'Tạo lớp',
                  onAction: _showCreateDialog,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.classes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final c = vm.classes[i];
                    return ListTile(
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                      leading: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 22),
                      ),
                      title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('${c.memberCount} học viên', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                      onTap: () => Navigator.pushNamed(context, '/instructor/classes/${c.id}'),
                    );
                  },
                ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I05 — Instructor Class Members Management
// ════════════════════════════════════════════════════════════════════════════════
class ClassMembersManageScreen extends StatefulWidget {
  final int classId;
  const ClassMembersManageScreen({super.key, required this.classId});
  @override
  State<ClassMembersManageScreen> createState() => _ClassMembersManageScreenState();
}

class _ClassMembersManageScreenState extends State<ClassMembersManageScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassViewModel>().loadMembers(widget.classId);
    });
  }

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _addMember() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    final vm  = context.read<InstructorManageViewModel>();
    final err = await vm.addMemberByEmail(widget.classId, email);
    if (!mounted) return;
    if (err == null) {
      _emailCtrl.clear();
      context.read<ClassViewModel>().loadMembers(widget.classId);
      AppSnackBar.show(context, 'Thêm thành viên thành công!', type: SnackType.success);
    } else {
      AppSnackBar.show(context, err, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClassViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Quản lý học viên (${vm.members.length})')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                hintText: 'Nhập email học viên...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              keyboardType: TextInputType.emailAddress,
            )),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addMember,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                elevation: 0,
              ),
              child: const Icon(Icons.add_rounded),
            ),
          ]),
        ),
        const Divider(height: 1),
        Expanded(child: vm.isLoading
            ? const LoadingWidget()
            : vm.members.isEmpty
                ? const EmptyState(icon: Icons.person_add_outlined, title: 'Chưa có thành viên', message: 'Thêm email học viên để bắt đầu.')
                : ListView.separated(
                    itemCount: vm.members.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final m = vm.members[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Text(m.fullName.isNotEmpty ? m.fullName[0] : '?',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                        ),
                        title: Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        subtitle: Text(m.email, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_rounded, color: AppColors.error),
                          onPressed: () async {
                            final confirmed = await ConfirmDialog.show(
                              context,
                              title: 'Xoá thành viên',
                              message: 'Xoá "${m.fullName}" khỏi lớp?',
                              confirmLabel: 'Xoá',
                              isDanger: true,
                            );
                            if (confirmed == true && context.mounted) {
                              final err = await context.read<InstructorManageViewModel>().removeMember(widget.classId, m.userId);
                              if (context.mounted) {
                                if (err == null) {
                                  context.read<ClassViewModel>().loadMembers(widget.classId);
                                } else {
                                  AppSnackBar.show(context, err, type: SnackType.error);
                                }
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I06/07 — Manage Learning Paths
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
        title: const Text('Thêm lộ trình học'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề *')),
          const SizedBox(height: 8),
          TextField(controller: weekCtrl, decoration: const InputDecoration(labelText: 'Tuần số *'), keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final week = int.tryParse(weekCtrl.text.trim());
              if (week == null) return;
              final vm  = context.read<InstructorManageViewModel>();
              final err = await vm.createLearningPath(classId: widget.classId, title: titleCtrl.text.trim(), weekNumber: week);
              if (!mounted) return;
              if (err == null) {
                context.read<LearningPathViewModel>().loadPaths(widget.classId);
                AppSnackBar.show(context, 'Tạo lộ trình thành công!', type: SnackType.success);
              } else {
                AppSnackBar.show(context, err, type: SnackType.error);
              }
            },
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
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.primary), onPressed: _showAddDialog)],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.paths.isEmpty
              ? EmptyState(icon: Icons.route_outlined, title: 'Chưa có lộ trình', message: '', actionLabel: 'Thêm', onAction: _showAddDialog)
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.paths.length,
                  itemBuilder: (_, i) {
                    final p = vm.paths[i];
                    return ListTile(
                      key: Key('path_${p.id}'),
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Text('W${p.weekNumber}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('${p.totalActivities} hoạt động', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 20),
                          onPressed: () async {
                            final confirmed = await ConfirmDialog.show(context, title: 'Xoá lộ trình', message: 'Xoá "${p.title}"?', confirmLabel: 'Xoá', isDanger: true);
                            if (confirmed == true && context.mounted) {
                              await context.read<InstructorManageViewModel>().deleteLearningPath(p.id);
                              if (context.mounted) context.read<LearningPathViewModel>().loadPaths(widget.classId);
                            }
                          },
                        ),
                        const Icon(Icons.drag_handle_rounded, color: AppColors.textHint),
                      ]),
                      onTap: () => Navigator.pushNamed(context, '/instructor/paths/${p.id}/activities'),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    // TODO: call reorder API
                  },
                ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I10/11 — Manage Activities for a Learning Path
// ════════════════════════════════════════════════════════════════════════════════
class ManageActivitiesScreen extends StatefulWidget {
  final int pathId;
  const ManageActivitiesScreen({super.key, required this.pathId});
  @override
  State<ManageActivitiesScreen> createState() => _ManageActivitiesScreenState();
}

class _ManageActivitiesScreenState extends State<ManageActivitiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityViewModel>().loadActivities(widget.pathId);
    });
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    String type = 'PreClass';
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Tạo hoạt động mới'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề *')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Loại'),
                items: ['PreClass','InClass','PostClass']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setS(() => type = v ?? type),
              ),
              const SizedBox(height: 8),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 3),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final vm  = context.read<InstructorManageViewModel>();
                final err = await vm.createActivity(
                  learningPathId: widget.pathId,
                  title: titleCtrl.text.trim(),
                  type: type,
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                );
                if (!context.mounted) return;
                if (err == null) {
                  context.read<ActivityViewModel>().loadActivities(widget.pathId);
                  AppSnackBar.show(context, 'Tạo hoạt động thành công!', type: SnackType.success);
                } else {
                  AppSnackBar.show(context, err, type: SnackType.error);
                }
              },
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivityViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý hoạt động'),
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.primary), onPressed: _showAddDialog)],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.activities.isEmpty
              ? EmptyState(icon: Icons.task_outlined, title: 'Chưa có hoạt động', message: '', actionLabel: 'Thêm', onAction: _showAddDialog)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.activities.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final a = vm.activities[i];
                    return Dismissible(
                      key: Key('act_${a.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await ConfirmDialog.show(context, title: 'Xoá hoạt động', message: 'Xoá "${a.title}"?', confirmLabel: 'Xoá', isDanger: true);
                      },
                      onDismissed: (_) async {
                        await context.read<InstructorManageViewModel>().deleteActivity(a.id);
                        if (context.mounted) context.read<ActivityViewModel>().loadActivities(widget.pathId);
                      },
                      child: ActivityCard(
                        title: a.title,
                        type: a.type,
                        deadline: a.deadline,
                        submissionStatus: null,
                        onTap: () {},
                      ),
                    );
                  },
                ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I12/13/14 — Manage Projects & Milestones (Instructor)
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

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo dự án mới'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên dự án *')),
          const SizedBox(height: 8),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 3),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final vm  = context.read<ProjectViewModel>();
              final err = await vm.createProject(classId: widget.classId, title: titleCtrl.text.trim(), description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim());
              if (!context.mounted) return;
              if (err == null) { AppSnackBar.show(context, 'Tạo dự án thành công!', type: SnackType.success); }
              else { AppSnackBar.show(context, err, type: SnackType.error); }
            },
            child: const Text('Tạo'),
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
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.primary), onPressed: _showAddDialog)],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.projects.isEmpty
              ? EmptyState(icon: Icons.folder_outlined, title: 'Chưa có dự án', message: '', actionLabel: 'Tạo dự án', onAction: _showAddDialog)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.projects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final p = vm.projects[i];
                    return ListTile(
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                      leading: const Icon(Icons.folder_special_rounded, color: AppColors.primary),
                      title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('${p.milestoneCount} milestones', style: const TextStyle(fontSize: 12)),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'milestones') {
                            Navigator.pushNamed(context, '/instructor/projects/${p.id}/milestones');
                          } else if (v == 'delete') {
                            final confirmed = await ConfirmDialog.show(context, title: 'Xoá dự án', message: 'Xoá "${p.title}"?', confirmLabel: 'Xoá', isDanger: true);
                            if (confirmed == true && context.mounted) {
                              await vm.deleteProject(p.id, widget.classId);
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'milestones', child: Text('Quản lý Milestones')),
                          const PopupMenuItem(value: 'delete', child: Text('Xoá', style: TextStyle(color: AppColors.error))),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I15/16 — Review Session Management (Instructor)
// ════════════════════════════════════════════════════════════════════════════════
class InstructorReviewScreen extends StatefulWidget {
  final int classId;
  const InstructorReviewScreen({super.key, required this.classId});
  @override
  State<InstructorReviewScreen> createState() => _InstructorReviewScreenState();
}

class _InstructorReviewScreenState extends State<InstructorReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().loadSessions(widget.classId);
    });
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl   = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo phiên Review'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề phiên *')),
          const SizedBox(height: 8),
          TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Bắt đầu (YYYY-MM-DD)')),
          const SizedBox(height: 8),
          TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'Kết thúc (YYYY-MM-DD)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final vm  = context.read<ReviewViewModel>();
              final err = await vm.createSession(
                classId: widget.classId,
                title: titleCtrl.text.trim(),
                startDate: startCtrl.text.trim(),
                endDate: endCtrl.text.trim(),
              );
              if (!context.mounted) return;
              if (err == null) { AppSnackBar.show(context, 'Tạo phiên review thành công!', type: SnackType.success); }
              else { AppSnackBar.show(context, err, type: SnackType.error); }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Peer Review'),
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: AppColors.primary), onPressed: _showCreateDialog)],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.sessions.isEmpty
              ? EmptyState(icon: Icons.rate_review_outlined, title: 'Chưa có phiên', message: '', actionLabel: 'Tạo phiên', onAction: _showCreateDialog)
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.sessions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final s = vm.sessions[i];
                    return ListTile(
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                      leading: CircleAvatar(
                        backgroundColor: s.isOpen ? AppColors.successLight : AppColors.surfaceVariant,
                        child: Icon(Icons.rate_review_rounded, color: s.isOpen ? AppColors.success : AppColors.textHint),
                      ),
                      title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('${_fmtD(s.startDate)} → ${_fmtD(s.endDate)}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                      trailing: StatusBadge(status: s.isOpen ? BadgeStatus.open : BadgeStatus.closed),
                      onTap: () => Navigator.pushNamed(context, '/instructor/review/${s.id}/monitor'),
                    );
                  },
                ),
    );
  }

  String _fmtD(DateTime dt) => '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}';
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I20/21 — Learning Analytics
// ════════════════════════════════════════════════════════════════════════════════
class ClassAnalyticsScreen extends StatefulWidget {
  final int classId;
  const ClassAnalyticsScreen({super.key, required this.classId});
  @override
  State<ClassAnalyticsScreen> createState() => _ClassAnalyticsScreenState();
}

class _ClassAnalyticsScreenState extends State<ClassAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().loadClassAnalytics(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<AnalyticsViewModel>();
    final data = vm.classAnalytics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Analytics')),
      body: vm.isLoading
          ? const LoadingWidget()
          : data == null
              ? const EmptyState(icon: Icons.bar_chart_outlined, title: 'Chưa có dữ liệu', message: '')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Summary stats
                    Row(children: [
                      Expanded(child: StatCard(value: '${data['totalStudents'] ?? 0}', label: 'Tổng\nhọc viên', icon: Icons.people_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(value: '${data['activeStudents'] ?? 0}', label: 'Đang\nhoạt động', color: AppColors.success, icon: Icons.trending_up_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(value: '${(data['avgCompletion'] ?? 0)}%', label: 'TB hoàn\nthành', color: AppColors.secondary, icon: Icons.bar_chart_rounded)),
                    ]),
                    const SizedBox(height: 20),

                    // Completion distribution
                    const Text('Phân bổ tiến độ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...['0-25%', '25-50%', '50-75%', '75-100%'].asMap().entries.map((e) {
                      final pct = ((data['distribution'] as List<dynamic>?)?[e.key] as num?)?.toDouble() ?? 0.0;
                      final colors = [AppColors.error, AppColors.warning, AppColors.info, AppColors.success];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          SizedBox(width: 56, child: Text(e.value, style: const TextStyle(fontSize: 12, color: AppColors.textHint))),
                          Expanded(child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct / 100,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation(colors[e.key]),
                              minHeight: 10,
                            ),
                          )),
                          const SizedBox(width: 8),
                          Text('${pct.toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                      );
                    }),
                    const SizedBox(height: 20),

                    // Student list with progress
                    const Text('Tiến độ từng học viên', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...((data['studentProgress'] as List<dynamic>?) ?? []).map((s) {
                      final student  = s as Map<String,dynamic>;
                      final progress = (student['progress'] as num?)?.toDouble() ?? 0.0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              (student['name'] as String? ?? '?').isNotEmpty ? (student['name'] as String)[0] : '?',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(student['name'] as String? ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation(progress >= 75 ? AppColors.success : progress >= 40 ? AppColors.warning : AppColors.error),
                                minHeight: 6,
                              ),
                            ),
                          ])),
                          const SizedBox(width: 8),
                          Text('${progress.toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ]),
                      );
                    }),
                  ]),
                ),
    );
  }
}
