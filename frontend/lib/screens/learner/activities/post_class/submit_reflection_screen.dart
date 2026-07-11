import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../config/app_colors.dart';
import '../../../../viewmodels/viewmodels.dart';
import '../../../../widgets/widgets.dart';

class SubmitReflectionScreen extends StatefulWidget {
  final int activityId;
  const SubmitReflectionScreen({super.key, required this.activityId});

  @override
  State<SubmitReflectionScreen> createState() => _SubmitReflectionScreenState();
}

class _SubmitReflectionScreenState extends State<SubmitReflectionScreen> {
  final _noteCtrl = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submit() async {
    final note = _noteCtrl.text.trim();
    if (note.isEmpty && _selectedFile == null) {
      AppSnackBar.show(context, 'Vui lòng nhập Reflection hoặc đính kèm file', type: SnackType.error);
      return;
    }

    final err = await context.read<EvidenceViewModel>().submitEvidence(
          activityId: widget.activityId,
          note: note.isNotEmpty ? note : null,
          filePath: _selectedFile?.path,
          fileName: _selectedFile?.name,
        );

    if (!mounted) return;
    if (err == null) {
      AppSnackBar.show(context, 'Nộp Reflection thành công', type: SnackType.success);
      Navigator.pop(context);
    } else {
      AppSnackBar.show(context, err, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<EvidenceViewModel>().isSubmitting;
    const Color postClassColor = Color(0xFFF97316);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Nộp Reflection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nội dung Reflection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung reflection của bạn...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: postClassColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đính kèm File (nếu có)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: postClassColor.withAlpha(50), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile == null ? Icons.upload_file : Icons.insert_drive_file,
                      size: 48,
                      color: postClassColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFile == null ? 'Bấm để chọn file tải lên' : _selectedFile!.name,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    if (_selectedFile != null)
                      Text(
                        '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
            if (_selectedFile != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                    });
                  },
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  label: const Text('Xóa file', style: TextStyle(color: AppColors.error)),
                ),
              ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: postClassColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Xác nhận nộp bài',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
