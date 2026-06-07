import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/models.dart';
import '../../viewmodels/viewmodels.dart';
import '../../viewmodels/extended_viewmodels.dart';
import '../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L09 — Class Detail
// ════════════════════════════════════════════════════════════════════════════════
class ClassDetailScreen extends StatefulWidget {
  final int classId;
  const ClassDetailScreen({super.key, required this.classId});
  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassViewModel>().loadClass(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClassViewModel>();
    final cls = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: vm.isLoading
          ? const LoadingWidget()
          : cls == null
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Không tìm thấy', message: '')
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 140,
                      pinned: true,
                      backgroundColor: AppColors.primary,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(cls.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, Color(0xFF7C3AED)],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Stats row
                          Row(children: [
                            Expanded(child: StatCard(value: '${cls.memberCount}', label: 'Học viên', icon: Icons.group_rounded)),
                            const SizedBox(width: 10),
                            Expanded(child: StatCard(value: '${cls.weekCount}', label: 'Tuần học', icon: Icons.calendar_today_rounded)),
                            const SizedBox(width: 10),
                            Expanded(child: StatCard(
                              value: '${(cls.progressPercent * 100).toInt()}%',
                              label: 'Hoàn thành',
                              color: AppColors.success,
                              icon: Icons.check_circle_rounded,
                            )),
                          ]),
                          const SizedBox(height: 20),

                          // Progress bar
                          const Text('Tiến độ học tập', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: cls.progressPercent,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(AppColors.success),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Quick actions
                          const Text('Truy cập nhanh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Wrap(spacing: 10, runSpacing: 10, children: [
                            _actionChip(Icons.route_rounded, 'Lộ trình', AppColors.primary, () =>
                                Navigator.pushNamed(context, '/classes/${widget.classId}/learning-path')),
                            _actionChip(Icons.group_rounded, 'Thành viên', AppColors.secondary, () =>
                                Navigator.pushNamed(context, '/classes/${widget.classId}/members')),
                            _actionChip(Icons.folder_special_rounded, 'Dự án', AppColors.warning, () =>
                                Navigator.pushNamed(context, '/projects', arguments: {'classId': widget.classId})),
                            _actionChip(Icons.rate_review_rounded, 'Review', AppColors.success, () =>
                                Navigator.pushNamed(context, '/review-sessions', arguments: {'classId': widget.classId})),
                            _actionChip(Icons.insights_rounded, 'Tiến độ', AppColors.info, () =>
                                Navigator.pushNamed(context, '/progress', arguments: {'classId': widget.classId})),
                          ]),

                          if (cls.startDate != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(children: [
                                _infoRow(Icons.calendar_today_rounded, 'Bắt đầu',
                                    '${cls.startDate!.day.toString().padLeft(2,'0')}/${cls.startDate!.month.toString().padLeft(2,'0')}/${cls.startDate!.year}'),
                                if (cls.endDate != null) ...[
                                  const Divider(height: 16),
                                  _infoRow(Icons.event_rounded, 'Kết thúc',
                                      '${cls.endDate!.day.toString().padLeft(2,'0')}/${cls.endDate!.month.toString().padLeft(2,'0')}/${cls.endDate!.year}'),
                                ],
                              ]),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _actionChip(IconData icon, String label, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withAlpha(80)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      );

  Widget _infoRow(IconData icon, String label, String value) => Row(children: [
    Icon(icon, size: 16, color: AppColors.textHint),
    const SizedBox(width: 8),
    Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
    Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
  ]);
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L12 — Learning Path Detail (Week Detail)
// ════════════════════════════════════════════════════════════════════════════════
class WeekDetailScreen extends StatefulWidget {
  final int pathId;
  const WeekDetailScreen({super.key, required this.pathId});
  @override
  State<WeekDetailScreen> createState() => _WeekDetailScreenState();
}

class _WeekDetailScreenState extends State<WeekDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningPathViewModel>().loadPathDetail(widget.pathId);
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<LearningPathViewModel>();
    final detail = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(detail?['title'] as String? ?? 'Chi tiết tuần'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Tài liệu'),
            Tab(text: 'Pre-Class'),
            Tab(text: 'In-Class'),
            Tab(text: 'Post-Class'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : detail == null
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Không tìm thấy', message: '')
              : TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _MaterialsTab(materials: (detail['materials'] as List<dynamic>?) ?? []),
                    _ActivitiesTab(activities: (detail['preClassActivities'] as List<dynamic>?) ?? [], type: 'PreClass'),
                    _ActivitiesTab(activities: (detail['inClassActivities'] as List<dynamic>?) ?? [], type: 'InClass'),
                    _ActivitiesTab(activities: (detail['postClassActivities'] as List<dynamic>?) ?? [], type: 'PostClass'),
                  ],
                ),
    );
  }
}

