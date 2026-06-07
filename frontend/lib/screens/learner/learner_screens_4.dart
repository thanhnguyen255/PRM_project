import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../services/api_service.dart';
import '../../viewmodels/extended_viewmodels.dart';
import '../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L37/38/39 — Learning Progress
// ════════════════════════════════════════════════════════════════════════════════
class ProgressScreen extends StatefulWidget {
  final int? classId;
  const ProgressScreen({super.key, this.classId});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().loadMyProgress(classId: widget.classId);
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<AnalyticsViewModel>();
    final data = vm.myProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tiến độ học tập'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Tổng quan'),
            Tab(text: 'Hoạt động'),
            Tab(text: 'Dự án'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : data == null
              ? const EmptyState(icon: Icons.bar_chart_outlined, title: 'Chưa có dữ liệu', message: 'Hoàn thành các hoạt động để xem tiến độ.')
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _OverviewTab(data: data),
                    _ActivityProgressTab(data: data),
                    _ProjectProgressTab(data: data),
                  ],
                ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Map<String, dynamic> data;
  const _OverviewTab({required this.data});

  @override
  Widget build(BuildContext context) {
    final overall = (data['overallProgress'] as num?)?.toDouble() ?? 0.0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Overall progress ring (visual)
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140, height: 140,
                child: CircularProgressIndicator(
                  value: overall,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.success),
                  strokeWidth: 12,
                ),
              ),
              Column(children: [
                Text('${(overall * 100).toInt()}%',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const Text('Hoàn thành', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Stat grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            StatCard(value: '${data['completedActivities'] ?? 0}', label: 'Hoạt động\nhoàn thành', icon: Icons.task_alt_rounded),
            StatCard(value: '${data['pendingActivities'] ?? 0}', label: 'Chờ\nduyệt', color: AppColors.warning, icon: Icons.pending_actions_rounded),
            StatCard(value: '${data['completedMilestones'] ?? 0}', label: 'Milestone\nhoàn thành', color: AppColors.secondary, icon: Icons.flag_rounded),
            StatCard(value: '${data['feedbackReceived'] ?? 0}', label: 'Feedback\nnhận được', color: AppColors.info, icon: Icons.feedback_rounded),
          ],
        ),

        const SizedBox(height: 20),
        const Text('Tiến độ từng tuần', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...((data['weeklyProgress'] as List<dynamic>?) ?? []).map((w) {
          final week     = w as Map<String,dynamic>;
          final progress = (week['progress'] as num?)?.toDouble() ?? 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(week['title'] as String? ?? 'Tuần', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(progress >= 1.0 ? AppColors.success : AppColors.primary),
                  minHeight: 8,
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

class _ActivityProgressTab extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ActivityProgressTab({required this.data});

  @override
  Widget build(BuildContext context) {
    final activities = (data['activityDetails'] as List<dynamic>?) ?? [];
    if (activities.isEmpty) return const EmptyState(icon: Icons.task_outlined, title: 'Chưa có dữ liệu', message: '');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final a      = activities[i] as Map<String,dynamic>;
        final status = a['status'] as String? ?? 'pending';
        return ListTile(
          leading: Icon(
            switch (status) { 'Approved' => Icons.check_circle_rounded, 'Rejected' => Icons.cancel_rounded, _ => Icons.radio_button_unchecked_rounded },
            color: switch (status) { 'Approved' => AppColors.success, 'Rejected' => AppColors.error, _ => AppColors.textHint },
          ),
          title: Text(a['title'] as String? ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Text(a['type'] as String? ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          trailing: StatusBadge(status: StatusBadge.fromString(status)),
        );
      },
    );
  }
}

class _ProjectProgressTab extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ProjectProgressTab({required this.data});

  @override
  Widget build(BuildContext context) {
    final projects = (data['projectProgress'] as List<dynamic>?) ?? [];
    if (projects.isEmpty) return const EmptyState(icon: Icons.folder_outlined, title: 'Chưa có dự án', message: '');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final p        = projects[i] as Map<String,dynamic>;
        final progress = (p['progress'] as num?)?.toDouble() ?? 0.0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p['title'] as String? ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.success),
                  minHeight: 8,
                ),
              )),
              const SizedBox(width: 10),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
            ]),
            Text('${p['completedMilestones'] ?? 0}/${p['totalMilestones'] ?? 0} milestones', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          ]),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L41 — Edit Profile
// ════════════════════════════════════════════════════════════════════════════════
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _isSaving   = false;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final res = await ApiService.instance.put('/users/me', data: {
      'fullName': _nameCtrl.text.trim(),
    });
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (res['success'] == true) {
      AppSnackBar.show(context, 'Cập nhật thành công!', type: SnackType.success);
      Navigator.pop(context);
    } else {
      AppSnackBar.show(context, res['message'] as String? ?? 'Lỗi cập nhật', type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('Chỉnh sửa hồ sơ')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person_rounded, size: 52, color: AppColors.primary),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AppTextField(
            label: 'Họ và tên',
            hint: 'Nguyễn Văn A',
            controller: _nameCtrl,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
          ),
          const SizedBox(height: 16),

          AppTextField(
            label: 'Email (không thể thay đổi)',
            hint: 'email@example.com',
            controller: _emailCtrl,
            readOnly: true,
          ),
          const SizedBox(height: 32),

          AppButton(label: 'LƯU THAY ĐỔI', onPressed: _save, isLoading: _isSaving, icon: Icons.save_rounded),
        ]),
      ),
    ),
  );
}
