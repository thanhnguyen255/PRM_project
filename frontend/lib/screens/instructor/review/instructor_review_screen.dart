import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I15/I16 — Review Session Management (Instructor)
// ════════════════════════════════════════════════════════════════════════════════
class InstructorReviewScreen extends StatefulWidget {
  final int classId;
  const InstructorReviewScreen({super.key, required this.classId});
  @override
  State<InstructorReviewScreen> createState() => _InstructorReviewScreenState();
}

class _InstructorReviewScreenState extends State<InstructorReviewScreen> {
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
      appBar: AppBar(
        title: const Text('Quản lý Peer Review'),
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.sessions.isEmpty
              ? const EmptyState(
                  icon: Icons.rate_review_outlined,
                  title: 'Chưa có phiên Review',
                  message: 'Hãy tạo phiên Peer Review từ các hoạt động lớp học để bắt đầu.',
                )
              : RefreshIndicator(
                  onRefresh: () => vm.loadSessions(widget.classId),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.sessions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _ReviewSessionCard(
                      session: vm.sessions[i],
                      onMonitor: () => Navigator.pushNamed(context, '/instructor/review/${vm.sessions[i].id}/monitor'),
                    ),
                  ),
                ),
    );
  }
}

class _ReviewSessionCard extends StatelessWidget {
  final dynamic session;
  final VoidCallback onMonitor;
  const _ReviewSessionCard({required this.session, required this.onMonitor});

  String _fmtD(DateTime dt) => '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final bool isOpen = session.isOpen as bool;
    return InkWell(
      onTap: onMonitor,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isOpen ? AppColors.success.withAlpha(80) : AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              leading: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isOpen ? AppColors.successLight : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.rate_review_rounded,
                  color: isOpen ? AppColors.success : AppColors.textHint,
                  size: 24,
                ),
              ),
              title: Text(session.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 4),
                Text(
                  '${_fmtD(session.startDate)} → ${_fmtD(session.endDate)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ]),
              trailing: StatusBadge(status: isOpen ? BadgeStatus.open : BadgeStatus.closed),
            ),
          ),
          // Stats + action
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(children: [
              _Stat('${session.totalPairs ?? 0}', 'Cặp review', AppColors.secondary),
              const SizedBox(width: 12),
              _Stat('${session.completedPairs ?? 0}', 'Hoàn thành', AppColors.success),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onMonitor,
                icon: const Icon(Icons.monitor_rounded, size: 16),
                label: const Text('Theo dõi', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _Stat(String value, String label, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
  ]);
}

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I16 — Review Monitor Screen (Instructor)
// ════════════════════════════════════════════════════════════════════════════════
class ReviewMonitorScreen extends StatefulWidget {
  final int sessionId;
  const ReviewMonitorScreen({super.key, required this.sessionId});
  @override
  State<ReviewMonitorScreen> createState() => _ReviewMonitorScreenState();
}

class _ReviewMonitorScreenState extends State<ReviewMonitorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewViewModel>().loadSessionDetail(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<ReviewViewModel>();
    final sess = vm.sessionDetail; // Map<String,dynamic>?

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(sess?['title'] as String? ?? 'Theo dõi Review')),
      body: vm.isLoading
          ? const LoadingWidget()
          : sess == null
              ? const EmptyState(icon: Icons.error_outline_rounded, title: 'Không tìm thấy', message: '')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Summary stats
                    Row(children: [
                      Expanded(child: StatCard(value: '${sess['totalPairs'] ?? 0}', label: 'Tổng\ncặp', icon: Icons.people_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(value: '${sess['completedPairs'] ?? 0}', label: 'Hoàn\nthành', color: AppColors.success, icon: Icons.check_circle_rounded)),
                      const SizedBox(width: 10),
                      Expanded(child: StatCard(value: '${(sess['totalPairs'] as int? ?? 0) - (sess['completedPairs'] as int? ?? 0)}', label: 'Chưa\nxong', color: AppColors.warning, icon: Icons.pending_rounded)),
                    ]),
                    const SizedBox(height: 20),

                    // Overall progress
                    const Text('Tiến độ tổng thể', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Column(children: [
                        Row(children: [
                          const Text('Hoàn thành:', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          const Spacer(),
                          Builder(builder: (ctx) {
                            final total     = sess['totalPairs'] as int? ?? 0;
                            final completed = sess['completedPairs'] as int? ?? 0;
                            final pct       = total == 0 ? 0 : (completed / total * 100).toInt();
                            return Text('$pct%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary));
                          }),
                        ]),
                        const SizedBox(height: 10),
                        Builder(builder: (ctx) {
                          final total     = sess['totalPairs'] as int? ?? 0;
                          final completed = sess['completedPairs'] as int? ?? 0;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : completed / total,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                              minHeight: 10,
                            ),
                          );
                        }),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // Review pairs list
                    const Text('Danh sách cặp review', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    if ((sess['pairs'] as List?)?.isEmpty ?? true)
                      const EmptyState(icon: Icons.groups_outlined, title: 'Chưa có cặp review', message: 'Hệ thống chưa phân công cặp.')
                    else
                      ...(sess['pairs'] as List).map((pair) {
                        final p = pair as Map<String, dynamic>;
                        final bool isCompleted = p['isCompleted'] as bool? ?? false;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          clipBehavior: Clip.antiAlias,
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: isCompleted ? AppColors.success.withAlpha(20) : AppColors.primaryLight,
                              child: Text(
                                (p['reviewerName'] as String? ?? '?').isNotEmpty ? (p['reviewerName'] as String)[0] : '?',
                                style: TextStyle(
                                  color: isCompleted ? AppColors.success : AppColors.primary, 
                                  fontWeight: FontWeight.w700
                                ),
                              ),
                            ),
                            title: Text(p['reviewerName'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Row(
                              children: [
                                Text('→ ${p['revieweeName'] as String? ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                                const SizedBox(width: 8),
                                if (isCompleted && p['rating'] != null)
                                  Row(
                                    children: List.generate(5, (idx) => Icon(
                                      idx < (p['rating'] as int) ? Icons.star_rounded : Icons.star_outline_rounded,
                                      size: 14,
                                      color: Colors.amber,
                                    )),
                                  ),
                              ],
                            ),
                            trailing: StatusBadge(status: isCompleted ? BadgeStatus.approved : BadgeStatus.pending),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    if (isCompleted) ...[
                                      const Text(
                                        'Nội dung đánh giá chéo:',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Text(
                                          p['content'] as String? ?? 'Không có nội dung nhận xét.',
                                          style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                                        ),
                                      ),
                                      if (p['submittedAt'] != null) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Thời gian nộp: ${_fmtDateStr(p['submittedAt'] as String)}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                                        ),
                                      ],
                                    ] else ...[
                                      const Row(
                                        children: [
                                          Icon(Icons.pending_actions_rounded, size: 16, color: AppColors.warning),
                                          SizedBox(width: 8),
                                          Text(
                                            'Chưa thực hiện đánh giá chéo.',
                                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ]),
                ),
    );
  }
}

String _fmtDateStr(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  } catch (_) {
    return iso;
  }
}