class _MaterialsTab extends StatelessWidget {
  final List<dynamic> materials;
  const _MaterialsTab({required this.materials});

  IconData _typeIcon(String type) => switch (type) {
    'Video'    => Icons.play_circle_rounded,
    'Document' => Icons.picture_as_pdf_rounded,
    'Link'     => Icons.link_rounded,
    _          => Icons.attach_file_rounded,
  };

  Color _typeColor(String type) => switch (type) {
    'Video'    => AppColors.error,
    'Document' => AppColors.primary,
    'Link'     => AppColors.secondary,
    _          => AppColors.textHint,
  };

  @override
  Widget build(BuildContext context) => materials.isEmpty
      ? const EmptyState(icon: Icons.folder_open_rounded, title: 'Chưa có tài liệu', message: 'Giảng viên chưa upload tài liệu.')
      : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: materials.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final m    = materials[i] as Map<String, dynamic>;
            final type = m['type'] as String? ?? 'Link';
            return Card(
              child: ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _typeColor(type).withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_typeIcon(type), color: _typeColor(type), size: 22),
                ),
                title: Text(m['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                subtitle: Text(type, style: TextStyle(fontSize: 12, color: _typeColor(type))),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
                onTap: () {
                  // ignore: unused_local_variable
                  final link = m['linkUrl'] as String? ?? m['fileUrl'] as String?;
                  if (link == null || link.isEmpty) return;
                  if (type == 'Video') {
                    Navigator.pushNamed(context, '/video-player', arguments: {
                      'url': link,
                      'title': m['title'] as String? ?? 'Video',
                    });
                  } else {
                    Navigator.pushNamed(context, '/document-viewer', arguments: {
                      'url': link,
                      'title': m['title'] as String? ?? 'Tài liệu',
                      'type': type,
                    });
                  }
                },
              ),
            );
          },
        );
}

class _ActivitiesTab extends StatelessWidget {
  final List<dynamic> activities;
  final String type;
  const _ActivitiesTab({required this.activities, required this.type});

  @override
  Widget build(BuildContext context) => activities.isEmpty
      ? EmptyState(
          icon: Icons.task_outlined,
          title: 'Chưa có hoạt động',
          message: 'Chưa có hoạt động $type nào.',
        )
      : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final a = activities[i] as Map<String, dynamic>;
            return ActivityCard(
              title: a['title'] as String? ?? '',
              type: type,
              deadline: a['deadline'] != null ? DateTime.tryParse(a['deadline'] as String) : null,
              submissionStatus: a['submissionStatus'] as String?,
              onTap: () => Navigator.pushNamed(context, '/activities/${a['id']}'),
            );
          },
        );
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L13/14 — Materials List + Detail
// ════════════════════════════════════════════════════════════════════════════════
class MaterialsListScreen extends StatefulWidget {
  final int pathId;
  const MaterialsListScreen({super.key, required this.pathId});
  @override
  State<MaterialsListScreen> createState() => _MaterialsListScreenState();
}

class _MaterialsListScreenState extends State<MaterialsListScreen> {
  static const _filters = ['Tất cả', 'Video', 'Document', 'Link'];
  String _filter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() => context.read<MaterialViewModel>().loadMaterials(widget.pathId);

