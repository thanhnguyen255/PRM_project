import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_colors.dart';

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
