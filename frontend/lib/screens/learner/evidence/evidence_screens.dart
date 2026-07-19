import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L14 — My Evidence List (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class MyEvidenceListScreen extends StatefulWidget {
  const MyEvidenceListScreen({super.key});
  @override
  State<MyEvidenceListScreen> createState() => _MyEvidenceListState();
}

class _MyEvidenceListState extends State<MyEvidenceListScreen> {
  static const _filters = ['Tất cả', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvidenceViewModel>().loadEvidencesByClass(0); // 0 = my evidences
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EvidenceViewModel>();
    final evidences = vm.evidences.where((e) {
      if (vm.statusFilter == 'All' || vm.statusFilter == 'Tất cả') return true;
      return e.status == vm.statusFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Evidence của tôi')),
      body: Column(children: [
        const SizedBox(height: 8),
        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            _StatPill(vm.evidences.where((e) => e.status == 'Pending').length, 'Pending', AppColors.warning),
            const SizedBox(width: 8),
            _StatPill(vm.evidences.where((e) => e.status == 'Approved').length, 'Approved', AppColors.success),
            const SizedBox(width: 8),
            _StatPill(vm.evidences.where((e) => e.status == 'Rejected').length, 'Rejected', AppColors.error),
          ]),
        ),
        const SizedBox(height: 10),

        // Filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _filters.map((f) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: vm.statusFilter == f ? Colors.white : AppColors.textSecondary)),
                selected: vm.statusFilter == f,
                selectedColor: AppColors.primary,
                onSelected: (_) {
                  vm.setStatusFilter(f);
                  vm.loadEvidencesByClass(0);
                },
              ),
            )).toList()),
          ),
        ),
        const SizedBox(height: 8),

        Expanded(child: vm.isLoading
            ? const LoadingWidget()
            : evidences.isEmpty
                ? const EmptyState(icon: Icons.task_outlined, title: 'Chưa có evidence', message: 'Hoàn thành các hoạt động để nộp evidence.')
                : RefreshIndicator(
                    onRefresh: () => vm.loadEvidencesByClass(0),
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: evidences.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final e = evidences[i];
                        return _EvidenceCard(
                          evidence: e,
                          onTap: () => Navigator.pushNamed(context, '/evidences/${e.id}'),
                        );
                      },
                    ),
                  ),
        ),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _StatPill(this.count, this.label, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withAlpha(40))),
      child: Column(children: [
        Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

class _EvidenceCard extends StatelessWidget {
  final dynamic evidence;
  final VoidCallback onTap;
  const _EvidenceCard({required this.evidence, required this.onTap});

  Color _statusColor(String s) {
    switch (s) {
      case 'Approved': return AppColors.success;
      case 'Rejected': return AppColors.error;
      default:         return AppColors.warning;
    }
  }
  IconData _statusIcon(String s) {
    switch (s) {
      case 'Approved': return Icons.check_circle_rounded;
      case 'Rejected': return Icons.cancel_rounded;
      default:         return Icons.hourglass_top_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(evidence.status);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(60)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(12)),
            child: Icon(_statusIcon(evidence.status), color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(evidence.activityTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(
              'Nộp ${_fmt(evidence.submittedAt)}',
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ])),
          const SizedBox(width: 8),
          StatusBadge(status: StatusBadge.fromString(evidence.status)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
        ]),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L — Evidence Detail (Learner view — read-only + comments)
// ════════════════════════════════════════════════════════════════════════════════
class LearnerEvidenceDetailScreen extends StatefulWidget {
  final int evidenceId;
  const LearnerEvidenceDetailScreen({super.key, required this.evidenceId});
  @override
  State<LearnerEvidenceDetailScreen> createState() => _LearnerEvidenceDetailState();
}

class _LearnerEvidenceDetailState extends State<LearnerEvidenceDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<EvidenceViewModel>().loadDetail(widget.evidenceId);
      await context.read<EvidenceViewModel>().loadComments(widget.evidenceId);
    });
  }

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  Future<void> _sendComment() async {
    final txt = _commentCtrl.text.trim();
    if (txt.isEmpty) return;
    final err = await context.read<EvidenceViewModel>().addComment(widget.evidenceId, txt);
    if (!mounted) return;
    if (err == null) {
      _commentCtrl.clear();
    } else {
      AppSnackBar.show(context, err, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EvidenceViewModel>();
    final e  = vm.detail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Chi tiết Evidence')),
      body: vm.isLoading
          ? const LoadingWidget()
          : e == null
              ? const EmptyState(icon: Icons.error_outline, title: 'Không tìm thấy', message: '')
              : Column(children: [
                  Expanded(child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Status card
                      _StatusBanner(status: e.status),
                      const SizedBox(height: 14),

                      // Activity info
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Hoạt động', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHint)),
                          const SizedBox(height: 4),
                          Text(e.activityTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const Divider(height: 20),
                          const Text('Ghi chú của bạn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textHint)),
                          const SizedBox(height: 6),
                          Text(
                            (e.note ?? '').isNotEmpty ? e.note! : 'Không có ghi chú.',
                            style: const TextStyle(fontSize: 14, height: 1.7, color: AppColors.textSecondary),
                          ),
                          const Divider(height: 20),
                          Row(children: [
                            const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textHint),
                            const SizedBox(width: 6),
                            Text(
                              'Nộp: ${e.submittedAt.day.toString().padLeft(2,'0')}/${e.submittedAt.month.toString().padLeft(2,'0')}/${e.submittedAt.year}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                            ),
                          ]),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // Comments
                      const Text('Nhận xét từ giảng viên', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      if (vm.comments.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Text('Chưa có nhận xét nào', style: TextStyle(color: AppColors.textHint, fontSize: 13))),
                        )
                      else
                        ...vm.comments.map((c) => CommentTile(
                          authorName:   c.authorName,
                          authorAvatar: c.authorAvatar,
                          authorId:     c.authorId,
                          isInstructor: c.isInstructor,
                          content:      c.content,
                          createdAt:    c.createdAt,
                          currentUserId: 1,
                        )),
                    ]),
                  )),

                  // Reply input
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 16),
                    decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
                    child: SafeArea(child: Row(children: [
                      Expanded(child: TextField(
                        controller: _commentCtrl,
                        decoration: InputDecoration(
                          hintText: 'Hỏi thêm giảng viên...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.border)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        maxLines: null,
                      )),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _sendComment,
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ])),
                  ),
                ]),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'Approved':
        return _banner(Icons.verified_rounded, 'Evidence đã được duyệt!', 'Giảng viên đã xác nhận hoàn thành.', AppColors.success);
      case 'Rejected':
        return _banner(Icons.cancel_rounded, 'Evidence bị từ chối', 'Xem nhận xét bên dưới và nộp lại.', AppColors.error);
      default:
        return _banner(Icons.hourglass_top_rounded, 'Đang chờ duyệt', 'Giảng viên sẽ xem xét sớm.', AppColors.warning);
    }
  }

  Widget _banner(IconData icon, String title, String msg, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withAlpha(60))),
    child: Row(children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(msg, style: TextStyle(fontSize: 12, color: color.withAlpha(200))),
      ])),
    ]),
  );
}
