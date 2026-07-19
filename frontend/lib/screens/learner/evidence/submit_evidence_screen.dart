import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L19/22/25 — Submit Evidence
// ════════════════════════════════════════════════════════════════════════════════
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
