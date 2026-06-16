import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_colors.dart';
import '../../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L16 — Document Viewer Screen
// ════════════════════════════════════════════════════════════════════════════════
class DocumentViewerScreen extends StatefulWidget {
  final String url;
  final String title;
  final String? type; // 'PDF', 'DOCX', 'PPTX', etc.
  const DocumentViewerScreen({super.key, required this.url, required this.title, this.type});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _isLoading = false;

  String get _docType {
    if (widget.type != null) return widget.type!.toUpperCase();
    final url = widget.url.toLowerCase();
    if (url.contains('.pdf'))  return 'PDF';
    if (url.contains('.doc'))  return 'DOCX';
    if (url.contains('.ppt'))  return 'PPTX';
    if (url.contains('.xls'))  return 'XLSX';
    return 'Document';
  }

  Color get _typeColor => switch (_docType) {
    'PDF'  => AppColors.error,
    'DOCX' => AppColors.primary,
    'PPTX' => const Color(0xFFD44A1C),
    'XLSX' => AppColors.success,
    _      => AppColors.secondary,
  };

  IconData get _typeIcon => switch (_docType) {
    'PDF'  => Icons.picture_as_pdf_rounded,
    'DOCX' => Icons.description_rounded,
    'PPTX' => Icons.slideshow_rounded,
    'XLSX' => Icons.table_chart_rounded,
    _      => Icons.attach_file_rounded,
  };

  Future<void> _openInBrowser() async {
    setState(() => _isLoading = true);
    try {
      await launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) AppSnackBar.show(context, 'Không thể mở tài liệu.', type: SnackType.error);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _openWithGoogleDocs() async {
    final encoded   = Uri.encodeComponent(widget.url);
    final viewerUrl = 'https://docs.google.com/viewer?url=$encoded&embedded=true';
    try {
      await launchUrl(Uri.parse(viewerUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) AppSnackBar.show(context, 'Không thể mở Google Docs.', type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: 'Mở ngoài',
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(height: 32),

          // Document preview card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: Column(children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: _typeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(_typeIcon, size: 56, color: _typeColor),
              ),
              const SizedBox(height: 20),

              Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _typeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_docType, style: TextStyle(fontSize: 13, color: _typeColor, fontWeight: FontWeight.w700)),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.link_rounded, size: 16, color: AppColors.textHint),
                  const SizedBox(width: 8),
                  Expanded(child: Text(widget.url, style: const TextStyle(fontSize: 12, color: AppColors.textHint), overflow: TextOverflow.ellipsis)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 32),

          AppButton(
            label: 'MỞ TRONG TRÌNH DUYỆT',
            onPressed: _openInBrowser,
            isLoading: _isLoading,
            icon: Icons.open_in_browser_rounded,
          ),
          const SizedBox(height: 12),

          if (_docType != 'PDF')
            AppButton(
              label: 'XEM QUA GOOGLE DOCS',
              onPressed: _openWithGoogleDocs,
              variant: ButtonVariant.secondary,
              icon: Icons.g_mobiledata_rounded,
            ),
          const SizedBox(height: 12),

          AppButton(
            label: 'TẢI XUỐNG',
            onPressed: () async {
              try {
                await launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication);
              } catch (_) {
                if (context.mounted) AppSnackBar.show(context, 'Không thể tải xuống.', type: SnackType.error);
              }
            },
            variant: ButtonVariant.outline,
            icon: Icons.download_rounded,
          ),

          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withAlpha(60)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.info),
                const SizedBox(width: 6),
                const Text('Mẹo xem tài liệu', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.info)),
              ]),
              const SizedBox(height: 8),
              ...[
                '📱 Mở trong trình duyệt để xem trực tiếp',
                '📄 Google Docs hỗ trợ DOCX, PPTX, XLSX',
                '⬇️ Tải xuống để đọc offline',
              ].map((tip) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(tip, style: const TextStyle(fontSize: 12, color: AppColors.info, height: 1.4)),
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}
