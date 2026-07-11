import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_colors.dart';
import '../../../../viewmodels/extended_viewmodels.dart';
import '../../../../widgets/widgets.dart';

class MaterialDetailScreen extends StatefulWidget {
  final int materialId;
  const MaterialDetailScreen({super.key, required this.materialId});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialViewModel>().loadMaterialDetail(widget.materialId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MaterialViewModel>();
    final m = vm.materialDetail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Chi tiết tài liệu')),
      body: vm.isLoading
          ? const LoadingWidget()
          : m == null
              ? const EmptyState(icon: Icons.error_outline, title: 'Lỗi', message: 'Không tìm thấy tài liệu.')
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['title'] as String? ?? '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          m['type'] as String? ?? '',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final isVideo = (m['type'] as String? ?? '').toLowerCase().contains('video');
                            if (isVideo) {
                              Navigator.pushNamed(context, '/video-player', arguments: {
                                'url': m['linkUrl'] ?? m['fileUrl'] ?? '',
                                'title': m['title'] ?? '',
                              });
                            } else {
                              Navigator.pushNamed(context, '/document-viewer', arguments: {
                                'url': m['fileUrl'] ?? m['linkUrl'] ?? '',
                                'title': m['title'] ?? '',
                              });
                            }
                          },
                          icon: Icon((m['type'] as String? ?? '').toLowerCase().contains('video') ? Icons.play_arrow : Icons.menu_book),
                          label: Text((m['type'] as String? ?? '').toLowerCase().contains('video') ? 'Xem Video' : 'Đọc Tài liệu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
