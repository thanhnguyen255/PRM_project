import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../viewmodels/extended_viewmodels.dart';
import '../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L26 — Project List
// ════════════════════════════════════════════════════════════════════════════════
class ProjectListScreen extends StatefulWidget {
  final int classId;
  const ProjectListScreen({super.key, required this.classId});
  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
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
      appBar: AppBar(title: const Text('Dự án')),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.projects.isEmpty
              ? const EmptyState(
                  icon: Icons.folder_outlined,
                  title: 'Chưa có dự án',
                  message: 'Giảng viên chưa tạo dự án.',
                )
              : RefreshIndicator(
                  onRefresh: () => vm.loadProjects(widget.classId),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = vm.projects[i];
                      return _ProjectCard(project: p, onTap: () =>
                          Navigator.pushNamed(context, '/projects/${p.id}'));
                    },
                  ),
                ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final dynamic project;
  final VoidCallback onTap;
  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final total     = project.milestoneCount as int;
    final completed = project.completedMilestones as int;
    final progress  = total == 0 ? 0.0 : completed / total;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.folder_special_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(project.title as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              Text('$completed/$total milestones', style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ]),
          if (total > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
                minHeight: 6,
              ),
            ),
          ],
          if (project.nextMilestoneTitle != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.warning),
                const SizedBox(width: 6),
                Expanded(child: Text('Tiếp theo: ${project.nextMilestoneTitle}',
                    style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w500))),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L27 — Project Detail
// ════════════════════════════════════════════════════════════════════════════════
class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  const ProjectDetailScreen({super.key, required this.projectId});
  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().loadProjectDetail(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<ProjectViewModel>();
    final detail = vm.projectDetail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(detail?['title'] as String? ?? 'Dự án')),
      body: vm.isLoading
          ? const LoadingWidget()
          : detail == null
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Không tìm thấy', message: '')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if ((detail['description'] as String?) != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(detail['description'] as String, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SectionHeader(title: 'Milestones'),
                    const SizedBox(height: 8),

                    if ((detail['milestones'] as List?)?.isEmpty ?? true)
                      const EmptyState(icon: Icons.flag_outlined, title: 'Chưa có milestone', message: '')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (detail['milestones'] as List).length,
                        itemBuilder: (_, i) {
                          final m    = (detail['milestones'] as List)[i] as Map<String,dynamic>;
                          final done = m['isSubmitted'] as bool? ?? false;
                          return _MilestoneStepItem(
                            milestone: m,
                            isDone: done,
                            isLast: i == (detail['milestones'] as List).length - 1,
                            onTap: () => Navigator.pushNamed(context, '/milestones/${m['id']}'),
                          );
                        },
                      ),
                  ]),
                ),
    );
  }
}

class _MilestoneStepItem extends StatelessWidget {
  final Map<String,dynamic> milestone;
  final bool isDone;
  final bool isLast;
  final VoidCallback onTap;

  const _MilestoneStepItem({required this.milestone, required this.isDone, required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) => Column(children: [
    InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDone ? AppColors.success.withAlpha(100) : AppColors.border,
          ),
        ),
        child: Row(children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? AppColors.success : AppColors.textHint,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Milestone ${milestone['stepNumber']}: ${milestone['title']}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (milestone['dueDate'] != null)
              Text('Hạn: ${_fmtDate(milestone['dueDate'] as String)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ]),
      ),
    ),
    if (!isLast) Container(width: 2, height: 20, color: AppColors.border),
  ]);

  String _fmtDate(String d) {
    final dt = DateTime.tryParse(d);
    if (dt == null) return d;
    return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
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

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L31 — Review Sessions
// ════════════════════════════════════════════════════════════════════════════════
class ReviewSessionsScreen extends StatefulWidget {
  final int classId;
  const ReviewSessionsScreen({super.key, required this.classId});
  @override
  State<ReviewSessionsScreen> createState() => _ReviewSessionsScreenState();
}

class _ReviewSessionsScreenState extends State<ReviewSessionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().loadSessions(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Peer Review')),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.sessions.isEmpty
              ? const EmptyState(
                  icon: Icons.rate_review_outlined,
                  title: 'Chưa có phiên review',
                  message: 'Giảng viên chưa tạo phiên peer review.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final s = vm.sessions[i];
                    return _ReviewSessionCard(session: s, onTap: () =>
                        Navigator.pushNamed(context, '/review-sessions/${s.id}'));
                  },
                ),
    );
  }
}

class _ReviewSessionCard extends StatelessWidget {
  final dynamic session;
  final VoidCallback onTap;
  const _ReviewSessionCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOpen = session.isOpen as bool;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOpen ? AppColors.success.withAlpha(100) : AppColors.border,
            width: isOpen ? 2 : 1,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(session.title as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
            StatusBadge(status: isOpen ? BadgeStatus.open : BadgeStatus.closed),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text(
              '${_fmtDate(session.startDate)} → ${_fmtDate(session.endDate)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _pill('${session.myCompletedCount}/${session.myAssignmentCount}', Icons.assignment_turned_in_rounded, AppColors.success),
            const SizedBox(width: 8),
            const Text('phiếu đã nộp', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          ]),
        ]),
      ),
    );
  }

  Widget _pill(String text, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    ]),
  );

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}';
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L32 — Review Detail + L33 Submit Feedback + L34 Received Feedback
// ════════════════════════════════════════════════════════════════════════════════
class ReviewDetailScreen extends StatefulWidget {
  final int sessionId;
  const ReviewDetailScreen({super.key, required this.sessionId});
  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<ReviewViewModel>();
      await vm.loadSessionDetail(widget.sessionId);
      await vm.loadReceivedFeedback(widget.sessionId);
    });
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<ReviewViewModel>();
    final detail = vm.sessionDetail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(detail?['title'] as String? ?? 'Review Detail'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Phiếu của tôi'),
            Tab(text: 'Feedback nhận được'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _MyAssignmentsTab(detail: detail, sessionId: widget.sessionId),
                _ReceivedFeedbackTab(feedbacks: vm.receivedFeedback),
              ],
            ),
    );
  }
}

