import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I04 — Manage Classes (Instructor)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.add_circle_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Tạo lớp học kỳ mới'),
        ]),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(
              labelText: 'Tên lớp *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            )),
            const SizedBox(height: 12),
            TextField(controller: startCtrl, decoration: InputDecoration(
              labelText: 'Ngày bắt đầu (YYYY-MM-DD)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
            )),
            const SizedBox(height: 12),
            TextField(controller: endCtrl, decoration: InputDecoration(
              labelText: 'Ngày kết thúc (YYYY-MM-DD)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: const Icon(Icons.event_rounded, size: 18),
            )),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final vm  = context.read<InstructorManageViewModel>();
              final err = await vm.createClass(
                courseId:  widget.courseId,
                name:      nameCtrl.text.trim(),
                startDate: startCtrl.text.trim().isEmpty ? null : startCtrl.text.trim(),
                endDate:   endCtrl.text.trim().isEmpty   ? null : endCtrl.text.trim(),
              );
              if (!mounted) return;
              if (err == null) {
                context.read<ClassViewModel>().loadClassesByCourse(widget.courseId);
                AppSnackBar.show(context, 'Tạo lớp thành công!', type: SnackType.success);
              } else {
                AppSnackBar.show(context, err, type: SnackType.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Tạo lớp'),
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
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            tooltip: 'Tạo lớp mới',
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.classes.isEmpty
              ? EmptyState(
                  icon: Icons.class_outlined,
                  title: 'Chưa có lớp học kỳ',
                  message: 'Tạo lớp mới để học viên có thể tham gia.',
                  actionLabel: 'Tạo lớp',
                  onAction: _showCreateDialog,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.classes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ClassCard(
                    cls: vm.classes[i],
                    onTap: () => Navigator.pushNamed(context, '/instructor/classes/${vm.classes[i].id}'),
                    onManageMembers: () => Navigator.pushNamed(context, '/instructor/classes/${vm.classes[i].id}/members'),
                    onManagePaths: () => Navigator.pushNamed(context, '/instructor/classes/${vm.classes[i].id}/paths'),
                    onManageProjects: () => Navigator.pushNamed(context, '/instructor/classes/${vm.classes[i].id}/projects'),
                    onViewAnalytics: () => Navigator.pushNamed(context, '/instructor/analytics/${vm.classes[i].id}'),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final dynamic cls;
  final VoidCallback onTap;
  final VoidCallback onManageMembers;
  final VoidCallback onManagePaths;
  final VoidCallback onManageProjects;
  final VoidCallback onViewAnalytics;

  const _ClassCard({
    required this.cls,
    required this.onTap,
    required this.onManageMembers,
    required this.onManagePaths,
    required this.onManageProjects,
    required this.onViewAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        // Header
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 24),
          ),
          title: Text(cls.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          subtitle: Text('${cls.memberCount} học viên • ${cls.weekCount} tuần', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          trailing: PopupMenuButton<String>(
            onSelected: (v) {
              switch (v) {
                case 'members':  onManageMembers();  break;
                case 'paths':    onManagePaths();    break;
                case 'projects': onManageProjects(); break;
                case 'analytics': onViewAnalytics(); break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'members',   child: Row(children: [Icon(Icons.people_rounded, size: 16), SizedBox(width: 8), Text('Học viên')])),
              const PopupMenuItem(value: 'paths',     child: Row(children: [Icon(Icons.route_rounded, size: 16), SizedBox(width: 8), Text('Lộ trình')])),
              const PopupMenuItem(value: 'projects',  child: Row(children: [Icon(Icons.folder_special_rounded, size: 16), SizedBox(width: 8), Text('Dự án')])),
              const PopupMenuItem(value: 'analytics', child: Row(children: [Icon(Icons.bar_chart_rounded, size: 16), SizedBox(width: 8), Text('Analytics')])),
            ],
          ),
          onTap: onTap,
        ),

        // Progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(children: [
            Row(children: [
              const Text('Tiến độ:', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
              const Spacer(),
              Text('${(cls.progressPercent * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: cls.progressPercent,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 5,
              ),
            ),
          ]),
        ),

        // Quick action chips
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(children: [
            _QuickChip('Học viên', Icons.people_rounded, AppColors.primary, onManageMembers),
            const SizedBox(width: 8),
            _QuickChip('Lộ trình', Icons.route_rounded, AppColors.secondary, onManagePaths),
            const SizedBox(width: 8),
            _QuickChip('Dự án', Icons.folder_special_rounded, AppColors.warning, onManageProjects),
            const SizedBox(width: 8),
            _QuickChip('Thống kê', Icons.bar_chart_rounded, AppColors.info, onViewAnalytics),
          ]),
        ),
      ]),
    );
  }

  Widget _QuickChip(String label, IconData icon, Color color, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I05 — Class Members Management (Instructor)
// ════════════════════════════════════════════════════════════════════════════════
class ClassMembersManageScreen extends StatefulWidget {
  final int classId;
  const ClassMembersManageScreen({super.key, required this.classId});
  @override
  State<ClassMembersManageScreen> createState() => _ClassMembersManageScreenState();
}

class _ClassMembersManageScreenState extends State<ClassMembersManageScreen> {
  final _emailCtrl    = TextEditingController();
  final _searchCtrl   = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassViewModel>().loadMembers(widget.classId);
    });
  }

  @override
  void dispose() { _emailCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  Future<void> _addMember() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    final vm  = context.read<InstructorManageViewModel>();
    final err = await vm.addMemberByEmail(widget.classId, email);
    if (!mounted) return;
    if (err == null) {
      _emailCtrl.clear();
      context.read<ClassViewModel>().loadMembers(widget.classId);
      AppSnackBar.show(context, 'Thêm học viên thành công!', type: SnackType.success);
    } else {
      AppSnackBar.show(context, err, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm      = context.watch<ClassViewModel>();
    final members = vm.members.where((m) =>
      _searchQuery.isEmpty ||
      m.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      m.email.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Quản lý học viên (${vm.members.length})'),
      ),
      body: Column(children: [
        // Add member bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Nhập email học viên...',
                prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.textHint),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            )),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _addMember,
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Thêm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                elevation: 0,
              ),
            ),
          ]),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm học viên...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        const Divider(height: 1),

        // Members list
        Expanded(child: vm.isLoading
            ? const LoadingWidget()
            : members.isEmpty
                ? const EmptyState(icon: Icons.person_search_rounded, title: 'Không tìm thấy', message: 'Không có học viên phù hợp.')
                : ListView.separated(
                    itemCount: members.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                    itemBuilder: (_, i) {
                      final m = members[i];
                      return MemberListTile(
                        fullName:  m.fullName,
                        email:     m.email,
                        avatarUrl: m.avatarUrl,
                        userId:    m.userId,
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_rounded, color: AppColors.error, size: 22),
                          tooltip: 'Xoá khỏi lớp',
                          onPressed: () async {
                            final confirmed = await ConfirmDialog.show(
                              context,
                              title: 'Xoá học viên',
                              message: 'Xoá "${m.fullName}" khỏi lớp?',
                              confirmLabel: 'Xoá',
                              isDanger: true,
                            );
                            if (confirmed == true && context.mounted) {
                              final err = await context.read<InstructorManageViewModel>().removeMember(widget.classId, m.userId);
                              if (context.mounted) {
                                if (err == null) {
                                  context.read<ClassViewModel>().loadMembers(widget.classId);
                                  AppSnackBar.show(context, 'Đã xoá học viên.', type: SnackType.success);
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
