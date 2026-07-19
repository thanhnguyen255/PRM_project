import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L17/L18/L19 — Peer Review Screens (Learner)
// ════════════════════════════════════════════════════════════════════════════════

// SCR-L17 — Review Sessions List
class ReviewSessionsScreen extends StatefulWidget {
  final int classId;
  const ReviewSessionsScreen({super.key, required this.classId});
  @override
  State<ReviewSessionsScreen> createState() => _ReviewSessionsState();
}

class _ReviewSessionsState extends State<ReviewSessionsScreen> {
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
              ? const EmptyState(icon: Icons.rate_review_outlined, title: 'Chưa có phiên Review', message: 'Giảng viên chưa tạo phiên Peer Review.')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final s = vm.sessions[i];
                    return _SessionCard(
                      session: s,
                      onTap: () => Navigator.pushNamed(context, '/review-sessions/${s.id}'),
                    );
                  },
                ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final dynamic session;
  final VoidCallback onTap;
  const _SessionCard({required this.session, required this.onTap});

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final bool isOpen = session.isOpen as bool;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isOpen ? AppColors.success.withAlpha(80) : AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8)],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: isOpen ? AppColors.successLight : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.rate_review_rounded, color: isOpen ? AppColors.success : AppColors.textHint, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(session.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(
              '${_fmt(session.startDate)} → ${_fmt(session.endDate)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
            const SizedBox(height: 6),
            StatusBadge(status: isOpen ? BadgeStatus.open : BadgeStatus.closed),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ]),
      ),
    );
  }
}

// SCR-L18 — Review Detail (assignments)
class ReviewDetailScreen extends StatefulWidget {
  final int sessionId;
  const ReviewDetailScreen({super.key, required this.sessionId});
  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().loadSessionDetail(widget.sessionId);
      context.read<ReviewViewModel>().loadAssignments(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<ReviewViewModel>();
    final sess = vm.sessionDetail;
    final assignments = vm.assignments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(sess?['title'] as String? ?? 'Peer Review')),
      body: vm.isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF7C3AED), AppColors.secondary]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    const Icon(Icons.rate_review_rounded, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Phiên Peer Review', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(sess?['title'] as String? ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        '${assignments.where((a) => (a['isCompleted'] as bool? ?? false)).length}/${assignments.length} đã hoàn thành',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ])),
                  ]),
                ),
                const SizedBox(height: 16),

                // My assignments
                const Text('Bài cần review', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),

                if (assignments.isEmpty)
                  const EmptyState(icon: Icons.assignment_outlined, title: 'Chưa có phân công', message: 'Hệ thống chưa phân công bài review cho bạn.')
                else
                  ...assignments.map((a) => _AssignmentCard(
                    assignment: a,
                    onReview: () => Navigator.pushNamed(context, '/submit-feedback', arguments: {
                      'assignmentId': a['id'],
                      'revieweeName': a['revieweeName'] ?? '',
                    }),
                  )),

                const SizedBox(height: 16),
                const Text('Feedback nhận được', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                _ReceivedFeedbackSection(sessionId: widget.sessionId),
              ]),
            ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onReview;
  const _AssignmentCard({required this.assignment, required this.onReview});

  @override
  Widget build(BuildContext context) {
    final bool done = assignment['isCompleted'] as bool? ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? AppColors.success.withAlpha(80) : AppColors.border),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.secondary.withAlpha(20),
          child: Text(
            (assignment['revieweeName'] as String? ?? '?').isNotEmpty ? (assignment['revieweeName'] as String)[0] : '?',
            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Review: ${assignment['revieweeName'] ?? ''}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(done ? '✅ Đã hoàn thành' : '⏳ Chưa review', style: TextStyle(fontSize: 12, color: done ? AppColors.success : AppColors.warning)),
        ])),
        if (!done)
          ElevatedButton(
            onPressed: onReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          )
        else
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
      ]),
    );
  }
}

class _ReceivedFeedbackSection extends StatefulWidget {
  final int sessionId;
  const _ReceivedFeedbackSection({required this.sessionId});
  @override
  State<_ReceivedFeedbackSection> createState() => _ReceivedFeedbackSectionState();
}

class _ReceivedFeedbackSectionState extends State<_ReceivedFeedbackSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().loadReceivedFeedback(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedbacks = context.watch<ReviewViewModel>().receivedFeedback;
    if (feedbacks.isEmpty) {
      return const EmptyState(icon: Icons.feedback_outlined, title: 'Chưa có feedback', message: 'Chưa có ai review bài của bạn.');
    }
    return Column(
      children: feedbacks.map((f) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Text(f.reviewerName.isNotEmpty ? f.reviewerName[0] : '?',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.reviewerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Row(children: List.generate(5, (i) => Icon(i < f.rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 14, color: AppColors.warning))),
            ]),
          ]),
          const SizedBox(height: 8),
          Text(f.content, style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary)),
        ]),
      )).toList(),
    );
  }
}

// SCR-L19 — Submit Feedback Screen
class SubmitFeedbackScreen extends StatefulWidget {
  final int assignmentId;
  final String revieweeName;
  const SubmitFeedbackScreen({super.key, required this.assignmentId, required this.revieweeName});
  @override
  State<SubmitFeedbackScreen> createState() => _SubmitFeedbackState();
}

class _SubmitFeedbackState extends State<SubmitFeedbackScreen> {
  final _contentCtrl = TextEditingController();
  int _rating = 3;

  @override
  void dispose() { _contentCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      AppSnackBar.show(context, 'Vui lòng nhập nội dung nhận xét.', type: SnackType.error);
      return;
    }
    final vm  = context.read<ReviewViewModel>();
    final err = await vm.submitFeedback(assignmentId: widget.assignmentId, content: content, rating: _rating);
    if (!mounted) return;
    if (err == null) {
      AppSnackBar.show(context, 'Đã gửi feedback!', type: SnackType.success);
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
      appBar: AppBar(title: Text('Review: ${widget.revieweeName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Reviewer info
          Center(
            child: Column(children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.secondary.withAlpha(20),
                child: Text(
                  widget.revieweeName.isNotEmpty ? widget.revieweeName[0] : '?',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 10),
              Text(widget.revieweeName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              const Text('Bạn đang review bài của người này', style: TextStyle(fontSize: 13, color: AppColors.textHint)),
            ]),
          ),
          const SizedBox(height: 28),

          // Star rating
          const Text('Đánh giá', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => GestureDetector(
            onTap: () => setState(() => _rating = i + 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: AppColors.warning,
                size: 40,
              ),
            ),
          ))),
          Center(child: Text(_ratingLabel(), style: const TextStyle(fontSize: 13, color: AppColors.textHint))),
          const SizedBox(height: 24),

          // Content
          const Text('Nhận xét chi tiết *', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _contentCtrl,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Nhận xét điểm mạnh, điểm cần cải thiện, gợi ý...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 24),

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

  String _ratingLabel() {
    switch (_rating) {
      case 1: return '⭐ Rất tệ';
      case 2: return '⭐⭐ Tệ';
      case 3: return '⭐⭐⭐ Trung bình';
      case 4: return '⭐⭐⭐⭐ Tốt';
      default: return '⭐⭐⭐⭐⭐ Xuất sắc';
    }
  }
}
