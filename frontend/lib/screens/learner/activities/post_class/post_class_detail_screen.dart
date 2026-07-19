import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_colors.dart';
import '../../../../viewmodels/extended_viewmodels.dart';
import '../../../../widgets/widgets.dart';

class PostClassDetailScreen extends StatefulWidget {
  final int activityId;
  const PostClassDetailScreen({super.key, required this.activityId});

  @override
  State<PostClassDetailScreen> createState() => _PostClassDetailScreenState();
}

class _PostClassDetailScreenState extends State<PostClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExtendedActivityViewModel>().loadActivityDetail(widget.activityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExtendedActivityViewModel>();
    final activity = vm.activityDetail;
    const Color postClassColor = Color(0xFFF97316);

    if (activity != null) {
      final submission = activity['submission'] as Map<String, dynamic>?;
      final submissionStatus = submission?['status'] as String? ?? 'Pending';
      final commentCount = submission?['commentCount'] as int? ?? 0;

      Color badgeColor;
      Color badgeTextColor;
      String badgeText;

      if (submissionStatus == 'Approved') {
        badgeColor = const Color(0xFFD1FAE5);
        badgeTextColor = const Color(0xFF065F46);
        badgeText = 'Approved ✓';
      } else if (submissionStatus == 'Rejected') {
        badgeColor = const Color(0xFFFEE2E2);
        badgeTextColor = const Color(0xFF991B1B);
        badgeText = 'Rejected ✗';
      } else {
        badgeColor = const Color(0xFFFEF3C7);
        badgeTextColor = const Color(0xFF92400E);
        badgeText = 'Pending';
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Chi tiết hoạt động Post-Class')),
        body: vm.isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String? ?? 'Không có tiêu đề',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: postClassColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            activity['type'] as String? ?? '',
                            style: const TextStyle(color: postClassColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (activity['deadline'] != null)
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.error),
                              const SizedBox(width: 4),
                              Text(
                                'Hạn chót: ${DateTime.parse(activity['deadline']).toLocal().toString().substring(0, 16)}',
                                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Trạng thái: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(color: badgeTextColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Mô tả / Hướng dẫn',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        activity['description'] as String? ?? 'Chưa có mô tả cho hoạt động này.',
                        style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: submissionStatus == 'Approved'
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/submit-post-class-reflection', arguments: widget.activityId);
                              },
                        icon: const Icon(Icons.upload_file),
                        label: Text(submissionStatus == 'Approved' ? 'Đã được phê duyệt' : 'Nộp Reflection / Bằng chứng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: postClassColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if (submission != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/evidences/${submission['id']}/comments');
                          },
                          icon: const Icon(Icons.comment),
                          label: Text('XEM BÌNH LUẬN ($commentCount)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: postClassColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: postClassColor),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Chi tiết hoạt động Post-Class')),
      body: vm.isLoading
          ? const LoadingWidget()
          : const EmptyState(icon: Icons.error_outline, title: 'Lỗi', message: 'Không tìm thấy hoạt động.'),
    );
  }
}
