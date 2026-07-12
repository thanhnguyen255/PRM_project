import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class MaterialListTile extends StatelessWidget {
  final Map<String, dynamic> material;

  const MaterialListTile({super.key, required this.material});

  String get _type => material['type'] as String? ?? '';

  IconData get _icon {
    switch (_type) {
      case 'Video':
        return Icons.play_circle_rounded;
      case 'Document':
        return Icons.description_rounded;
      case 'Link':
        return Icons.link_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Color get _color {
    switch (_type) {
      case 'Video':
        return AppColors.secondary; // #EC4899
      case 'Document':
        return AppColors.primary; // #4F46E5
      case 'Link':
        return const Color(0xFF06B6D4);
      default:
        return AppColors.primary;
    }
  }

  List<Color> get _gradientColors {
    switch (_type) {
      case 'Video':
        return [const Color(0xFF7C3AED), AppColors.secondary];
      case 'Document':
        return [AppColors.primary, const Color(0xFF4F46E5)];
      case 'Link':
        return [const Color(0xFF0EA5E9), const Color(0xFF06B6D4)];
      default:
        return [AppColors.primary, const Color(0xFF4F46E5)];
    }
  }

  String get _typeLabel {
    switch (_type) {
      case 'Video':
        return '▶ Video';
      case 'Document':
        return '📄 Tài liệu';
      case 'Link':
        return '🔗 Liên kết';
      default:
        return '📄 Tài liệu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/material-detail', arguments: {'id': material['id']});
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _color.withAlpha(60)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6)],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _gradientColors),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(material['title'] as String? ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
              child: Text(_typeLabel, style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w600)),
            ),
          ])),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 22),
        ]),
      ),
    );
  }
}
