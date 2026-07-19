import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I02 — Manage Courses Tab (embedded in Dashboard)
// ════════════════════════════════════════════════════════════════════════════════
class ManageCoursesTab extends StatefulWidget {
  const ManageCoursesTab({super.key});
  @override
  State<ManageCoursesTab> createState() => _ManageCoursesTabState();
}

class _ManageCoursesTabState extends State<ManageCoursesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseViewModel>().loadMyCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CourseViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý khóa học'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            tooltip: 'Tạo khóa học',
            onPressed: () => Navigator.pushNamed(context, '/instructor/courses/create'),
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.courses.isEmpty
              ? EmptyState(
                  icon: Icons.book_outlined,
                  title: 'Chưa có khóa học',
                  message: 'Tạo khóa học mới để bắt đầu.',
                  actionLabel: 'Tạo khóa học',
                  onAction: () => Navigator.pushNamed(context, '/instructor/courses/create'),
                )
              : RefreshIndicator(
                  onRefresh: () => vm.loadMyCourses(),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final c = vm.courses[i];
                      return _CourseManageCard(
                        course: c,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/instructor/courses/${c.id}/classes',
                          arguments: {'courseTitle': c.title},
                        ),
                        onEdit: () => Navigator.pushNamed(
                          context,
                          '/instructor/courses/${c.id}/edit',
                          arguments: {'title': c.title, 'description': c.description},
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _CourseManageCard extends StatelessWidget {
  final dynamic course; // CourseModel
  final VoidCallback onTap;
  final VoidCallback onEdit;
  const _CourseManageCard({required this.course, required this.onTap, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          // Cover gradient
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF7C3AED)],
              ),
            ),
            child: const Center(child: Icon(Icons.school_rounded, size: 36, color: Colors.white54)),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(course.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis)),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.textHint),
                  onPressed: onEdit,
                  style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(32, 32)),
                ),
              ]),
              if (course.description != null && course.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(course.description!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 12),
              Row(children: [
                _Chip(icon: Icons.class_rounded, label: '${course.classCount} lớp', color: AppColors.primary),
                const SizedBox(width: 8),
                _Chip(icon: Icons.people_rounded, label: 'Xem lớp', color: AppColors.secondary),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 20),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I03 — Create/Edit Course Screen
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
  final _formKey   = GlobalKey<FormState>();
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
      AppSnackBar.show(context, _isEdit ? 'Cập nhật thành công!' : 'Tạo khóa học thành công!', type: SnackType.success);
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
      appBar: AppBar(
        title: Text(_isEdit ? 'Chỉnh sửa khóa học' : 'Tạo khóa học mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header icon
            Center(
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF7C3AED)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.school_rounded, size: 36, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),

            AppTextField(
              label: 'Tên khóa học *',
              hint: 'VD: Lập trình Flutter nâng cao',
              controller: _titleCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên khóa học' : null,
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: 'Mô tả khóa học',
              hint: 'Mô tả nội dung, mục tiêu và yêu cầu của khóa học...',
              controller: _descCtrl,
              maxLines: 6,
            ),
            const SizedBox(height: 32),

            AppButton(
              label: _isEdit ? 'LƯU THAY ĐỔI' : 'TẠO KHÓA HỌC',
              onPressed: _save,
              isLoading: vm.isSaving,
              icon: _isEdit ? Icons.save_rounded : Icons.add_circle_rounded,
            ),

            if (!_isEdit) ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'HỦY',
                onPressed: () => Navigator.pop(context),
                variant: ButtonVariant.outline,
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
