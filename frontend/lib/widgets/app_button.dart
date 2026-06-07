import 'package:flutter/material.dart';
import '../config/app_colors.dart';

enum ButtonVariant { primary, secondary, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = switch (variant) {
      ButtonVariant.primary   => AppColors.primary,
      ButtonVariant.secondary => const Color(0xFFEEF2FF),
      ButtonVariant.danger    => const Color(0xFFFEE2E2),
    };
    final textColor = switch (variant) {
      ButtonVariant.primary   => Colors.white,
      ButtonVariant.secondary => AppColors.primary,
      ButtonVariant.danger    => AppColors.error,
    };

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
