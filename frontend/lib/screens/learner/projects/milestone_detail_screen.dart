import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../config/app_colors.dart';
import '../../../models/models.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

class MilestoneDetailScreen extends StatefulWidget {
  final int milestoneId;
  const MilestoneDetailScreen({super.key, required this.milestoneId});

  @override
  State<MilestoneDetailScreen> createState() => _MilestoneDetailScreenState();
}

class _MilestoneDetailScreenState extends State<MilestoneDetailScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _descCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  Uint8List? _fileBytes;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().loadMilestoneDetail(widget.milestoneId).then((_) {
        _animCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'zip', 'rar', 'jpg', 'png'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _fileBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
      });
    }
  }

  void _submit() async {
    final vm = context.read<ProjectViewModel>();
    final err = await vm.submitMilestone(
      milestoneId: widget.milestoneId,
      description: _descCtrl.text.trim(),
      fileBytes: _fileBytes,
      fileName: _fileName,
    );
    if (!mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nộp Milestone thành công!'),
        backgroundColor: AppColors.success,
      ));
      _descCtrl.clear();
      setState(() {
        _fileBytes = null;
        _fileName = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi: $err'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectViewModel>();
    final m = vm.milestone;
    final sub = vm.submission;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Milestone Detail'),
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
      body: vm.isLoading
          ? const LoadingWidget()
          : m == null
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Not Found', message: 'Could not load milestone details.')
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Header Card
                      _buildHeaderCard(m),
                      const SizedBox(height: 24),

                      // Description
                      if ((m.description ?? '').isNotEmpty) ...[
                        const Text('Description & Requirements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border.withOpacity(0.5)),
                          ),
                          child: Text(m.description!, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textSecondary)),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Submission Area
                      if (!m.isSubmitted) ...[
                        _buildSubmissionForm(vm)
                      ] else ...[
                        _buildSubmissionDetails(m, sub)
                      ],
                    ]),
                  ),
                ),
    );
  }

  Widget _buildHeaderCard(MilestoneModel m) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text('Step ${m.stepNumber}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          if (m.isSubmitted && m.isLate)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8)),
              child: const Text('Late Submission', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: m.isSubmitted ? AppColors.success : Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
              child: Text(m.isSubmitted ? 'Submitted' : 'Pending', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ]),
        const SizedBox(height: 16),
        Text(m.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        if (m.dueDate != null) ...[
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.access_time_rounded, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              'Due: ${m.dueDate!.day.toString().padLeft(2, '0')}/${m.dueDate!.month.toString().padLeft(2, '0')}/${m.dueDate!.year}',
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ]),
        ],
      ]),
    );
  }

  Widget _buildSubmissionForm(ProjectViewModel vm) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Submit Deliverables', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 16),
      AppTextField(
        label: 'Submission Note',
        hint: 'Describe what your team has accomplished...',
        controller: _descCtrl,
        maxLines: 4,
      ),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.attach_file_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_fileName ?? 'No file selected', style: TextStyle(color: _fileName != null ? AppColors.textPrimary : AppColors.textHint, fontSize: 14, fontWeight: _fileName != null ? FontWeight.w600 : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (_fileName == null) const Text('Max size: 20MB', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            ]),
          ),
          TextButton(
            onPressed: _pickFile,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Browse'),
          ),
        ]),
      ),
      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: vm.isSaving ? null : _submit,
          icon: vm.isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.cloud_upload_rounded),
          label: Text(vm.isSaving ? 'Submitting...' : 'SUBMIT MILESTONE', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
        ),
      ),
    ]);
  }

  Widget _buildSubmissionDetails(MilestoneModel m, MilestoneSubmissionModel? sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Submission Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: AppColors.success.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Successfully Submitted', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success)),
                if (m.submittedAt != null)
                  Text(
                    'At: ${m.submittedAt!.hour.toString().padLeft(2, '0')}:${m.submittedAt!.minute.toString().padLeft(2, '0')} on ${m.submittedAt!.day.toString().padLeft(2, '0')}/${m.submittedAt!.month.toString().padLeft(2, '0')}/${m.submittedAt!.year}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textHint),
                  ),
              ]),
            ),
          ]),
          if (sub != null && (sub.description ?? '').isNotEmpty) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
            const Text('Note:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textHint)),
            const SizedBox(height: 8),
            Text(sub.description!, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textPrimary)),
          ],
          if (sub != null && (sub.fileUrl ?? '').isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.description_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sub.fileUrl!.split('/').last,
                    style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
              ]),
            ),
          ]
        ]),
      ),
    ]);
  }
}
