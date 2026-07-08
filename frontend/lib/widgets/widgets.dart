import 'package:flutter/material.dart';
import '../config/app_colors.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum ButtonVariant { primary, secondary, danger, outline }
enum BadgeStatus  { pending, approved, rejected, locked, inProgress, open, closed }
enum SnackType    { success, error, warning, info }

// ═══════════════════════════════════════════════════════════════════════════════
// 1. AppButton
// ═══════════════════════════════════════════════════════════════════════════════

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = _buildStyle();
    final child = isLoading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
            Text(label),
          ]);

    Widget btn;
    if (variant == ButtonVariant.outline) {
      btn = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      );
    } else {
      btn = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      );
    }

    return isFullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  ButtonStyle _buildStyle() {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          elevation: 0,
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight, foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        );
      case ButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.errorLight, foregroundColor: AppColors.error,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        );
      case ButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 2. AppTextField
// ═══════════════════════════════════════════════════════════════════════════════

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: obscureText ? 1 : maxLines,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
        validator: validator,
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// 3. StatusBadge
// ═══════════════════════════════════════════════════════════════════════════════

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  final double? fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize});

  static BadgeStatus fromString(String? s) => switch (s?.toLowerCase()) {
    'pending'     => BadgeStatus.pending,
    'approved'    => BadgeStatus.approved,
    'rejected'    => BadgeStatus.rejected,
    'locked'      => BadgeStatus.locked,
    'inprogress'  => BadgeStatus.inProgress,
    'open'        => BadgeStatus.open,
    'closed'      => BadgeStatus.closed,
    _             => BadgeStatus.pending,
  };

  @override
  Widget build(BuildContext context) {
    final cfg = _config();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: cfg.dot)),
        const SizedBox(width: 4),
        Text(cfg.label, style: TextStyle(fontSize: fontSize ?? 12, fontWeight: FontWeight.w500, color: cfg.text)),
      ]),
    );
  }

  ({Color bg, Color dot, Color text, String label}) _config() => switch (status) {
    BadgeStatus.pending    => (bg: AppColors.warningLight, dot: AppColors.warning,   text: const Color(0xFFD97706), label: 'Pending'),
    BadgeStatus.approved   => (bg: AppColors.successLight, dot: AppColors.success,   text: const Color(0xFF059669), label: 'Approved'),
    BadgeStatus.rejected   => (bg: AppColors.errorLight,   dot: AppColors.error,     text: AppColors.error,         label: 'Rejected'),
    BadgeStatus.locked     => (bg: AppColors.surfaceVariant, dot: AppColors.textHint, text: AppColors.textHint,     label: 'Locked'),
    BadgeStatus.inProgress => (bg: AppColors.infoLight,    dot: AppColors.info,      text: AppColors.info,          label: 'In Progress'),
    BadgeStatus.open       => (bg: AppColors.successLight, dot: AppColors.success,   text: const Color(0xFF059669), label: 'Open'),
    BadgeStatus.closed     => (bg: AppColors.surfaceVariant, dot: AppColors.textHint, text: AppColors.textHint,     label: 'Closed'),
  };
}

// ═══════════════════════════════════════════════════════════════════════════════
// 4. SectionHeader
// ═══════════════════════════════════════════════════════════════════════════════

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(children: [
      Expanded(child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8),
      )),
      if (actionLabel != null)
        GestureDetector(
          onTap: onAction,
          child: Text(actionLabel!, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
        ),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// 5. EmptyState
// ═══════════════════════════════════════════════════════════════════════════════

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 72, color: AppColors.textHint),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(message, style: const TextStyle(fontSize: 14, color: AppColors.textHint), textAlign: TextAlign.center),
        if (actionLabel != null) ...[
          const SizedBox(height: 24),
          AppButton(label: actionLabel!, onPressed: onAction, variant: ButtonVariant.secondary, isFullWidth: false),
        ],
      ]),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// 6. AppSnackBar
// ═══════════════════════════════════════════════════════════════════════════════

class AppSnackBar {
  static void show(BuildContext context, String message, {SnackType type = SnackType.info}) {
    final (color, icon) = switch (type) {
      SnackType.success => (const Color(0xFF059669), Icons.check_circle_rounded),
      SnackType.error   => (const Color(0xFFDC2626), Icons.cancel_rounded),
      SnackType.warning => (const Color(0xFFD97706), Icons.warning_rounded),
      SnackType.info    => (const Color(0xFF2563EB), Icons.info_rounded),
    };

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14))),
      ]),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 7. StatCard
// ═══════════════════════════════════════════════════════════════════════════════

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? color;
  final IconData? icon;

  const StatCard({super.key, required this.value, required this.label, this.color, this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(children: [
      if (icon != null) Icon(icon!, color: color ?? AppColors.primary, size: 22),
      if (icon != null) const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: color ?? AppColors.primary)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// 8. CourseCard
// ═══════════════════════════════════════════════════════════════════════════════

class CourseCard extends StatelessWidget {
  final String title;
  final String instructorName;
  final String? coverImageUrl;
  final double progressPercent;
  final VoidCallback onTap;
  final double? width;

  const CourseCard({
    super.key,
    required this.title,
    required this.instructorName,
    this.coverImageUrl,
    required this.progressPercent,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 2))],
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Cover
        Container(
          height: 110,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: coverImageUrl != null
              ? Image.network(coverImageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholder())
              : _placeholder(),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text('👤 $instructorName', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  minHeight: 5,
                ),
              )),
              const SizedBox(width: 8),
              Text('${(progressPercent * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ]),
          ]),
        ),
      ]),
    ),
  );

  Widget _placeholder() => const Icon(Icons.school_rounded, size: 40, color: Colors.white54);
}

