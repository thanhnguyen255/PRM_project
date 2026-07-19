import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ─── Helper: wrap Map<String,dynamic> as typed access ─────────────────────────
class _A {
  final Map<String, dynamic> _m;
  const _A(this._m);
  String  get title             => _m['title'] as String? ?? '';
  String? get description       => _m['description'] as String?;
  String? get type              => _m['type'] as String?;
  int     get learningPathId    => _m['learningPathId'] as int? ?? 0;
  String? get submissionStatus  => _m['submissionStatus'] as String? ?? (_m['submission'] != null ? _m['submission']['status'] as String? : null);
  DateTime? get deadline {
    final v = _m['deadline'];
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L08/L09 — Pre-Class Activity Detail (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class PreClassActivityScreen extends StatefulWidget {
  final int activityId;
  const PreClassActivityScreen({super.key, required this.activityId});
  @override
  State<PreClassActivityScreen> createState() => _PreClassActivityState();
}

class _PreClassActivityState extends State<PreClassActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityViewModel>().loadDetail(widget.activityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm  = context.watch<ActivityViewModel>();
    final raw = vm.detail;
    final a   = raw != null ? _A(raw) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(a?.title ?? 'Pre-Class'),
        actions: [
          if (a != null)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.preClass.withAlpha(20), borderRadius: BorderRadius.circular(20)),
              child: const Text('Pre-Class', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.preClass)),
            ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : a == null
              ? const EmptyState(icon: Icons.error_outline, title: 'Không tìm thấy', message: '')
              : Column(children: [
                  Expanded(child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (a.deadline != null)
                        _InfoChip(Icons.calendar_today_rounded, 'Hạn nộp: ${_fmt(a.deadline!)}', AppColors.warning),
                      const SizedBox(height: 12),
                      if ((a.description ?? '').isNotEmpty) ...[
                        const Text('Mô tả hoạt động', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                          child: Text(a.description!, style: const TextStyle(fontSize: 14, height: 1.8, color: AppColors.textSecondary)),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text('Tài liệu học tập', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _MaterialsBlock(learningPathId: a.learningPathId),
                      const SizedBox(height: 16),
                      const Text('Trạng thái nộp bài', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _SubmissionStatusCard(status: a.submissionStatus),
                      if (raw != null && raw['reviewSessionId'] != null) ...[
                        const SizedBox(height: 16),
                        const Text('Đánh giá chéo (Peer Review)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _PeerReviewPanel(
                          sessionId: raw['reviewSessionId'] as int,
                          sessionTitle: raw['reviewSessionTitle'] as String? ?? 'Phiên Đánh giá chéo',
                          isOpen: raw['isReviewSessionOpen'] as bool? ?? false,
                        ),
                      ],
                    ]),
                  )),
                  _SubmitBar(
                    activityId: widget.activityId,
                    status: a.submissionStatus,
                    onTap: () async {
                      await Navigator.pushNamed(context, '/submit-evidence', arguments: {
                        'activityId': widget.activityId,
                        'activityTitle': a.title,
                        'label': a.type == 'PostClass' ? 'Reflection' : 'Bằng chứng',
                      });
                      if (context.mounted) {
                        context.read<ActivityViewModel>().loadDetail(widget.activityId);
                      }
                    },
                  ),
                ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L10/L11 — In-Class Activity Detail (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class InClassActivityScreen extends StatefulWidget {
  final int activityId;
  const InClassActivityScreen({super.key, required this.activityId});
  @override
  State<InClassActivityScreen> createState() => _InClassActivityState();
}

class _InClassActivityState extends State<InClassActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityViewModel>().loadDetail(widget.activityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm  = context.watch<ActivityViewModel>();
    final raw = vm.detail;
    final a   = raw != null ? _A(raw) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(a?.title ?? 'In-Class'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.inClass.withAlpha(20), borderRadius: BorderRadius.circular(20)),
            child: const Text('In-Class', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inClass)),
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : a == null
              ? const EmptyState(icon: Icons.error_outline, title: 'Không tìm thấy', message: '')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.inClass, Color(0xFF4F46E5)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(children: [
                        const Icon(Icons.class_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Hoạt động In-Class', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(a.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                        ])),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    if ((a.description ?? '').isNotEmpty) ...[
                      const Text('Nội dung buổi học', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: Text(a.description!, style: const TextStyle(fontSize: 14, height: 1.8, color: AppColors.textSecondary)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text('Tài liệu buổi học', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _MaterialsBlock(learningPathId: a.learningPathId),
                    const SizedBox(height: 16),
                    const Text('Trạng thái điểm danh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _SubmissionStatusCard(status: a.submissionStatus),
                    if (raw != null && raw['reviewSessionId'] != null) ...[
                      const SizedBox(height: 16),
                      const Text('Đánh giá chéo (Peer Review)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _PeerReviewPanel(
                        sessionId: raw['reviewSessionId'] as int,
                        sessionTitle: raw['reviewSessionTitle'] as String? ?? 'Phiên Đánh giá chéo',
                        isOpen: raw['isReviewSessionOpen'] as bool? ?? false,
                      ),
                    ],
                    const SizedBox(height: 80),
                  ]),
                ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L12/L13 — Post-Class Activity & Evidence Submit (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class PostClassActivityScreen extends StatefulWidget {
  final int activityId;
  const PostClassActivityScreen({super.key, required this.activityId});
  @override
  State<PostClassActivityScreen> createState() => _PostClassActivityState();
}

class _PostClassActivityState extends State<PostClassActivityScreen> {
  final _noteCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityViewModel>().loadDetail(widget.activityId);
    });
  }

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  Future<void> _submitEvidence() async {
    final note = _noteCtrl.text.trim();
    setState(() => _submitting = true);
    final vm  = context.read<EvidenceViewModel>();
    final err = await vm.submitEvidence(
      activityId: widget.activityId,
      note: note.isEmpty ? null : note,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (err == null) {
      AppSnackBar.show(context, '✅ Nộp evidence thành công!', type: SnackType.success);
      context.read<ActivityViewModel>().loadDetail(widget.activityId);
      _noteCtrl.clear();
    } else {
      AppSnackBar.show(context, err, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm  = context.watch<ActivityViewModel>();
    final raw = vm.detail;
    final a   = raw != null ? _A(raw) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(a?.title ?? 'Post-Class'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.postClass.withAlpha(20), borderRadius: BorderRadius.circular(20)),
            child: const Text('Post-Class', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.postClass)),
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : a == null
              ? const EmptyState(icon: Icons.error_outline, title: 'Không tìm thấy', message: '')
              : Column(children: [
                  Expanded(child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (a.deadline != null)
                        _InfoChip(Icons.timer_rounded, 'Hạn nộp: ${_fmt(a.deadline!)}', AppColors.postClass),
                      const SizedBox(height: 12),
                      if ((a.description ?? '').isNotEmpty) ...[
                        const Text('Yêu cầu bài tập', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                          child: Text(a.description!, style: const TextStyle(fontSize: 14, height: 1.8, color: AppColors.textSecondary)),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text('Tài liệu tham khảo', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _MaterialsBlock(learningPathId: a.learningPathId),
                      const SizedBox(height: 16),
                      _SubmissionStatusCard(status: a.submissionStatus),
                      if (raw != null && raw['reviewSessionId'] != null) ...[
                        const SizedBox(height: 16),
                        const Text('Đánh giá chéo (Peer Review)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _PeerReviewPanel(
                          sessionId: raw['reviewSessionId'] as int,
                          sessionTitle: raw['reviewSessionTitle'] as String? ?? 'Phiên Đánh giá chéo',
                          isOpen: raw['isReviewSessionOpen'] as bool? ?? false,
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (a.submissionStatus != 'Approved') ...[
                        const Text('Nộp Evidence', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.postClass.withAlpha(60)),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            TextField(
                              controller: _noteCtrl,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Mô tả công việc bạn đã làm, những gì học được...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('* Bạn có thể mô tả chi tiết trong phần ghi chú.', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
                          ]),
                        ),
                      ],
                    ]),
                  )),
                  if (a.submissionStatus != 'Approved')
                    _SubmitBar(activityId: widget.activityId, status: a.submissionStatus, onTap: _submitEvidence, isLoading: _submitting),
                ]),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
String _fmt(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withAlpha(60))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}

class _MaterialsBlock extends StatelessWidget {
  final int learningPathId;
  const _MaterialsBlock({required this.learningPathId});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.folder_open_rounded, color: AppColors.primary, size: 20),
        ),
        title: const Text('Tài liệu đính kèm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: const Text('Xem tài liệu, video bài học', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        onTap: () => Navigator.pushNamed(context, '/paths/$learningPathId/materials'),
      ),
    ),
  );
}

class _SubmissionStatusCard extends StatelessWidget {
  final String? status;
  const _SubmissionStatusCard({this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null || status == 'NotSubmitted') {
      return _card(Icons.pending_outlined, 'Chưa nộp', 'Hoạt động chưa được nộp evidence.', AppColors.textHint);
    }
    if (status == 'Pending') {
      return _card(Icons.hourglass_top_rounded, 'Đang chờ duyệt', 'Giảng viên sẽ xem xét evidence của bạn.', AppColors.warning);
    }
    if (status == 'Approved') {
      return _card(Icons.check_circle_rounded, 'Đã được duyệt ✅', 'Evidence đã được giảng viên xác nhận.', AppColors.success);
    }
    if (status == 'Rejected') {
      return _card(Icons.cancel_rounded, 'Bị từ chối', 'Vui lòng xem nhận xét và nộp lại.', AppColors.error);
    }
    return const SizedBox.shrink();
  }

  Widget _card(IconData icon, String title, String msg, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withAlpha(60))),
    child: Row(children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(msg, style: TextStyle(fontSize: 12, color: color.withAlpha(180))),
      ])),
    ]),
  );
}

class _SubmitBar extends StatelessWidget {
  final int activityId;
  final String? status;
  final VoidCallback? onTap;
  final bool isLoading;
  const _SubmitBar({required this.activityId, this.status, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final isResubmit = status == 'Rejected';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: AppButton(
          label: isResubmit ? 'NỘP LẠI EVIDENCE' : 'NỘP EVIDENCE',
          onPressed: onTap ?? () {},
          isLoading: isLoading,
          icon: isResubmit ? Icons.refresh_rounded : Icons.upload_file_rounded,
        ),
      ),
    );
  }
}

class _PeerReviewPanel extends StatelessWidget {
  final int sessionId;
  final String sessionTitle;
  final bool isOpen;

  const _PeerReviewPanel({
    required this.sessionId,
    required this.sessionTitle,
    required this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOpen ? AppColors.success.withAlpha(80) : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOpen ? AppColors.successLight : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.rate_review_rounded,
                  color: isOpen ? AppColors.success : AppColors.textHint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sessionTitle,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOpen ? '● Đang mở nhận đánh giá' : '○ Đã đóng / Chưa mở',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOpen ? AppColors.success : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/review-sessions/$sessionId');
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('THỰC HIỆN ĐÁNH GIÁ CHÉO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
