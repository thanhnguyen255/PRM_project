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

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final y = picked.year;
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      controller.text = '$y-$m-$d';
    }
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl   = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.rate_review_rounded, color: AppColors.secondary),
          SizedBox(width: 8),
          Text('Tạo phiên Peer Review'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: titleCtrl,
            decoration: InputDecoration(labelText: 'Tiêu đề phiên *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: startCtrl,
            readOnly: true,
            onTap: () => _selectDate(ctx, startCtrl),
            decoration: InputDecoration(
              labelText: 'Ngày bắt đầu (YYYY-MM-DD)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: endCtrl,
            readOnly: true,
            onTap: () => _selectDate(ctx, endCtrl),
            decoration: InputDecoration(
              labelText: 'Ngày kết thúc (YYYY-MM-DD)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              suffixIcon: const Icon(Icons.event_rounded, size: 18),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final vm  = context.read<ReviewViewModel>();
              final err = await vm.createSession(
                classId:   widget.classId,
                title:     titleCtrl.text.trim(),
                startDate: startCtrl.text.trim(),
                endDate:   endCtrl.text.trim(),
              );
              if (!context.mounted) return;
              if (err == null) {
                AppSnackBar.show(context, 'Tạo phiên review thành công!', type: SnackType.success);
              } else {
                AppSnackBar.show(context, err, type: SnackType.error);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white, elevation: 0),
            child: const Text('Tạo phiên'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReviewViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý Peer Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            tooltip: 'Tạo phiên',
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.sessions.isEmpty
              ? EmptyState(
                  icon: Icons.rate_review_outlined,
                  title: 'Chưa có phiên Review',
                  message: 'Tạo phiên Peer Review để học viên đánh giá lẫn nhau.',
                  actionLabel: 'Tạo phiên đầu tiên',
                  onAction: _showCreateDialog,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tạo phiên', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
          ListTile(
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
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                (p['reviewerName'] as String? ?? '?').isNotEmpty ? (p['reviewerName'] as String)[0] : '?',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(p['reviewerName'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text('→ ${p['revieweeName'] as String? ?? ''}', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                            trailing: StatusBadge(status: (p['isCompleted'] as bool? ?? false) ? BadgeStatus.approved : BadgeStatus.pending),
                          ),
                        );
                      }),
                  ]),
                ),
    );
  }
}
