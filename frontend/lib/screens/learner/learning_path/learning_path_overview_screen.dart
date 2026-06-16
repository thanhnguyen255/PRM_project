import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L11 — Learning Path Overview (list of weeks for a class)
// ════════════════════════════════════════════════════════════════════════════════
class LearningPathScreen extends StatefulWidget {
  final int classId;
  const LearningPathScreen({super.key, required this.classId});
  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningPathViewModel>().loadPaths(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LearningPathViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Lộ trình học')),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.paths.isEmpty
              ? const EmptyState(icon: Icons.route_rounded, title: 'Chưa có lộ trình', message: 'Giảng viên chưa tạo lộ trình học.')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.paths.length,
                  itemBuilder: (_, i) {
                    final p      = vm.paths[i];
                    final isLast = i == vm.paths.length - 1;
                    return _WeekStep(path: p, isLast: isLast);
                  },
                ),
    );
  }
}

class _WeekStep extends StatelessWidget {
  final dynamic path;
  final bool isLast;
  const _WeekStep({required this.path, required this.isLast});

  Color get _stateColor => switch (path.state as String) {
    'completed'  => AppColors.success,
    'inProgress' => AppColors.primary,
    _            => AppColors.textHint,
  };

  IconData get _stateIcon => switch (path.state as String) {
    'completed'  => Icons.check_circle_rounded,
    'inProgress' => Icons.radio_button_checked_rounded,
    _            => Icons.lock_rounded,
  };

  @override
  Widget build(BuildContext context) => Column(children: [
    InkWell(
      onTap: path.state != 'locked'
          ? () => Navigator.pushNamed(context, '/learning-paths/${path.id}')
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _stateColor.withAlpha(path.state == 'locked' ? 51 : 128),
            width: path.state == 'inProgress' ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Icon(_stateIcon, color: _stateColor, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(path.title as String, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600,
              color: path.state == 'locked' ? AppColors.textHint : AppColors.textPrimary,
            )),
            const SizedBox(height: 4),
            Text(
              '${path.completedActivities}/${path.totalActivities} hoạt động',
              style: TextStyle(fontSize: 13, color: _stateColor),
            ),
          ])),
          if (path.state != 'locked')
            Icon(Icons.chevron_right_rounded, color: _stateColor),
        ]),
      ),
    ),
    if (!isLast)
      Container(width: 2, height: 24, color: AppColors.border),
  ]);
}
