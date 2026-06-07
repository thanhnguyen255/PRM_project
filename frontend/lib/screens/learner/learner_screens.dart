import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../viewmodels/viewmodels.dart';
import '../../widgets/widgets.dart';

/// SCR-L06 - Notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (vm.unreadCount > 0)
            TextButton(
              onPressed: vm.markAllRead,
              child: const Text('Đánh dấu tất cả', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.notifications.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'Chưa có thông báo',
                  message: 'Các thông báo từ hệ thống sẽ xuất hiện ở đây.',
                )
              : RefreshIndicator(
                  onRefresh: vm.load,
                  color: AppColors.primary,
                  child: ListView.separated(
                    itemCount: vm.notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final n = vm.notifications[i];
                      return NotificationCard(
                        title: n.title,
                        body: n.body,
                        isRead: n.isRead,
                        createdAt: n.createdAt,
                        onTap: () => vm.markRead(n.id),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// SCR-L08 - Course Detail
class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});
  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseViewModel>().loadCourseDetail(widget.courseId);
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<CourseViewModel>();
    final course = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: vm.isLoading
          ? const LoadingWidget()
          : course == null
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Không tìm thấy', message: 'Khóa học không tồn tại.')
              : NestedScrollView(
                  headerSliverBuilder: (_, __) => [
                    SliverAppBar(
                      expandedHeight: 180,
                      floating: false,
                      pinned: true,
                      backgroundColor: AppColors.primary,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(course.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, Color(0xFF7C3AED)],
                            ),
                          ),
                          child: course.coverImageUrl != null
                              ? Image.network(course.coverImageUrl!, fit: BoxFit.cover, color: Colors.black26, colorBlendMode: BlendMode.darken)
                              : const Icon(Icons.school_rounded, size: 72, color: Colors.white30),
                        ),
                      ),
                      bottom: TabBar(
                        controller: _tabCtrl,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white60,
                        indicatorColor: Colors.white,
                        tabs: const [Tab(text: 'Lớp học kỳ'), Tab(text: 'Thông tin')],
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      // Tab 1: Class list (placeholder)
                      _buildClassList(course.id),
                      // Tab 2: Info
                      _buildInfo(course.description),
                    ],
                  ),
                ),
    );
  }

  Widget _buildClassList(int courseId) => Center(
    child: ElevatedButton(
      onPressed: () {},
      child: const Text('Xem các lớp học kỳ'),
    ),
  );

  Widget _buildInfo(String? desc) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Mô tả khóa học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text(desc ?? 'Chưa có mô tả.', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

/// SCR-L10 - Members List
class MembersScreen extends StatefulWidget {
  final int classId;
  const MembersScreen({super.key, required this.classId});
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassViewModel>().loadMembers(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClassViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Thành viên lớp (${vm.members.length} người)'),
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.members.isEmpty
              ? const EmptyState(icon: Icons.group_outlined, title: 'Chưa có thành viên', message: 'Lớp học chưa có học viên nào.')
              : ListView.separated(
                  itemCount: vm.members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = vm.members[i];
                    return MemberListTile(
                      fullName: m.fullName,
                      email: m.email,
                      avatarUrl: m.avatarUrl,
                      userId: m.userId,
                    );
                  },
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// SCR-L11 - Learning Path Overview
class LearningPathScreen extends StatefulWidget {
  final int classId;
  const LearningPathScreen({super.key, required this.classId});
  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningPathViewModel>().loadPaths(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LearningPathViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Lộ trình học')),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.paths.isEmpty
              ? const EmptyState(icon: Icons.route_rounded, title: 'Chưa có lộ trình', message: 'Giảng viên chưa tạo lộ trình học.')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.paths.length,
                  itemBuilder: (_, i) {
                    final p = vm.paths[i];
                    final isLast = i == vm.paths.length - 1;
                    return _WeekStep(path: p, isLast: isLast);
                  },
                ),
    );
  }
}

class _WeekStep extends StatelessWidget {
  final dynamic path;
  final bool isLast;

  const _WeekStep({required this.path, required this.isLast});

  Color get _stateColor => switch (path.state as String) {
    'completed'  => AppColors.success,
    'inProgress' => AppColors.primary,
    _            => AppColors.textHint,
  };

  IconData get _stateIcon => switch (path.state as String) {
    'completed'  => Icons.check_circle_rounded,
    'inProgress' => Icons.radio_button_checked_rounded,
    _            => Icons.lock_rounded,
  };

  @override
  Widget build(BuildContext context) => Column(children: [
    InkWell(
      onTap: path.state != 'locked' ? () {} : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _stateColor.withAlpha(path.state == 'locked' ? 51 : 128), width: path.state == 'inProgress' ? 2 : 1),
        ),
        child: Row(children: [
          Icon(_stateIcon, color: _stateColor, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(path.title as String, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: path.state == 'locked' ? AppColors.textHint : AppColors.textPrimary,
            )),
            const SizedBox(height: 4),
            Text(
              '${path.completedActivities}/${path.totalActivities} hoạt động',
              style: TextStyle(fontSize: 13, color: _stateColor),
            ),
          ])),
          if (path.state != 'locked')
            Icon(Icons.chevron_right_rounded, color: _stateColor),
        ]),
      ),
    ),
    if (!isLast)
      Container(width: 2, height: 24, color: AppColors.border),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────

