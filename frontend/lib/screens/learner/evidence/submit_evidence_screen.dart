import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
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
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'mp4'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      AppSnackBar.show(context, 'Lỗi chọn file: $e', type: SnackType.error);
    }
  }

  Future<void> _submit() async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty && _selectedFile == null) {
      AppSnackBar.show(context, 'Vui lòng nhập ghi chú hoặc chọn file.', type: SnackType.warning);
      return;
    }
    final vm = context.read<EvidenceViewModel>();
    final err = await vm.submitEvidence(
      activityId: widget.activityId,
      note: note.isNotEmpty ? note : null,
      filePath: _selectedFile?.path,
      fileName: _selectedFile?.name,
    );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(51)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.task_alt_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.activityTitle,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            AppTextField(
              label: 'Ghi chú / Mô tả',
              hint: 'Nhập mô tả về những gì bạn đã làm...',
              controller: _noteCtrl,
              maxLines: 6,
            ),
            const SizedBox(height: 16),

            // File Picker Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedFile != null ? AppColors.success : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedFile != null ? Icons.check_circle_rounded : Icons.attach_file_rounded,
                    color: _selectedFile != null ? AppColors.success : AppColors.textHint,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  if (_selectedFile != null) ...[
                    Text(
                      _selectedFile!.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(_selectedFile!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.change_circle_outlined, size: 16),
                          label: const Text('Thay đổi'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _selectedFile = null),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                          label: const Text('Xóa', style: TextStyle(color: AppColors.error)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text('Chọn file đính kèm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    const Text('JPG, PNG, PDF, MP4 · Tối đa 50MB', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'CHỌN FILE',
                      onPressed: _pickFile,
                      variant: ButtonVariant.outline,
                      isFullWidth: false,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            AppButton(
              label: 'NỘP BẰNG CHỨNG',
              onPressed: _submit,
              isLoading: vm.isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
