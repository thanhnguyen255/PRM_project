import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/app_colors.dart';
import '../../../../widgets/widgets.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String url;
  final String title;

  const DocumentViewerScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Tài liệu này sẽ được mở bên ngoài ứng dụng.',
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    AppSnackBar.show(context, 'Không thể mở liên kết này.', type: SnackType.error);
                  }
                }
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Mở tài liệu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