  List<Map<String,dynamic>> get _filtered {
    final vm = context.read<MaterialViewModel>();
    if (_filter == 'Tất cả') return vm.materials;
    return vm.materials.where((m) => m['type'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MaterialViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tài liệu học tập')),
      body: Column(children: [
        const SizedBox(height: 12),
        FilterChipGroup(options: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f)),
        const SizedBox(height: 12),
        Expanded(child: vm.isLoading
            ? const LoadingWidget()
            : _filtered.isEmpty
                ? const EmptyState(icon: Icons.folder_open_rounded, title: 'Chưa có tài liệu', message: 'Không có tài liệu phù hợp.')
                : RefreshIndicator(
                    onRefresh: () async => _load(),
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final m = _filtered[i];
                        final type = m['type'] as String? ?? 'Link';
                        return _MaterialCard(material: m, type: type);
                      },
                    ),
                  ),
        ),
      ]),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String,dynamic> material;
  final String type;
  const _MaterialCard({required this.material, required this.type});

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      'Video'    => AppColors.error,
      'Document' => AppColors.primary,
      'Link'     => AppColors.secondary,
      _          => AppColors.textHint,
    };
    final icon = switch (type) {
      'Video'    => Icons.play_circle_filled_rounded,
      'Document' => Icons.picture_as_pdf_rounded,
      'Link'     => Icons.open_in_new_rounded,
      _          => Icons.attach_file_rounded,
    };

    return InkWell(
      onTap: () {
        final link = material['linkUrl'] as String? ?? material['fileUrl'] as String?;
        if (link == null || link.isEmpty) return;
        if (type == 'Video') {
          Navigator.pushNamed(context, '/video-player', arguments: {
            'url': link,
            'title': material['title'] as String? ?? 'Video',
          });
        } else {
          Navigator.pushNamed(context, '/document-viewer', arguments: {
            'url': link,
            'title': material['title'] as String? ?? 'Tài liệu',
            'type': type,
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(material['title'] as String? ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(6)),
              child: Text(type, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ),
          ])),
          Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L18/21/24 — Activity Detail
// ════════════════════════════════════════════════════════════════════════════════
class ActivityDetailScreen extends StatefulWidget {
  final int activityId;
  const ActivityDetailScreen({super.key, required this.activityId});
  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityViewModel>().loadDetail(widget.activityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<ActivityViewModel>();
    final detail = vm.detail;
    final activity = detail != null ? ActivityModel.fromJson(detail) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết hoạt động'),
        actions: [
          if (activity?.submissionStatus == null)
            TextButton.icon(
              onPressed: activity != null
                  ? () => Navigator.pushNamed(context, '/submit-evidence', arguments: {
                      'activityId': activity.id,
                      'activityTitle': activity.title,
                    })
                  : null,
              icon: const Icon(Icons.upload_rounded, size: 18, color: AppColors.primary),
              label: const Text('Nộp', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : detail == null
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Không tìm thấy', message: '')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Header card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (activity != null) Row(children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ActivityCard.typeColor(activity.type),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: ActivityCard.typeColor(activity.type).withAlpha(26),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ActivityCard.typeLabel(activity.type),
                              style: TextStyle(fontSize: 11, color: ActivityCard.typeColor(activity.type), fontWeight: FontWeight.w700),
                            ),
                          ),
                          const Spacer(),
                          if (activity.submissionStatus != null)
                            StatusBadge(status: StatusBadge.fromString(activity.submissionStatus)),
                        ]),
                        const SizedBox(height: 10),
                        Text(detail['title'] as String? ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        if (activity?.deadline != null) ...[
                          const SizedBox(height: 8),
                          Row(children: [
                            Icon(
                              Icons.timer_rounded,
                              size: 16,
                              color: activity!.isOverdue ? AppColors.error : activity.isUrgent ? AppColors.warning : AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Hạn: ${_formatDt(activity.deadline!)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: activity.isOverdue ? AppColors.error : activity.isUrgent ? AppColors.warning : AppColors.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ]),
                        ],
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    if ((detail['description'] as String?) != null) ...[
                      const Text('Mô tả & Yêu cầu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          detail['description'] as String,
                          style: const TextStyle(fontSize: 14, height: 1.7, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Submission info
                    if (detail['submission'] != null) ...[
                      const Text('Bài nộp của bạn', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _SubmissionCard(submission: detail['submission'] as Map<String,dynamic>),
                      const SizedBox(height: 16),
                    ],

                    // CTA button
                    if (activity?.submissionStatus == null)
                      AppButton(
                        label: 'NỘP BẰNG CHỨNG',
                        onPressed: () => Navigator.pushNamed(context, '/submit-evidence', arguments: {
                          'activityId': widget.activityId,
                          'activityTitle': detail['title'],
                        }),
                        icon: Icons.upload_rounded,
                      ),
                  ]),
                ),
    );
  }

  String _formatDt(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} '
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
}

class _SubmissionCard extends StatelessWidget {
  final Map<String,dynamic> submission;
  const _SubmissionCard({required this.submission});

  @override
  Widget build(BuildContext context) {
    final status = submission['status'] as String? ?? 'Pending';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Trạng thái:', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
          const SizedBox(width: 8),
          StatusBadge(status: StatusBadge.fromString(status)),
        ]),
        if ((submission['note'] as String?) != null && (submission['note'] as String).isNotEmpty) ...[
          const Divider(height: 16),
          Text('Ghi chú: ${submission['note']}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
        const Divider(height: 16),
        Row(children: [
          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textHint),
          const SizedBox(width: 4),
          Text(
            'Nộp: ${submission['submittedAt'] != null ? _fmtDt(DateTime.parse(submission['submittedAt'] as String)) : 'N/A'}',
            style: const TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/evidences/${submission['id']}'),
            child: const Text('Xem chi tiết', style: TextStyle(fontSize: 12)),
          ),
        ]),
      ]),
    );
  }

  String _fmtDt(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')} '
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L35 — Evidence Detail (Learner view)
// ════════════════════════════════════════════════════════════════════════════════
class EvidenceDetailLearnerScreen extends StatefulWidget {
  final int evidenceId;
  const EvidenceDetailLearnerScreen({super.key, required this.evidenceId});
  @override
  State<EvidenceDetailLearnerScreen> createState() => _EvidenceDetailLearnerState();
}

class _EvidenceDetailLearnerState extends State<EvidenceDetailLearnerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<EvidenceViewModel>();
      await vm.loadDetail(widget.evidenceId);
      await vm.loadComments(widget.evidenceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EvidenceViewModel>();
    final e  = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết Evidence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.comment_rounded),
            onPressed: () => Navigator.pushNamed(context, '/evidences/${widget.evidenceId}/comments'),
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : e == null
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Không tìm thấy', message: '')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Status banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _statusBg(e.status),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _statusColor(e.status).withAlpha(80)),
                      ),
                      child: Row(children: [
                        Icon(_statusIcon(e.status), color: _statusColor(e.status), size: 24),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_statusLabel(e.status),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _statusColor(e.status))),
                          Text(_statusMessage(e.status), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ])),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Activity info
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.activityTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('Nộp lúc: ${_fmtDt(e.submittedAt)}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                        if (e.reviewedAt != null) Text('Duyệt lúc: ${_fmtDt(e.reviewedAt!)}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    if ((e.note ?? '').isNotEmpty) ...[
                      const Text('Ghi chú của bạn', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(e.note!, style: const TextStyle(fontSize: 14, height: 1.6)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    AppButton(
                      label: 'Xem bình luận (${e.commentCount})',
                      onPressed: () => Navigator.pushNamed(context, '/evidences/${widget.evidenceId}/comments'),
                      variant: ButtonVariant.outline,
                      icon: Icons.comment_rounded,
                    ),
                  ]),
                ),
    );
  }

  Color _statusColor(String s) => switch (s) {
    'Approved' => AppColors.success,
    'Rejected' => AppColors.error,
    _          => AppColors.warning,
  };

  Color _statusBg(String s) => switch (s) {
    'Approved' => AppColors.successLight,
    'Rejected' => AppColors.errorLight,
    _          => AppColors.warningLight,
  };

  IconData _statusIcon(String s) => switch (s) {
    'Approved' => Icons.check_circle_rounded,
    'Rejected' => Icons.cancel_rounded,
    _          => Icons.hourglass_empty_rounded,
  };

  String _statusLabel(String s) => switch (s) {
    'Approved' => '✅ Đã được chấp nhận',
    'Rejected' => '❌ Bị từ chối',
    _          => '⏳ Đang chờ duyệt',
  };

  String _statusMessage(String s) => switch (s) {
    'Approved' => 'Giảng viên đã duyệt bài nộp của bạn.',
    'Rejected' => 'Hãy xem comment của giảng viên và nộp lại.',
    _          => 'Bài nộp đang được giảng viên xem xét.',
  };

  String _fmtDt(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} '
      '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L36 — Evidence Comments (Chat-style)
