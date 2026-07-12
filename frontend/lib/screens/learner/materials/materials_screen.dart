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
    String? filePath;
    String? fileName;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          scrollable: true,
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () => Navigator.pop(ctx), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: isSaving 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text('Thêm'),
                  ),
                ),
              ],
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