// ═══════════════════════════════════════════════════════════════════════════════
// 9. ActivityCard
// ═══════════════════════════════════════════════════════════════════════════════

class ActivityCard extends StatelessWidget {
  final String title;
  final String type;         // "PreClass" | "InClass" | "PostClass"
  final DateTime? deadline;
  final String? submissionStatus;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.title,
    required this.type,
    this.deadline,
    this.submissionStatus,
    required this.onTap,
  });

  static Color typeColor(String t) => switch (t) {
    'PreClass'  => AppColors.preClass,
    'InClass'   => AppColors.inClass,
    'PostClass' => AppColors.postClass,
    _           => AppColors.primary,
  };

  static String typeLabel(String t) => switch (t) {
    'PreClass'  => 'Pre-Class',
    'InClass'   => 'In-Class',
    'PostClass' => 'Post-Class',
    _           => t,
  };

  @override
  Widget build(BuildContext context) {
    final color      = typeColor(type);
    final now        = DateTime.now();
    final isOverdue  = deadline != null && deadline!.isBefore(now) && submissionStatus == null;
    final isUrgent   = deadline != null && deadline!.difference(now).inHours <= 24 && submissionStatus == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 1))],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(4)),
                child: Text(typeLabel(type), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
            if (deadline != null) ...[
              const SizedBox(height: 4),
              Text(
                '⏰ Hạn: ${_formatDeadline(deadline!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverdue ? AppColors.error : isUrgent ? AppColors.warning : AppColors.textHint,
                  decoration: isOverdue && submissionStatus == null ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ])),
          if (submissionStatus != null)
            StatusBadge(status: StatusBadge.fromString(submissionStatus)),
        ]),
      ),
    );
  }

  String _formatDeadline(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════════════════════════
// 10. NotificationCard
// ═══════════════════════════════════════════════════════════════════════════════

class NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface : AppColors.primaryLight,
        border: Border(left: BorderSide(color: isRead ? AppColors.border : AppColors.primary, width: 3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 8, height: 8,
          margin: const EdgeInsets.only(top: 6, right: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isRead ? AppColors.textHint : AppColors.primary,
          ),
        ),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: isRead ? FontWeight.w400 : FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(_formatTime(createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        ])),
      ]),
    ),
  );

  String _formatTime(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} · '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════════════════════════
// 11. MemberListTile
// ═══════════════════════════════════════════════════════════════════════════════

class MemberListTile extends StatelessWidget {
  final String fullName;
  final String email;
  final String? avatarUrl;
  final int userId;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MemberListTile({
    super.key,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.userId,
    this.trailing,
    this.onTap,
  });

  Color _avatarColor() {
    const colors = [AppColors.primary, AppColors.secondary, AppColors.success, AppColors.warning];
    return colors[userId % colors.length];
  }

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: CircleAvatar(
      radius: 20,
      backgroundColor: _avatarColor(),
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))
          : null,
    ),
    title: Text(fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
    subtitle: Text(email, style: const TextStyle(fontSize: 13, color: AppColors.textHint)),
    trailing: trailing,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// 12. FilterChipGroup
// ═══════════════════════════════════════════════════════════════════════════════

class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final Function(String) onSelected;

  const FilterChipGroup({super.key, required this.options, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: options.map((opt) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(opt, style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: opt == selected ? Colors.white : AppColors.textPrimary,
          )),
          selected: opt == selected,
          onSelected: (_) => onSelected(opt),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surfaceVariant,
          checkmarkColor: Colors.white,
          showCheckmark: false,
          side: BorderSide(color: opt == selected ? AppColors.primary : AppColors.border),
        ),
      )).toList(),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// 13. ConfirmDialog
// ═══════════════════════════════════════════════════════════════════════════════

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDanger;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Hủy',
    this.isDanger = false,
  });

  static Future<bool?> show(BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDanger = false,
  }) => showDialog<bool>(context: context, builder: (_) => ConfirmDialog(
    title: title, message: message, confirmLabel: confirmLabel, isDanger: isDanger,
  ));

  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    content: Text(message, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel)),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDanger ? AppColors.error : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(confirmLabel),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// 14. LoadingWidget
// ═══════════════════════════════════════════════════════════════════════════════

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(color: AppColors.primary),
      if (message != null) ...[
        const SizedBox(height: 12),
        Text(message!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ],
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// 15. CommentTile
// ═══════════════════════════════════════════════════════════════════════════════

class CommentTile extends StatelessWidget {
  final String authorName;
  final String? authorAvatar;
  final int authorId;
  final bool isInstructor;
  final String content;
  final DateTime createdAt;
  final int currentUserId;

  const CommentTile({
    super.key,
    required this.authorName,
    this.authorAvatar,
    required this.authorId,
    required this.isInstructor,
    required this.content,
    required this.createdAt,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = authorId == currentUserId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) _avatar(),
          if (!isMe) const SizedBox(width: 8),
          Flexible(child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(authorName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                if (isInstructor) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(4)),
                    child: const Text('GV', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
                const SizedBox(width: 8),
                Text(
                  '${createdAt.hour.toString().padLeft(2,'0')}:${createdAt.minute.toString().padLeft(2,'0')}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint),
                ),
              ]),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primaryLight : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(content, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
              ),
            ],
          )),
          if (isMe) const SizedBox(width: 8),
          if (isMe) _avatar(),
        ],
      ),
    );
  }

  Widget _avatar() {
    const colors = [AppColors.primary, AppColors.secondary, AppColors.success];
    final color = colors[authorId % colors.length];
    return CircleAvatar(
      radius: 16,
      backgroundColor: color,
      backgroundImage: authorAvatar != null ? NetworkImage(authorAvatar!) : null,
      child: authorAvatar == null
          ? Text(authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))
          : null,
    );
  }
}
