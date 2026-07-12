import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I21 — Student Progress Analytics (Instructor view of a single Learner)
// ════════════════════════════════════════════════════════════════════════════════
class StudentProgressAnalyticsScreen extends StatefulWidget {
  final int userId;
  final int classId;
  final String studentName;

  const StudentProgressAnalyticsScreen({
    super.key,
    required this.userId,
    required this.classId,
    required this.studentName,
  });

  @override
  State<StudentProgressAnalyticsScreen> createState() => _StudentProgressAnalyticsState();
}

class _StudentProgressAnalyticsState extends State<StudentProgressAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsViewModel>().loadStudentAnalytics(widget.userId, widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();
    final s = vm.studentAnalytics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tiến độ: ${widget.studentName}'),
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : s == null
              ? const EmptyState(
                  icon: Icons.person_off_rounded,
                  title: 'Không tìm thấy dữ liệu',
                  message: 'Không thể nạp thông tin tiến độ của học sinh này.',
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Header Card
                      _buildHeader(s),
                      const SizedBox(height: 20),

                      // Activities & Milestones Section
                      const Text('Hoạt động & Dự án', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      _buildActivityCard(s),
                      const SizedBox(height: 20),

                      // Peer Review Section
                      const Text('Peer Review', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      _buildPeerReviewCard(s),
                      const SizedBox(height: 20),

                      // Feedbacks List
                      const Text('Nhận xét từ bạn bè', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      _buildFeedbacksList(s),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> s) {
    final initial = (s['fullName'] as String? ?? '?').isNotEmpty ? (s['fullName'] as String)[0] : '?';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(
              initial.toUpperCase(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['fullName'] ?? widget.studentName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text('Vai trò: Học viên', style: TextStyle(fontSize: 13, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> s) {
    final subRate = (s['submissionRate'] as num? ?? 0.0).toDouble();
    final appRate = (s['approvalRate'] as num? ?? 0.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Submissions
          Row(
            children: [
              const Icon(Icons.outbox_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text('Tỷ lệ nộp bài', style: TextStyle(fontWeight: FontWeight.w600))),
              Text(
                '${s['submittedActivitiesCount']}/${s['totalActivities']}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: s['totalActivities'] == 0 ? 0 : (s['submittedActivitiesCount'] as int) / (s['totalActivities'] as int),
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('$subRate%', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          ),
          const Divider(height: 24),

          // Approved
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text('Tỷ lệ duyệt (Approved)', style: TextStyle(fontWeight: FontWeight.w600))),
              Text(
                '${s['approvedActivitiesCount']}/${s['totalActivities']}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: s['totalActivities'] == 0 ? 0 : (s['approvedActivitiesCount'] as int) / (s['totalActivities'] as int),
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('$appRate%', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          ),
          const Divider(height: 24),

          // Milestones
          Row(
            children: [
              const Icon(Icons.folder_special_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text('Milestones hoàn thành', style: TextStyle(fontWeight: FontWeight.w600))),
              Text(
                '${s['submittedMilestonesCount']}/${s['totalMilestones']}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeerReviewCard(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReviewStat(
                '${s['completedPeerReviewsCount']}/${s['peerReviewAssignmentsCount']}',
                'Đã làm review',
                AppColors.primary,
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              _buildReviewStat(
                '${s['receivedReviewsCount']}',
                'Nhận xét nhận',
                AppColors.secondary,
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              _buildReviewStat(
                '★ ${s['averageReceivedRating'] ?? 0.0}',
                'Điểm TB nhận',
                AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStat(String val, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildFeedbacksList(Map<String, dynamic> s) {
    final list = s['receivedFeedbacks'] as List<dynamic>? ?? [];
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Text('Học viên chưa nhận được đánh giá nào.', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
        ),
      );
    }

    return Column(
      children: list.map((f) {
        final reviewer = f['reviewerName'] as String? ?? 'Ẩn danh';
        final rating = f['rating'] as int? ?? 0;
        final content = f['content'] as String? ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        reviewer.isNotEmpty ? reviewer[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(reviewer, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 14,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