// ════════════════════════════════════════════════════════════════════════════════
class EvidenceCommentsScreen extends StatefulWidget {
  final int evidenceId;
  const EvidenceCommentsScreen({super.key, required this.evidenceId});
  @override
  State<EvidenceCommentsScreen> createState() => _EvidenceCommentsScreenState();
}

class _EvidenceCommentsScreenState extends State<EvidenceCommentsScreen> {
  final _ctrl       = TextEditingController();
  final _scrollCtrl = ScrollController();
  final int _myId   = 0; // TODO: load from SharedPreferences

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvidenceViewModel>().loadComments(widget.evidenceId);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty) return;
    final vm  = context.read<EvidenceViewModel>();
    final err = await vm.addComment(widget.evidenceId, txt);
    if (!mounted) return;
    if (err == null) {
      _ctrl.clear();
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      AppSnackBar.show(context, err, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EvidenceViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bình luận')),
      body: Column(children: [
        Expanded(child: vm.comments.isEmpty
            ? const EmptyState(icon: Icons.chat_bubble_outline_rounded, title: 'Chưa có bình luận', message: 'Hãy là người đầu tiên bình luận!')
            : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: vm.comments.length,
                itemBuilder: (_, i) {
                  final c = vm.comments[i];
                  return CommentTile(
                    authorName: c.authorName,
                    authorAvatar: c.authorAvatar,
                    authorId: c.authorId,
                    isInstructor: c.isInstructor,
                    content: c.content,
                    createdAt: c.createdAt,
                    currentUserId: _myId,
                  );
                },
              ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            child: Row(children: [
              Expanded(child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  hintText: 'Nhập bình luận...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                maxLines: null,
              )),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _send,
                icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
