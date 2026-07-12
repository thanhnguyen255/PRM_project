import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';
import '../../../models/models.dart';

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
      context.read<LearningPathViewModel>().loadPathDetail(widget.pathId);
    });
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  List<ActivityModel> _parseActivities(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map((item) => ActivityModel.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LearningPathViewModel>();
    final title = vm.detail?['title'] as String? ?? 'Lộ trình tuần';
    
    final preClass = _parseActivities(vm.detail?['preClassActivities']);
    final inClass = _parseActivities(vm.detail?['inClassActivities']);
    final postClass = _parseActivities(vm.detail?['postClassActivities']);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_copy_rounded),
            tooltip: 'Tài liệu học tập',
            onPressed: () => Navigator.pushNamed(context, '/paths/${widget.pathId}/materials'),
          ),
        ],
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
                  activities: preClass,
                  type: 'PreClass',
                  emptyMsg: 'Chưa có hoạt động Pre-Class',
                ),
                _ActivityTypeList(
                  activities: inClass,
                  type: 'InClass',
                  emptyMsg: 'Chưa có hoạt động In-Class',
                ),
                _ActivityTypeList(
                  activities: postClass,
                  type: 'PostClass',
                  emptyMsg: 'Chưa có hoạt động Post-Class',
                ),
              ],
            ),
    );
  }
}

class _ActivityTypeList extends StatelessWidget {
  final List<ActivityModel> activities;
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
