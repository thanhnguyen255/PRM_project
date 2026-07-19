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
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
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
      context.read<ReviewViewModel>().loadReviewDetail(widget.sessionId);
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
              minimumSize: const Size(0, 36),
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
            Flexible(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.reviewerName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                Row(children: List.generate(5, (i) => Icon(i < f.rating ? Icons.star_rounded : Icons.star_outline_rounded, size: 14, color: AppColors.warning))),
              ]),
            ),
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

class _SubmitFeedbackState extends State<SubmitFeedbackScreen> with SingleTickerProviderStateMixin {
  final _contentCtrl = TextEditingController();
  int _rating = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() { 
    _contentCtrl.dispose(); 
    _animCtrl.dispose();
    super.dispose(); 
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn mức đánh giá sao.'), backgroundColor: AppColors.error));
      return;
    }
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập nội dung nhận xét.'), backgroundColor: AppColors.error));
      return;
    }
    
    final vm  = context.read<ReviewViewModel>();
    final err = await vm.submitFeedback(assignmentId: widget.assignmentId, content: content, rating: _rating);
    if (!mounted) return;
    
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi feedback thành công!'), backgroundColor: AppColors.success));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $err'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Review: ${widget.revieweeName}'),
        elevation: 0,
        backgroundColor: AppColors.background,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.background, AppColors.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Reviewer Info Card
            _buildRevieweeCard(),
            const SizedBox(height: 28),

            // Evidence Preview
            const Text('Bằng chứng học tập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            _buildEvidenceCard(),
            const SizedBox(height: 32),

            // Star rating
            const Text('Đánh giá của bạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            _buildStarRating(),
            const SizedBox(height: 28),

            // Content
            const Text('Nhận xét chi tiết *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Nhận xét điểm mạnh, điểm cần cải thiện, gợi ý...',
                hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border.withOpacity(0.5))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: vm.isSaving ? null : _submit,
                icon: vm.isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
                label: Text(vm.isSaving ? 'ĐANG GỬI...' : 'GỬI FEEDBACK', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildRevieweeCard() {
    return Center(
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.surface,
            child: Text(
              widget.revieweeName.isNotEmpty ? widget.revieweeName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(widget.revieweeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: const Text('Đang review bài tập', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _buildEvidenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bao_cao_hoat_dong_${widget.revieweeName.replaceAll(' ', '_')}.pdf', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            const Text('Kích thước: 2.4 MB  •  2 ngày trước', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          ])),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Ghi chú của học viên:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            SizedBox(height: 6),
            Text(
              'Đây là báo cáo hoạt động nhóm của chúng em. Chúng em đã nghiên cứu tài liệu pre-class và thực hiện thảo luận. Mong nhận được ý kiến đóng góp từ bạn!',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đang mở tài liệu báo cáo của ${widget.revieweeName}...')));
            },
            icon: const Icon(Icons.remove_red_eye_rounded, size: 18),
            label: const Text('XEM TÀI LIỆU ĐÍNH KÈM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildStarRating() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => GestureDetector(
        onTap: () => setState(() => _rating = i + 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < _rating ? AppColors.warning : AppColors.border,
            size: i < _rating ? 48 : 42,
            shadows: i < _rating ? [BoxShadow(color: AppColors.warning.withOpacity(0.4), blurRadius: 10)] : null,
          ),
        ),
      ))),
      const SizedBox(height: 12),
      Text(_ratingLabel(), style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _rating > 0 ? AppColors.warning : AppColors.textHint)),
    ]);
  }

  String _ratingLabel() {
    switch (_rating) {
      case 1: return 'Rất tệ';
      case 2: return 'Cần cải thiện nhiều';
      case 3: return 'Đạt yêu cầu';
      case 4: return 'Khá tốt';
      case 5: return 'Tuyệt vời / Xuất sắc';
      default: return 'Chưa chọn';
    }
  }
}
