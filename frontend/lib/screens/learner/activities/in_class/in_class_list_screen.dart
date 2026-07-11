import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_colors.dart';
import '../../../../viewmodels/extended_viewmodels.dart';
import '../../../../widgets/widgets.dart';

class InClassListScreen extends StatefulWidget {
  final int pathId;
  const InClassListScreen({super.key, required this.pathId});

  @override
  State<InClassListScreen> createState() => _InClassListScreenState();
}

class _InClassListScreenState extends State<InClassListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExtendedActivityViewModel>().loadActivities(widget.pathId, type: 'InClass');
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExtendedActivityViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Hoạt động In-Class')),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.activities.isEmpty
              ? const EmptyState(
                  icon: Icons.group_work_outlined,
                  title: 'Chưa có hoạt động',
                  message: 'Không có hoạt động In-Class nào cho lộ trình này.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = vm.activities[index];
                    return _ActivityCard(activity: activity);
                  },
                ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Map<String, dynamic> activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final title = activity['title'] as String? ?? 'Không có tiêu đề';
    final type = activity['type'] as String? ?? '';
    final id = activity['id'] as int;
    
    // Pink color for InClass as per spec
    const Color inClassColor = Color(0xFFEC4899);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/in-class-detail', arguments: id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: inClassColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group_work, color: inClassColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: inClassColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(fontSize: 12, color: inClassColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
