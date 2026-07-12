import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/api_config.dart';
import '../../../../services/api_service.dart';
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
                      const SizedBox(height: 16),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        color: AppColors.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Đường dẫn gốc (URL):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              const SizedBox(height: 6),
                              Builder(builder: (ctx) {
                                var rawUrl = m['linkUrl'] ?? m['fileUrl'] ?? 'Chưa có đường dẫn';
                                if (rawUrl.startsWith('/')) {
                                  var base = ApiConfig.baseUrl;
                                  if (base.endsWith('/api')) {
                                    base = base.substring(0, base.length - 4);
                                  } else if (base.endsWith('/api/')) {
                                    base = base.substring(0, base.length - 5);
                                  }
                                  final normalizedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
                                  rawUrl = '$normalizedBase$rawUrl';
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SelectableText(rawUrl, style: const TextStyle(fontSize: 13, color: AppColors.primary, decoration: TextDecoration.underline)),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final uri = Uri.parse(rawUrl);
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      },
                                      icon: const Icon(Icons.download_rounded, size: 18),
                                      label: const Text('Tải file / Mở trình duyệt'),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
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
