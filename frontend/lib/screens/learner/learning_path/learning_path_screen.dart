import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L05 — Learning Path Detail / Week View (Learner)
// ════════════════════════════════════════════════════════════════════════════════
class LearningPathDetailScreen extends StatefulWidget {
  final int pathId;
  const LearningPathDetailScreen({super.key, required this.pathId});
  @override
  State<LearningPathDetailScreen> createState() => _LearningPathDetailState();
}

class _LearningPathDetailState extends State<LearningPathDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityViewModel>().loadActivities(widget.pathId);
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  List _filterByType(List activities, String type) =>
      activities.where((a) => a.type == type).toList();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivityViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lộ trình tuần'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: [
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.preClass, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 4),
                const Text('Pre-Class'),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.inClass, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 4),
                const Text('In-Class'),
              ]),
            ),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.postClass, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 4),
                const Text('Post-Class'),
              ]),
            ),
          ],
        ),
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                _ActivityTypeList(
                  activities: _filterByType(vm.activities, 'PreClass'),
                  type: 'PreClass',
                  emptyMsg: 'Chưa có hoạt động Pre-Class',
                ),
                _ActivityTypeList(
                  activities: _filterByType(vm.activities, 'InClass'),
                  type: 'InClass',
                  emptyMsg: 'Chưa có hoạt động In-Class',
                ),
                _ActivityTypeList(
                  activities: _filterByType(vm.activities, 'PostClass'),
                  type: 'PostClass',
                  emptyMsg: 'Chưa có hoạt động Post-Class',
                ),
              ],
            ),
    );
  }
}

class _ActivityTypeList extends StatelessWidget {
  final List activities;
  final String type;
  final String emptyMsg;
  const _ActivityTypeList({required this.activities, required this.type, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return EmptyState(
        icon: Icons.task_outlined,
        title: emptyMsg,
        message: 'Giảng viên chưa thêm hoạt động này.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = activities[i];
        return ActivityCard(
          title: a.title,
          type: a.type,
          deadline: a.deadline,
          submissionStatus: a.submissionStatus,
          onTap: () => Navigator.pushNamed(context, '/activities/${a.id}'),
        );
      },
    );
  }
}
