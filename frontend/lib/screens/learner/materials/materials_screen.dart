import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
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
        Navigator.pushNamed(context, '/material-detail', arguments: material['id']);
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
    String? filePath;
    String? fileName;
    bool isSaving = false;

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
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type selector
                Row(
                  children: ['Video', 'Document'].map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t, style: TextStyle(fontSize: 12, color: type == t ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      selected: type == t,
                      selectedColor: t == 'Video' ? AppColors.secondary : AppColors.primary,
                      onSelected: isSaving ? null : (_) => setS(() => type = t),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  enabled: !isSaving,
                  decoration: InputDecoration(labelText: 'Tiêu đề *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: linkCtrl,
                  enabled: !isSaving,
                  decoration: InputDecoration(labelText: 'URL (Liên kết)', hintText: 'https://...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text('— HOẶC —', style: TextStyle(fontSize: 11, color: AppColors.textHint, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: isSaving ? null : () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'mp3', 'wav', 'mp4', 'm4a', 'aac'],
                      );
                      if (result != null && result.files.single.path != null) {
                        setS(() {
                          filePath = result.files.single.path;
                          fileName = result.files.single.name;
                          if (titleCtrl.text.trim().isEmpty) {
                            final name = result.files.single.name;
                            final lastDot = name.lastIndexOf('.');
                            titleCtrl.text = lastDot > 0 ? name.substring(0, lastDot) : name;
                          }
                        });
                      }
                    } catch (e) {
                      debugPrint('File picker error: $e');
                    }
                  },
                  icon: const Icon(Icons.attach_file_rounded, size: 16),
                  label: const Text('Chọn tệp từ thiết bị', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                if (fileName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Đã chọn: $fileName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx), 
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isSaving 
                ? null 
                : () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    if (linkCtrl.text.trim().isEmpty && filePath == null) {
                      AppSnackBar.show(context, 'Vui lòng điền URL hoặc chọn một tệp.', type: SnackType.error);
                      return;
                    }
                    setS(() => isSaving = true);
                    final vm  = context.read<MaterialViewModel>();
                    final err = await vm.createMaterial(
                      learningPathId: widget.pathId,
                      title: titleCtrl.text.trim(),
                      type: type,
                      linkUrl: linkCtrl.text.trim().isEmpty ? null : linkCtrl.text.trim(),
                      filePath: filePath,
                    );
                    if (!context.mounted) return;
                    setS(() => isSaving = false);
                    if (err == null) {
                      Navigator.pop(ctx);
                      AppSnackBar.show(context, 'Thêm tài liệu thành công!', type: SnackType.success);
                    } else {
                      AppSnackBar.show(context, err, type: SnackType.error);
                    }
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, 
                foregroundColor: Colors.white, 
                elevation: 0,
              ),
              child: isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text('Thêm'),
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
