import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_colors.dart';
import '../../../viewmodels/extended_viewmodels.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L15/L16 — Materials List (Learner) — links to VideoPlayer/DocViewer
// ════════════════════════════════════════════════════════════════════════════════
class MaterialsScreen extends StatefulWidget {
  final int activityId;
  const MaterialsScreen({super.key, required this.activityId});
  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialViewModel>().loadMaterials(widget.activityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MaterialViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tài liệu học tập')),
      body: vm.isLoading
          ? const LoadingWidget()
          : vm.materials.isEmpty
              ? const EmptyState(icon: Icons.folder_open_outlined, title: 'Chưa có tài liệu', message: 'Giảng viên chưa thêm tài liệu cho hoạt động này.')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.materials.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final m = vm.materials[i];
                    return _MaterialCard(material: m);
                  },
                ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final Map<String, dynamic> material;
  const _MaterialCard({required this.material});

  bool get _isVideo => (material['type'] as String? ?? '').toLowerCase().contains('video');

  @override
  Widget build(BuildContext context) {
    final color = _isVideo ? AppColors.secondary : AppColors.primary;
    final icon  = _isVideo ? Icons.play_circle_rounded : Icons.description_rounded;

    return InkWell(
      onTap: () {
        if (_isVideo) {
          Navigator.pushNamed(context, '/video-player', arguments: {
            'url': material['linkUrl'] ?? '',
            'title': material['title'] ?? '',
          });
        } else {
          Navigator.pushNamed(context, '/document-viewer', arguments: {
            'url': material['linkUrl'] ?? '',
            'title': material['title'] ?? '',
          });
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(60)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isVideo ? [const Color(0xFF7C3AED), AppColors.secondary] : [AppColors.primary, const Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(material['title'] as String? ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
              child: Text(_isVideo ? '▶ Video' : '📄 Tài liệu', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ),
          ])),
          const SizedBox(width: 8),
          Icon(_isVideo ? Icons.play_arrow_rounded : Icons.open_in_new_rounded, color: color, size: 22),
        ]),
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
                      child: _MaterialCard(material: m),
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
