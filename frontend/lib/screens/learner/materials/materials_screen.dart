import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L15/L16 — Materials List (Learner) — links to VideoPlayer/DocViewer
// ════════════════════════════════════════════════════════════════════════════════
class MaterialsScreen extends StatefulWidget {
  final int pathId;
  const MaterialsScreen({super.key, required this.pathId});
  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  String _selectedType = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialViewModel>().loadMaterials(widget.pathId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MaterialViewModel>();
    
    final filteredMaterials = vm.materials.where((m) {
      if (_selectedType == 'Tất cả') return true;
      final type = m['type'] as String? ?? '';
      return type == _selectedType;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tài liệu học tập')),
      body: vm.isLoading
          ? const LoadingWidget()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (vm.materials.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  FilterChipGroup(
                    options: const ['Tất cả', 'Video', 'Document', 'Link'],
                    selected: _selectedType,
                    onSelected: (val) => setState(() => _selectedType = val),
                  ),
                ],
                Expanded(
                  child: filteredMaterials.isEmpty && vm.materials.isNotEmpty
                      ? const EmptyState(
                          icon: Icons.filter_alt_off_outlined,
                          title: 'Không có kết quả',
                          message: 'Không tìm thấy tài liệu phù hợp với bộ lọc.',
                        )
                      : filteredMaterials.isEmpty
                          ? const EmptyState(
                              icon: Icons.folder_open_outlined,
                              title: 'Chưa có tài liệu',
                              message: 'Giảng viên chưa thêm tài liệu cho hoạt động này.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredMaterials.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (_, i) {
                                final m = filteredMaterials[i];
                                return MaterialListTile(material: m);
                              },
                            ),
                ),
              ],
            ),
    );
  }
}



// ════════════════════════════════════════════════════════════════════════════════
// Instructor — Manage Materials (add video/doc links)
// ════════════════════════════════════════════════════════════════════════════════
class ManageMaterialsScreen extends StatefulWidget {
  final int pathId;
  const ManageMaterialsScreen({super.key, required this.pathId});
  @override
  State<ManageMaterialsScreen> createState() => _ManageMaterialsState();
}

class _ManageMaterialsState extends State<ManageMaterialsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialViewModel>().loadMaterials(widget.pathId);
    });
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final linkCtrl  = TextEditingController();
    String type = 'Video';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.add_circle_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Thêm tài liệu'),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            // Type selector
            Row(children: ['Video', 'Document'].map((t) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(t, style: TextStyle(fontSize: 12, color: type == t ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                selected: type == t,
                selectedColor: type == 'Video' ? AppColors.secondary : AppColors.primary,
                onSelected: (_) => setS(() => type = t),
              ),
            )).toList()),
            const SizedBox(height: 12),
            TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Tiêu đề *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 12),
            TextField(controller: linkCtrl, decoration: InputDecoration(labelText: 'URL *', hintText: 'https://...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty || linkCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final vm  = context.read<MaterialViewModel>();
                final err = await vm.createMaterial(
                  learningPathId: widget.pathId,
                  title: titleCtrl.text.trim(),
                  type: type,
                  linkUrl: linkCtrl.text.trim(),
                );
                if (!context.mounted) return;
                if (err == null) {
                  AppSnackBar.show(context, 'Thêm tài liệu thành công!', type: SnackType.success);
                } else {
                  AppSnackBar.show(context, err, type: SnackType.error);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MaterialViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản lý tài liệu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.materials.isEmpty
              ? EmptyState(
                  icon: Icons.folder_outlined,
                  title: 'Chưa có tài liệu',
                  message: 'Thêm video hoặc tài liệu cho hoạt động này.',
                  actionLabel: 'Thêm tài liệu',
                  onAction: _showAddDialog,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.materials.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final m = vm.materials[i];
                    return Dismissible(
                      key: Key('mat_${m['id']}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                      ),
                      confirmDismiss: (_) => ConfirmDialog.show(context, title: 'Xoá tài liệu', message: 'Xoá "${m['title']}"?', confirmLabel: 'Xoá', isDanger: true),
                      onDismissed: (_) async {
                        await context.read<MaterialViewModel>().deleteMaterial(m['id'] as int, widget.pathId);
                      },
                      child: MaterialListTile(material: m),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Thêm tài liệu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
