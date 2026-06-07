import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';
import '../../widgets/widgets.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SCR-L15 — Video Player Screen
// ════════════════════════════════════════════════════════════════════════════════
class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final String title;
  const VideoPlayerScreen({super.key, required this.url, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoCtrl;
  ChewieController?      _chewieCtrl;
  bool                   _isInitializing = true;
  String?                _error;

  @override
  void initState() {
    super.initState();
    _initVideo();
    // Lock to landscape when entering
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _initVideo() async {
    try {
      final uri = Uri.parse(widget.url);
      _videoCtrl = VideoPlayerController.networkUrl(uri);
      await _videoCtrl!.initialize();

      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoCtrl!.value.aspectRatio,
        autoInitialize: true,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        ),
        errorBuilder: (ctx, err) => Container(
          color: Colors.black,
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white54, size: 48),
            const SizedBox(height: 12),
            Text(err, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          ])),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }

    if (mounted) setState(() => _isInitializing = false);
  }

  @override
  void dispose() {
    _chewieCtrl?.dispose();
    _videoCtrl?.dispose();
    // Restore orientations
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontSize: 15, color: Colors.white), overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: Colors.white70),
            tooltip: 'Mở trong trình duyệt',
            onPressed: () => launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: _isInitializing
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Đang tải video...', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ]))
          : _error != null
              ? _ErrorFallback(url: widget.url, error: _error!)
              : _chewieCtrl != null
                  ? Column(children: [
                      Expanded(child: Center(child: Chewie(controller: _chewieCtrl!))),
                      _VideoInfo(title: widget.title, url: widget.url),
                    ])
                  : const Center(child: Text('Không thể tải video', style: TextStyle(color: Colors.white70))),
    );
  }
}

class _VideoInfo extends StatelessWidget {
  final String title;
  final String url;
  const _VideoInfo({required this.title, required this.url});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
    color: const Color(0xFF1A1A2E),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Row(children: [
        const Icon(Icons.link_rounded, size: 14, color: Colors.white38),
        const SizedBox(width: 4),
        Expanded(child: Text(url, style: const TextStyle(color: Colors.white38, fontSize: 11), overflow: TextOverflow.ellipsis)),
        TextButton.icon(
          onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          icon: const Icon(Icons.open_in_browser_rounded, size: 14, color: AppColors.primary),
          label: const Text('Mở ngoài', style: TextStyle(color: AppColors.primary, fontSize: 12)),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
        ),
      ]),
    ]),
  );
}

class _ErrorFallback extends StatelessWidget {
  final String url;
  final String error;
  const _ErrorFallback({required this.url, required this.error});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.videocam_off_rounded, size: 40, color: AppColors.error),
        ),
        const SizedBox(height: 20),
        const Text('Không thể phát video', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Video không tương thích hoặc không thể truy cập.', style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(150), height: 1.5), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          icon: const Icon(Icons.open_in_browser_rounded),
          label: const Text('Mở trong trình duyệt'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white54),
          label: const Text('Quay lại', style: TextStyle(color: Colors.white54)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ]),
    ),
  );
}

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
              // File type icon
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

              // URL preview
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

          // Action buttons
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

          // Tips
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