class _MyAssignmentsTab extends StatelessWidget {
  final Map<String,dynamic>? detail;
  final int sessionId;
  const _MyAssignmentsTab({this.detail, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final assignments = (detail?['myAssignments'] as List<dynamic>?) ?? [];
    if (assignments.isEmpty) return const EmptyState(icon: Icons.assignment_outlined, title: 'Chưa có phiếu', message: 'Bạn chưa được phân công review.');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = assignments[i] as Map<String,dynamic>;
        final hasFeedback = a['hasFeedback'] as bool? ?? false;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(
                (a['revieweeName'] as String? ?? '?').isNotEmpty ? (a['revieweeName'] as String)[0] : '?',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ),
            title: Text(a['revieweeName'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(hasFeedback ? '✅ Đã gửi feedback' : '⏳ Chưa gửi feedback',
                style: TextStyle(fontSize: 12, color: hasFeedback ? AppColors.success : AppColors.warning)),
            trailing: hasFeedback
                ? const Icon(Icons.check_circle_rounded, color: AppColors.success)
                : ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/submit-feedback', arguments: {
                      'assignmentId': a['id'],
                      'revieweeName': a['revieweeName'],
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      elevation: 0,
                    ),
                    child: const Text('Review'),
                  ),
          ),
        );
      },
    );
  }
}

class _ReceivedFeedbackTab extends StatelessWidget {
  final List<dynamic> feedbacks;
  const _ReceivedFeedbackTab({required this.feedbacks});

  @override
  Widget build(BuildContext context) {
    if (feedbacks.isEmpty) return const EmptyState(icon: Icons.feedback_outlined, title: 'Chưa có feedback', message: 'Bạn chưa nhận được feedback nào.');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: feedbacks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final f = feedbacks[i] as dynamic;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: Text(f.reviewerName.toString().isNotEmpty ? f.reviewerName.toString()[0] : '?',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(f.reviewerName.toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
              Row(mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (j) => Icon(j < (f.rating as int) ? Icons.star_rounded : Icons.star_outline_rounded, size: 16, color: AppColors.warning)),
              ),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
              child: Text(f.content.toString(), style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
          ]),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L33 — Submit Feedback Screen
// ════════════════════════════════════════════════════════════════════════════════
class SubmitFeedbackScreen extends StatefulWidget {
  final int assignmentId;
  final String revieweeName;
  const SubmitFeedbackScreen({super.key, required this.assignmentId, required this.revieweeName});
  @override
  State<SubmitFeedbackScreen> createState() => _SubmitFeedbackScreenState();
}

class _SubmitFeedbackScreenState extends State<SubmitFeedbackScreen> {
  final _contentCtrl = TextEditingController();
  int _rating        = 0;

  @override
  void dispose() { _contentCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_rating == 0) {
      AppSnackBar.show(context, 'Vui lòng chọn điểm đánh giá.', type: SnackType.warning);
      return;
    }
    if (_contentCtrl.text.trim().isEmpty) {
      AppSnackBar.show(context, 'Vui lòng nhập nội dung feedback.', type: SnackType.warning);
      return;
    }
    final vm  = context.read<ReviewViewModel>();
    final err = await vm.submitFeedback(
      assignmentId: widget.assignmentId,
      content: _contentCtrl.text.trim(),
      rating: _rating,
    );
    if (!mounted) return;
    if (err == null) {
      AppSnackBar.show(context, 'Gửi feedback thành công!', type: SnackType.success);
      Navigator.pop(context);
    } else {
      AppSnackBar.show(context, err, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Gửi Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Reviewee info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.person_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Text('Đánh giá: ${widget.revieweeName}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 24),

          // Star rating
          const Text('Điểm đánh giá *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _rating = i + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 36,
                  color: i < _rating ? AppColors.warning : AppColors.textHint,
                ),
              ),
            )),
          ),
          const SizedBox(height: 8),
          Text(
            _rating == 0 ? 'Chưa chọn' : ['', '⭐ Kém', '⭐⭐ Trung bình', '⭐⭐⭐ Khá', '⭐⭐⭐⭐ Tốt', '⭐⭐⭐⭐⭐ Xuất sắc'][_rating],
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          AppTextField(
            label: 'Nội dung feedback *',
            hint: 'Nhập nhận xét về bài làm của bạn này...',
            controller: _contentCtrl,
            maxLines: 7,
          ),
          const SizedBox(height: 32),

          AppButton(
            label: 'GỬI FEEDBACK',
            onPressed: _submit,
            isLoading: vm.isSaving,
            icon: Icons.send_rounded,
          ),
        ]),
      ),
    );
  }
}
