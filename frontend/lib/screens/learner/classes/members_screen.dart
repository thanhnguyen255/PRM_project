import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L10 - Members List
// ════════════════════════════════════════════════════════════════════════════════
class MembersScreen extends StatefulWidget {
  final int classId;
  const MembersScreen({super.key, required this.classId});
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassViewModel>().loadMembers(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClassViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Thành viên lớp (${vm.members.length} người)'),
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.members.isEmpty
              ? const EmptyState(icon: Icons.group_outlined, title: 'Chưa có thành viên', message: 'Lớp học chưa có học viên nào.')
              : ListView.separated(
                  itemCount: vm.members.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = vm.members[i];
                    return MemberListTile(
                      fullName: m.fullName,
                      email: m.email,
                      avatarUrl: m.avatarUrl,
                      userId: m.userId,
                    );
                  },
                ),
    );
  }
}
