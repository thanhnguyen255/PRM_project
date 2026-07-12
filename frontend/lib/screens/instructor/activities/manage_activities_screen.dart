import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-I10/I11 — Manage Activities for a Learning Path
// ════════════════════════════════════════════════════════════════════════════════
class ManageActivitiesScreen extends StatefulWidget {
  final int pathId;
  const ManageActivitiesScreen({super.key, required this.pathId});
  @override
  State<ManageActivitiesScreen> createState() => _ManageActivitiesScreenState();
}

class _ManageActivitiesScreenState extends State<ManageActivitiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityViewModel>().loadActivities(widget.pathId);
    });
  }

  Future<void> _selectDateTime(BuildContext context, TextEditingController controller, StateSetter setS) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      if (!context.mounted) return;
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        setS(() {
          controller.text = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
        });
      }
    }
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    final deadlineCtrl = TextEditingController();
    String type     = 'PreClass';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.add_circle_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Tạo hoạt động mới'),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              // Type selector chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['PreClass', 'InClass', 'PostClass'].map((t) => ChoiceChip(
                  label: Text(t, style: TextStyle(fontSize: 12, color: type == t ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  selected: type == t,
                  selectedColor: ActivityCard.typeColor(t),
                  onSelected: (_) => setS(() => type = t),
                )).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Mô tả hoạt động',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deadlineCtrl,
                readOnly: true,
                onTap: () => _selectDateTime(ctx, deadlineCtrl, setS),
                decoration: InputDecoration(
                  labelText: 'Hạn nộp (Deadline)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: const Icon(Icons.alarm_rounded, size: 18),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                
                String? deadlineIso;
                if (deadlineCtrl.text.isNotEmpty) {
                  try {
                    final parts = deadlineCtrl.text.split(' ');
                    final dateParts = parts[0].split('-');
                    final timeParts = parts[1].split(':');
                    final dt = DateTime(
                      int.parse(dateParts[0]),
                      int.parse(dateParts[1]),
                      int.parse(dateParts[2]),
                      int.parse(timeParts[0]),
                      int.parse(timeParts[1]),
                    );
                    deadlineIso = dt.toUtc().toIso8601String();
                  } catch (e) {
                    // Fallback
                  }
                }

                Navigator.pop(ctx);
                final vm  = context.read<InstructorManageViewModel>();
                final err = await vm.createActivity(
                  learningPathId: widget.pathId,
                  title: titleCtrl.text.trim(),
                  type: type,
                  description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                  deadline: deadlineIso,
                );
                if (!context.mounted) return;
                if (err == null) {
                  context.read<ActivityViewModel>().loadActivities(widget.pathId);
                  AppSnackBar.show(context, 'Tạo hoạt động thành công!', type: SnackType.success);
                } else {
                  AppSnackBar.show(context, err, type: SnackType.error);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
              child: const Text('Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ActivityViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý hoạt động'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.activities.isEmpty
              ? EmptyState(
                  icon: Icons.task_outlined,
                  title: 'Chưa có hoạt động',
                  message: 'Thêm hoạt động Pre/In/Post-Class cho tuần này.',
                  actionLabel: 'Thêm hoạt động',
                  onAction: _showAddDialog,
                )
              : Column(children: [
                  // Stats row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(children: [
                      _TypeCount(vm.activities.where((a) => a.type == 'PreClass').length,  'Pre-Class',  AppColors.preClass),
                      const SizedBox(width: 8),
                      _TypeCount(vm.activities.where((a) => a.type == 'InClass').length,   'In-Class',   AppColors.inClass),
                      const SizedBox(width: 8),
                      _TypeCount(vm.activities.where((a) => a.type == 'PostClass').length, 'Post-Class', AppColors.postClass),
                    ]),
                  ),
                  Expanded(child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: vm.activities.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final a = vm.activities[i];
                      return Dismissible(
                        key: Key('act_${a.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                            Text('Xoá', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                        confirmDismiss: (_) => ConfirmDialog.show(context, title: 'Xoá hoạt động', message: 'Xoá "${a.title}"?', confirmLabel: 'Xoá', isDanger: true),
                        onDismissed: (_) async {
                          await context.read<InstructorManageViewModel>().deleteActivity(a.id);
                          if (context.mounted) context.read<ActivityViewModel>().loadActivities(widget.pathId);
                        },
                        child: ActivityCard(
                          title: a.title,
                          type: a.type,
                          deadline: a.deadline,
                          submissionStatus: null,
                          onTap: () {},
                        ),
                      );
                    },
                  )),
                ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Thêm hoạt động', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

Widget _TypeCount(int count, String label, Color color) => Expanded(
  child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]),
  ),
);
