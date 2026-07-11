import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I17/I18/I19 — Evidence List + Detail + Comment (Instructor)
// ════════════════════════════════════════════════════════════════════════════════

// SCR-I17 — Evidence List Tab (embedded in Dashboard)
class EvidenceListTab extends StatefulWidget {
  const EvidenceListTab({super.key});
  @override
  State<EvidenceListTab> createState() => _EvidenceListTabState();
}

class _EvidenceListTabState extends State<EvidenceListTab> {
  static const _filters = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvidenceViewModel>().loadEvidencesByClass(1); // replaced by real classId
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EvidenceViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Evidence cần duyệt'), automaticallyImplyLeading: false),
      body: Column(children: [
        const SizedBox(height: 12),
        FilterChipGroup(
          options: _filters,
          selected: vm.statusFilter,
          onSelected: (f) {
            vm.setStatusFilter(f);
            vm.loadEvidencesByClass(1);
          },
        ),
        const SizedBox(height: 12),
        Expanded(child: vm.isLoading
            ? const LoadingWidget()
            : vm.evidences.isEmpty
                ? const EmptyState(icon: Icons.task_outlined, title: 'Không có evidence', message: 'Không có evidence nào cần duyệt.')
                : RefreshIndicator(
                    onRefresh: () => vm.loadEvidencesByClass(1),
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: vm.evidences.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final e = vm.evidences[i];
                        return _EvidenceItem(evidence: e);
                      },
                    ),
                  ),
        ),
      ]),
    );
  }
}

class _EvidenceItem extends StatelessWidget {
  final dynamic evidence;
  const _EvidenceItem({required this.evidence});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/instructor/evidence/${evidence.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              evidence.learnerName.isNotEmpty ? evidence.learnerName[0] : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(evidence.learnerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(evidence.activityTitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              'Nộp: ${evidence.submittedAt.day.toString().padLeft(2, '0')}/${evidence.submittedAt.month.toString().padLeft(2, '0')} · ${evidence.submittedAt.hour.toString().padLeft(2, '0')}:${evidence.submittedAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ])),
          const SizedBox(width: 8),
          StatusBadge(status: StatusBadge.fromString(evidence.status)),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I18/I19 — Evidence Detail + Comment (Instructor)
// ════════════════════════════════════════════════════════════════════════════════
class EvidenceDetailScreen extends StatefulWidget {
  final int evidenceId;
  const EvidenceDetailScreen({super.key, required this.evidenceId});
  @override
  State<EvidenceDetailScreen> createState() => _EvidenceDetailScreenState();
}

class _EvidenceDetailScreenState extends State<EvidenceDetailScreen> {
  final _commentCtrl = TextEditingController();

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
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  Future<void> _approve() async {
    final confirmed = await ConfirmDialog.show(context, title: 'Xác nhận Approve', message: 'Bạn có chắc muốn Approve evidence này không?', confirmLabel: 'APPROVE');
    if (confirmed != true || !mounted) return;
    final vm  = context.read<EvidenceViewModel>();
    final err = await vm.approve(widget.evidenceId);
    if (!mounted) return;
    AppSnackBar.show(context, err ?? '✅ Đã Approve evidence.', type: err == null ? SnackType.success : SnackType.error);
  }

  Future<void> _reject() async {
    final confirmed = await ConfirmDialog.show(context, title: 'Xác nhận Reject', message: 'Bạn có chắc muốn Reject evidence này không?', confirmLabel: 'REJECT', isDanger: true);
    if (confirmed != true || !mounted) return;
    final vm  = context.read<EvidenceViewModel>();
    final err = await vm.reject(widget.evidenceId);
    if (!mounted) return;
    AppSnackBar.show(context, err ?? '❌ Đã Reject evidence.', type: err == null ? SnackType.success : SnackType.error);
  }

  Future<void> _sendComment() async {
    final txt = _commentCtrl.text.trim();
    if (txt.isEmpty) return;
    final vm  = context.read<EvidenceViewModel>();
    final err = await vm.addComment(widget.evidenceId, txt);
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
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Không tìm thấy', message: '')
              : Column(children: [
                  Expanded(child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Learner info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8)],
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(e.learnerName.isNotEmpty ? e.learnerName[0] : '?',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(e.learnerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(e.activityTitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ])),
                            StatusBadge(status: StatusBadge.fromString(e.status)),
                          ]),
                          const Divider(height: 20),
                          _InfoRow(Icons.calendar_today_rounded, 'Nộp lúc:', '${e.submittedAt.day.toString().padLeft(2,'0')}/${e.submittedAt.month.toString().padLeft(2,'0')}/${e.submittedAt.year} · ${e.submittedAt.hour.toString().padLeft(2,'0')}:${e.submittedAt.minute.toString().padLeft(2,'0')}'),
                          // Evidence attachment note
                          if ((e.note ?? '').isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text('Ghi chú của học viên:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
                              child: Text(e.note!, style: const TextStyle(fontSize: 14, height: 1.6)),
                            ),
                          ],
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // Action buttons (only if pending)
                      if (e.status == 'Pending') ...[
                        Row(children: [
                          Expanded(child: ElevatedButton.icon(
                            onPressed: _approve,
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('APPROVE', style: TextStyle(fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success, foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: ElevatedButton.icon(
                            onPressed: _reject,
                            icon: const Icon(Icons.cancel_rounded, size: 18),
                            label: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error, foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                          )),
                        ]),
                        const SizedBox(height: 16),
                      ],

                      // Comments section
                      const Text('Bình luận & Phản hồi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),

                      if (vm.comments.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textHint, size: 20),
                            SizedBox(width: 8),
                            Text('Chưa có bình luận nào', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                          ]),
                        )
                      else
                        ...vm.comments.map((c) => CommentTile(
                          authorName:   c.authorName,
                          authorAvatar: c.authorAvatar,
                          authorId:     c.authorId,
                          isInstructor: c.isInstructor,
                          content:      c.content,
                          createdAt:    c.createdAt,
                          currentUserId: context.watch<AuthViewModel>().userId ?? 1,
                        )),
                    ]),
                  )),

                  // Comment input bar
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 16),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: SafeArea(child: Row(children: [
                      Expanded(child: TextField(
                        controller: _commentCtrl,
                        decoration: InputDecoration(
                          hintText: 'Nhận xét hoặc phản hồi...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.border)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: AppColors.textHint),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
    const SizedBox(width: 6),
    Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
  ]);
}
