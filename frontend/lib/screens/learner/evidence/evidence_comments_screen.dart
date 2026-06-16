import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

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