/// SCR-L17/20/23 - Activity List (Pre/In/Post class)
class ActivityListScreen extends StatefulWidget {
  final int pathId;
  final String type; // "PreClass" | "InClass" | "PostClass"

  const ActivityListScreen({super.key, required this.pathId, required this.type});
  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityViewModel>().loadActivities(widget.pathId, type: widget.type);
    });
  }

  String get _screenTitle => switch (widget.type) {
    'PreClass'  => 'Pre-Class Activities',
    'InClass'   => 'In-Class Activities',
    'PostClass' => 'Post-Class Activities',
    _           => 'Activities',
  };

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivityViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_screenTitle)),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.activities.isEmpty
              ? const EmptyState(icon: Icons.task_outlined, title: 'Chưa có hoạt động', message: 'Chưa có hoạt động nào được tạo.')
              : RefreshIndicator(
                  onRefresh: () => vm.loadActivities(widget.pathId, type: widget.type),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.activities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final a = vm.activities[i];
                      return ActivityCard(
                        title: a.title,
                        type: a.type,
                        deadline: a.deadline,
                        submissionStatus: a.submissionStatus,
                        onTap: () => Navigator.pushNamed(context, '/activities/${a.id}'),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// SCR-L19/22/25 - Submit Evidence
class SubmitEvidenceScreen extends StatefulWidget {
  final int activityId;
  final String activityTitle;

  const SubmitEvidenceScreen({super.key, required this.activityId, required this.activityTitle});
  @override
  State<SubmitEvidenceScreen> createState() => _SubmitEvidenceScreenState();
}

class _SubmitEvidenceScreenState extends State<SubmitEvidenceScreen> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_noteCtrl.text.trim().isEmpty) {
      AppSnackBar.show(context, 'Vui lòng nhập ghi chú hoặc chọn file.', type: SnackType.warning);
      return;
    }
    final vm  = context.read<EvidenceViewModel>();
    final err = await vm.submitEvidence(activityId: widget.activityId, note: _noteCtrl.text.trim());
    if (!mounted) return;
    if (err == null) {
      AppSnackBar.show(context, 'Nộp evidence thành công!', type: SnackType.success);
      Navigator.pop(context);
    } else {
      AppSnackBar.show(context, err, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EvidenceViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Nộp bằng chứng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Activity info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(51)),
            ),
            child: Row(children: [
              const Icon(Icons.task_alt_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(widget.activityTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary))),
            ]),
          ),
          const SizedBox(height: 20),

          AppTextField(
            label: 'Ghi chú / Mô tả',
            hint: 'Nhập mô tả về những gì bạn đã làm...',
            controller: _noteCtrl,
            maxLines: 6,
          ),
          const SizedBox(height: 16),

          // File picker placeholder
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1.5, style: BorderStyle.solid),
            ),
            child: Column(children: [
              const Icon(Icons.attach_file_rounded, color: AppColors.textHint, size: 32),
              const SizedBox(height: 8),
              const Text('Chọn file đính kèm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              const Text('JPG, PNG, PDF, MP4 · Tối đa 50MB', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
              const SizedBox(height: 12),
              AppButton(label: 'CHỌN FILE', onPressed: () {}, variant: ButtonVariant.outline, isFullWidth: false),
            ]),
          ),
          const SizedBox(height: 32),

          AppButton(
            label: 'NỘP BẰNG CHỨNG',
            onPressed: _submit,
            isLoading: vm.isSubmitting,
          ),
        ]),
      ),
    );
  }
}
