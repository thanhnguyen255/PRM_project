import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L17/20/23 — Activity List (by type: PreClass / InClass / PostClass)
// ════════════════════════════════════════════════════════════════════════════════
class ActivityListScreen extends StatefulWidget {
  final int pathId;
  final String type; // "PreClass" | "InClass" | "PostClass"

  const ActivityListScreen({super.key, required this.pathId, required this.type});
  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityViewModel>().loadActivities(widget.pathId, type: widget.type);
    });
  }

  String get _screenTitle => switch (widget.type) {
    'PreClass'  => 'Pre-Class Activities',
    'InClass'   => 'In-Class Activities',
    'PostClass' => 'Post-Class Activities',
    _           => 'Activities',
  };

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivityViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_screenTitle)),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.activities.isEmpty
              ? const EmptyState(icon: Icons.task_outlined, title: 'Chưa có hoạt động', message: 'Chưa có hoạt động nào được tạo.')
              : RefreshIndicator(
                  onRefresh: () => vm.loadActivities(widget.pathId, type: widget.type),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.activities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final a = vm.activities[i];
                      return ActivityCard(
                        title: a.title,
                        type: a.type,
                        deadline: a.deadline,
                        submissionStatus: a.submissionStatus,
                        onTap: () => Navigator.pushNamed(context, '/activities/${a.id}'),
                      );
                    },
                  ),
                ),
    );
  }
}
