# COMPONENT LIBRARY — FLIPPED CLASSROOM

> **Framework**: Flutter | **Design System**: Material Design 3
> **Font**: Inter | **Primary**: `#4F46E5`
> **File base**: `lib/widgets/`

---

## Table of Contents

| # | Component | File | Status |
|---|-----------|------|--------|
| 1 | [AppButton](#1-appbutton) | `widgets/app_button.dart` | ✅ |
| 2 | [AppTextField](#2-apptextfield) | `widgets/app_text_field.dart` | ✅ |
| 3 | [LoadingWidget](#3-loadingwidget) | `widgets/loading_widget.dart` | ✅ |
| 4 | [StatusBadge](#4-statusbadge) | `widgets/status_badge.dart` | ❌ |
| 5 | [CourseCard](#5-coursecard) | `widgets/course_card.dart` | ❌ |
| 6 | [ActivityCard](#6-activitycard) | `widgets/activity_card.dart` | ❌ |
| 7 | [SectionHeader](#7-sectionheader) | `widgets/section_header.dart` | ❌ |
| 8 | [EmptyStateWidget](#8-emptystate) | `widgets/empty_state.dart` | ❌ |
| 9 | [AppSnackBar](#9-appsnackbar) | `widgets/app_snack_bar.dart` | ❌ |
| 10 | [StatCard](#10-statcard) | `widgets/stat_card.dart` | ❌ |
| 11 | [NotificationCard](#11-notificationcard) | `widgets/notification_card.dart` | ❌ |
| 12 | [MemberListTile](#12-memberlisttile) | `widgets/member_list_tile.dart` | ❌ |
| 13 | [WeekCard](#13-weekcard) | `widgets/week_card.dart` | ❌ |
| 14 | [MaterialListTile](#14-materiallisttile) | `widgets/material_list_tile.dart` | ❌ |
| 15 | [EvidenceCard](#15-evidencecard) | `widgets/evidence_card.dart` | ❌ |
| 16 | [FilePickerWidget](#16-filepickerwidget) | `widgets/file_picker_widget.dart` | ❌ |
| 17 | [CommentTile](#17-commenttile) | `widgets/comment_tile.dart` | ❌ |
| 18 | [MilestoneCard](#18-milestonecard) | `widgets/milestone_card.dart` | ❌ |
| 19 | [RatingBar](#19-ratingbar) | `widgets/rating_bar.dart` | ❌ |
| 20 | [FilterChipGroup](#20-filterchipgroup) | `widgets/filter_chip_group.dart` | ❌ |
| 21 | [ConfirmDialog](#21-confirmdialog) | `widgets/confirm_dialog.dart` | ❌ |
| 22 | [ProgressStepCard](#22-progressstepcard) | `widgets/progress_step_card.dart` | ❌ |
| 23 | [SkeletonLoader](#23-skeletonloader) | `widgets/skeleton_loader.dart` | ❌ |
| 24 | [AppBarWidget](#24-appbarwidget) | `widgets/app_bar_widget.dart` | ❌ |
| 25 | [LearnerBottomNav](#25-learnerbottomnav) | `widgets/learner_bottom_nav.dart` | ❌ |
| 26 | [InstructorBottomNav](#26-instructorbottomnav) | `widgets/instructor_bottom_nav.dart` | ❌ |

---

## 1. AppButton

> **File**: `lib/widgets/app_button.dart` | **Status**: ✅ Đã implement

### Props

| Prop | Type | Default | Mô tả |
|------|------|---------|-------|
| `label` | `String` | required | Text hiển thị |
| `onPressed` | `VoidCallback?` | required | Callback khi nhấn |
| `variant` | `ButtonVariant` | `primary` | primary / secondary / danger / outline |
| `isLoading` | `bool` | `false` | Hiển thị loading spinner |
| `isFullWidth` | `bool` | `true` | Chiều rộng full |
| `icon` | `IconData?` | `null` | Icon bên trái label |

### Variants

```
┌──────────────────────────┐
│       ĐĂNG NHẬP          │  Primary — bg=#4F46E5, text=white
└──────────────────────────┘

┌──────────────────────────┐
│      XEM CHI TIẾT        │  Secondary — bg=#EEF2FF, text=#4F46E5
└──────────────────────────┘

┌──────────────────────────┐
│         XÓA              │  Danger — bg=#FEE2E2, text=#DC2626
└──────────────────────────┘

┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│        HỦY BỎ             │  Outline — border=#4F46E5, text=#4F46E5
└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘

┌──────────────────────────┐
│    ◌  (loading spinner)  │  Loading state (any variant)
└──────────────────────────┘
```

### Code

```dart
// Usage
AppButton(
  label: 'ĐĂNG NHẬP',
  onPressed: _login,
  isLoading: vm.isLoading,
)

AppButton(
  label: 'XÓA',
  variant: ButtonVariant.danger,
  icon: Icons.delete_outline_rounded,
  onPressed: _delete,
)
```

### Used in
SCR-L02, SCR-L03, SCR-L19, SCR-L22, SCR-L25, SCR-L30, SCR-L33, SCR-I03, SCR-I11, SCR-I18

---

## 2. AppTextField

> **File**: `lib/widgets/app_text_field.dart` | **Status**: ✅ Đã implement

### Props

| Prop | Type | Default | Mô tả |
|------|------|---------|-------|
| `label` | `String` | required | Label hiển thị trên field |
| `hint` | `String?` | `null` | Placeholder text |
| `controller` | `TextEditingController?` | `null` | Controller |
| `obscureText` | `bool` | `false` | Ẩn text (password) |
| `suffixIcon` | `Widget?` | `null` | Icon cuối (eye button...) |
| `validator` | `String? Function(String?)?` | `null` | Validation function |
| `keyboardType` | `TextInputType?` | `null` | Loại keyboard |
| `maxLines` | `int` | `1` | Số dòng tối đa |
| `readOnly` | `bool` | `false` | Chỉ đọc |
| `onTap` | `VoidCallback?` | `null` | Tap callback (cho date picker) |

### States

```
Label *
┌────────────────────────┐     Default — border: #E2E8F0
│  placeholder text      │
└────────────────────────┘

Label *
┌────────────────────────┐     Focused — border: #4F46E5 (2px)
│  user typing...        │
└────────────────────────┘

Label *                         Error — border + label: #EF4444
┌────────────────────────┐
│  invalid input         │
└────────────────────────┘
  Vui lòng nhập email hợp lệ.
```

### Used in
SCR-L02, SCR-L03, SCR-L33, SCR-I03, SCR-I07, SCR-I11, SCR-I13

---

## 3. LoadingWidget

> **File**: `lib/widgets/loading_widget.dart` | **Status**: ✅ Đã implement

```dart
// Full-screen loading
const LoadingWidget()

// Inside a button — dùng isLoading: true trong AppButton
```

```
        ◌    CircularProgressIndicator
             color: #4F46E5
             Center trong content area
```

---

## 4. StatusBadge

> **File**: `lib/widgets/status_badge.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `status` | `BadgeStatus` | pending / approved / rejected / locked / inProgress |
| `size` | `BadgeSize` | small / medium (default: medium) |

### Variants

```
 ┌─────────────┐
 │ ● Pending   │   bg: #FEF3C7, text: #D97706, dot: #F59E0B
 └─────────────┘

 ┌──────────────┐
 │ ✓ Approved   │   bg: #D1FAE5, text: #059669, dot: #10B981
 └──────────────┘

 ┌──────────────┐
 │ ✗ Rejected   │   bg: #FEE2E2, text: #DC2626, dot: #EF4444
 └──────────────┘

 ┌─────────────┐
 │ 🔒 Locked   │   bg: #F1F5F9, text: #94A3B8
 └─────────────┘

 ┌───────────────┐
 │ ● In Progress │   bg: #EFF6FF, text: #2563EB
 └───────────────┘
```

### Code

```dart
enum BadgeStatus { pending, approved, rejected, locked, inProgress }

class StatusBadge extends StatelessWidget {
  final BadgeStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: config.dot)),
        const SizedBox(width: 4),
        Text(config.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: config.text)),
      ]),
    );
  }
  // ... _getConfig() method
}
```

### Used in
SCR-L17, SCR-L18, SCR-L20, SCR-L21, SCR-L23, SCR-L24, SCR-L35, SCR-I17, SCR-I18

---

## 5. CourseCard

> **File**: `lib/widgets/course_card.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `course` | `CourseModel` | Dữ liệu khóa học |
| `progressPercent` | `double` | 0.0 – 1.0 (progress bar) |
| `onTap` | `VoidCallback` | Navigate to course detail |
| `width` | `double?` | Dùng khi horizontal scroll |

### Layout

```
┌──────────────────────────┐
│  [Cover Image 120px]     │  ClipRRect radius 12
│  (fallback: gradient bg) │
├──────────────────────────┤
│ PRM392 Mobile Dev   16sp │  Bold, maxLines: 2
│ 👤 Nguyễn Văn Bình  13sp │  textSecondary
│ 📅 12 tuần          12sp │  textHint
│                          │
│ ███████████░░░  75%  12sp│  LinearProgressIndicator
└──────────────────────────┘
  width: 180px (horizontal scroll mode)
  border-radius: 12px
  shadow: BoxShadow(blurRadius: 8, color: black12)
```

### Code

```dart
class CourseCard extends StatelessWidget {
  final CourseModel course;
  final double progressPercent;
  final VoidCallback onTap;
  final double? width;

  const CourseCard({
    super.key,
    required this.course,
    required this.progressPercent,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Cover Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: course.coverImageUrl ?? '',
              height: 120, width: double.infinity, fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                height: 120,
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary])),
                child: const Icon(Icons.school_rounded, size: 40, color: Colors.white),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.title, style: AppTextStyles.heading3.copyWith(fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('👤 ${course.instructorName}', style: AppTextStyles.bodySmall),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: LinearProgressIndicator(value: progressPercent, backgroundColor: AppColors.border, valueColor: const AlwaysStoppedAnimation(AppColors.primary))),
                const SizedBox(width: 8),
                Text('${(progressPercent * 100).toInt()}%', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
```

### Used in
SCR-L05 (horizontal scroll), SCR-L07 (vertical list), SCR-I02

---

## 6. ActivityCard

> **File**: `lib/widgets/activity_card.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `activity` | `ActivityModel` | Dữ liệu activity |
| `submission` | `ActivitySubmission?` | Evidence đã nộp (nullable) |
| `onTap` | `VoidCallback` | Navigate to detail |

### Layout

```
┌──────────────────────────────────┐
│ [●] Xem video chương 3      16sp │  ● màu theo type
│     [PreClass badge]             │
│                                  │
│     ⏰ Hạn: 09/06/2026 23:59     │  12sp, textHint
│                      [Pending]   │  StatusBadge
└──────────────────────────────────┘
padding: 16px, border-radius: 12px
border-left: 4px solid [type color]
```

**Type Colors** (dot + left border):
- PreClass: `#8B5CF6` (Violet)
- InClass: `#EC4899` (Pink)
- PostClass: `#F97316` (Orange)

**Deadline coloring**:
- Normal: textHint
- ≤ 24h còn lại: text = `#DC2626` (đỏ)
- Quá hạn: text = `#94A3B8` + strikethrough

### Code

```dart
class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final ActivitySubmission? submission;
  final VoidCallback onTap;

  // Type color mapping
  static Color typeColor(String type) => switch (type) {
    'PreClass'  => AppColors.preClass,
    'InClass'   => AppColors.inClass,
    'PostClass' => AppColors.postClass,
    _           => AppColors.primary,
  };

  static String typeLabel(String type) => switch (type) {
    'PreClass'  => 'Pre-Class',
    'InClass'   => 'In-Class',
    'PostClass' => 'Post-Class',
    _           => type,
  };

  @override
  Widget build(BuildContext context) {
    final color = typeColor(activity.type);
    final isOverdue = activity.deadline != null && activity.deadline!.isBefore(DateTime.now());
    final isUrgent = activity.deadline != null && activity.deadline!.difference(DateTime.now()).inHours <= 24;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 6),
              Text(typeLabel(activity.type), style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Text(activity.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
            if (activity.deadline != null) ...[
              const SizedBox(height: 4),
              Text(
                '⏰ Hạn: ${_formatDeadline(activity.deadline!)}',
                style: TextStyle(fontSize: 12, color: isOverdue ? AppColors.error : isUrgent ? AppColors.warning : AppColors.textHint),
              ),
            ],
          ])),
          if (submission != null) StatusBadge(status: _toStatus(submission!.status)),
        ]),
      ),
    );
  }

  String _formatDeadline(DateTime dt) => '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  BadgeStatus _toStatus(EvidenceStatus s) => switch (s) {
    EvidenceStatus.Pending  => BadgeStatus.pending,
    EvidenceStatus.Approved => BadgeStatus.approved,
    EvidenceStatus.Rejected => BadgeStatus.rejected,
  };
}
```

### Used in
SCR-L05, SCR-L12, SCR-L17, SCR-L20, SCR-L23

---

## 7. SectionHeader

> **File**: `lib/widgets/section_header.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `title` | `String` | Tiêu đề section |
| `actionLabel` | `String?` | Text nút "Xem tất cả" |
| `onAction` | `VoidCallback?` | Callback |

### Layout

```
KHÓA HỌC CỦA TÔI               Xem tất cả ►
14sp UPPERCASE #64748B          14sp #4F46E5
```

### Code

```dart
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(children: [
      Expanded(child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8))),
      if (actionLabel != null)
        GestureDetector(
          onTap: onAction,
          child: Text(actionLabel!, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
        ),
    ]),
  );
}
```

### Used in
SCR-L05, SCR-L07, SCR-I01

---

## 8. EmptyState

> **File**: `lib/widgets/empty_state.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `icon` | `IconData` | Icon trung tâm |
| `title` | `String` | Tiêu đề |
| `message` | `String` | Mô tả |
| `actionLabel` | `String?` | Text nút action |
| `onAction` | `VoidCallback?` | Callback |

### Layout

```
        [Icon 80px, color: #94A3B8]

        Chưa có dữ liệu              18sp, textSecondary
        Hãy thêm khóa học mới để    14sp, textHint
        bắt đầu học.

        ┌────────────────────┐
        │   + Thêm ngay      │       (optional action)
        └────────────────────┘
```

### Code

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 80, color: AppColors.textHint),
        const SizedBox(height: 16),
        Text(title, style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        if (actionLabel != null) ...[
          const SizedBox(height: 24),
          AppButton(label: actionLabel!, onPressed: onAction, variant: ButtonVariant.secondary),
        ],
      ]),
    ),
  );
}
```

### Used in
Tất cả list screens khi không có dữ liệu

---

## 9. AppSnackBar

> **File**: `lib/widgets/app_snack_bar.dart` | **Status**: ❌ Cần implement

### Variants

```
 ┌──────────────────────────────────────────┐
 │ ✅  Nộp evidence thành công!             │  Success — bg: #059669
 └──────────────────────────────────────────┘

 ┌──────────────────────────────────────────┐
 │ ❌  Đã xảy ra lỗi. Vui lòng thử lại.    │  Error — bg: #DC2626
 └──────────────────────────────────────────┘

 ┌──────────────────────────────────────────┐
 │ ⚠️  Sắp đến hạn nộp!                    │  Warning — bg: #D97706
 └──────────────────────────────────────────┘

 ┌──────────────────────────────────────────┐
 │ ℹ️  Bài nộp đang chờ giảng viên duyệt   │  Info — bg: #2563EB
 └──────────────────────────────────────────┘
```

**Duration**: 3 giây | **Position**: bottom

### Code

```dart
enum SnackType { success, error, warning, info }

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
```

```dart
// Usage
AppSnackBar.show(context, 'Nộp evidence thành công!', type: SnackType.success);
AppSnackBar.show(context, 'Lỗi kết nối!', type: SnackType.error);
```

---

## 10. StatCard

> **File**: `lib/widgets/stat_card.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `value` | `String` | Số liệu chính |
| `label` | `String` | Mô tả |
| `color` | `Color?` | Màu value (default: primary) |
| `icon` | `IconData?` | Icon trang trí |

### Layout

```
┌──────────────┐
│      12      │  28sp, Bold, color=primary
│  Evidence    │  12sp, textSecondary
│  chờ duyệt   │
└──────────────┘
border-radius: 12, bg: #F8FAFC, border: 1px #E2E8F0
padding: 16px
```

### Code

```dart
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
      if (icon != null) Icon(icon!, color: color ?? AppColors.primary, size: 24),
      Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color ?? AppColors.primary)),
      const SizedBox(height: 4),
      Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
    ]),
  );
}
```

### Used in
SCR-L40 (Learner stats), SCR-I01 (Instructor dashboard stats)

---

## 11. NotificationCard

> **File**: `lib/widgets/notification_card.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `notification` | `NotificationModel` | Dữ liệu notification |
| `onTap` | `VoidCallback` | Navigate |
| `onMarkRead` | `VoidCallback?` | Đánh dấu đã đọc |

### Layout

```
┌──────────────────────────────────────┐
│ 🔵 Evidence được duyệt ✅            │  Unread: bg=#EEF2FF, left border=#4F46E5
│    Bài nộp tuần 3 đã được Approved.  │  14sp
│                     08/06 15:00 12sp │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ ⚪ Hoạt động mới 📚                   │  Read: bg=white
│    Tuần 2 đã có hoạt động mới...     │
│                     08/06 08:00 12sp │
└──────────────────────────────────────┘
```

### Used in
SCR-L06

---

## 12. MemberListTile

> **File**: `lib/widgets/member_list_tile.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `user` | `UserModel` | Thông tin thành viên |
| `trailing` | `Widget?` | Widget bên phải |
| `onTap` | `VoidCallback?` | Tap callback |

### Layout

```
┌────────────────────────────────────────────┐
│ [Avatar 40px]  Lê Văn Minh           16sp  │
│                learner1@student.edu.vn 13sp │  [trailing]
└────────────────────────────────────────────┘
```

**Avatar fallback**: Lấy chữ cái đầu của FullName, bg = màu hash từ userId

### Code

```dart
class MemberListTile extends StatelessWidget {
  final UserModel user;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MemberListTile({super.key, required this.user, this.trailing, this.onTap});

  Color _avatarColor(int id) {
    final colors = [AppColors.primary, AppColors.secondary, AppColors.success, AppColors.warning];
    return colors[id % colors.length];
  }

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: CircleAvatar(
      radius: 20,
      backgroundColor: _avatarColor(user.id),
      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
      child: user.avatarUrl == null ? Text(user.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)) : null,
    ),
    title: Text(user.fullName, style: AppTextStyles.bodyLarge),
    subtitle: Text(user.email, style: AppTextStyles.bodySmall),
    trailing: trailing,
  );
}
```

### Used in
SCR-L10, SCR-I05

---

## 13. WeekCard

> **File**: `lib/widgets/week_card.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `path` | `LearningPathModel` | Dữ liệu learning path |
| `state` | `WeekState` | completed / inProgress / locked |
| `isLast` | `bool` | Ẩn connector line |
| `onTap` | `VoidCallback` | Navigate |

### Layout

```
  ╔═══════════════════════════════╗
  ║ ✅ Tuần 1 · Giới thiệu Flutter║  completed: border=green, icon=✅
  ║    4/4 hoạt động              ║
  ╚══════════════╦════════════════╝
                 │  (connector line, 24px)
  ╔══════════════╩════════════════╗
  ║ 🔵 Tuần 2 · Widgets & Layout  ║  inProgress: border=primary, icon=●
  ║    2/5 hoạt động              ║
  ╚══════════════╦════════════════╝
                 │
  ╔══════════════╩════════════════╗
  ║ 🔒 Tuần 3 · State Management  ║  locked: border=grey, opacity=0.6
  ╚═══════════════════════════════╝
```

### Used in
SCR-L11

---

## 14. MaterialListTile

> **File**: `lib/widgets/material_list_tile.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `material` | `LearningMaterialModel` | Dữ liệu tài liệu |
| `onTap` | `VoidCallback` | Navigate to detail |

### Layout

```
┌──────────────────────────────────────────┐
│ 🎬  Video Dart cơ bản 30 phút            │  Video type
│     youtube.com                  12sp    │
└──────────────────────────────────────────┘
┌──────────────────────────────────────────┐
│ 📄  Slide Tuần 1                         │  Document type
│     PDF · 2.4MB                  12sp    │
└──────────────────────────────────────────┘
┌──────────────────────────────────────────┐
│ 🔗  Flutter Official Docs                │  Link type
│     flutter.dev                  12sp    │
└──────────────────────────────────────────┘
```

**Icon mapping**: Video→`play_circle_rounded` | Document→`description_rounded` | Link→`link_rounded`

### Used in
SCR-L13, SCR-L14, SCR-I08

---

## 15. EvidenceCard

> **File**: `lib/widgets/evidence_card.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `submission` | `ActivitySubmission` | Dữ liệu evidence |
| `learnerName` | `String` | Tên learner |
| `activityTitle` | `String` | Tên activity |
| `onTap` | `VoidCallback` | Navigate |
| `showAvatar` | `bool` | Hiện avatar (Instructor view) |

### Layout (Instructor view)

```
┌──────────────────────────────────────────┐
│ [Av]  Lê Văn Minh                        │
│       Tuần 3 · Pre-Class                 │  14sp
│       Nộp: 08/06/2026 · 08:30       12sp│
│                             [Pending]    │
└──────────────────────────────────────────┘
```

### Layout (Learner view — My Evidence)

```
┌──────────────────────────────────────────┐
│ [●PreClass] Xem video chương 3           │
│ Nộp: 08/06/2026 · 10:30           12sp  │
│                          [Approved ✓]   │
└──────────────────────────────────────────┘
```

### Used in
SCR-L35, SCR-I17

---

## 16. FilePickerWidget

> **File**: `lib/widgets/file_picker_widget.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `onFilePicked` | `Function(File)` | Callback khi chọn xong |
| `allowedExtensions` | `List<String>` | Các loại file cho phép |
| `maxSizeMB` | `int` | Giới hạn dung lượng |
| `selectedFile` | `File?` | File đã chọn |

### States

```
Chưa chọn file:
┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│                                │
│   📎  Chọn file đính kèm       │  Dashed border: #E2E8F0
│   JPG, PNG, PDF, MP4           │
│   Tối đa 50MB                  │
│                                │
└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘

Đã chọn file:
┌──────────────────────────────┐
│ 📄 evidence_week3.pdf    ✕  │  bg=#EEF2FF, close button
│    2.4MB                     │
└──────────────────────────────┘
```

### Code

```dart
class FilePickerWidget extends StatelessWidget {
  final Function(File) onFilePicked;
  final List<String> allowedExtensions;
  final int maxSizeMB;
  final File? selectedFile;

  const FilePickerWidget({
    super.key,
    required this.onFilePicked,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'pdf', 'mp4'],
    this.maxSizeMB = 50,
    this.selectedFile,
  });

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final sizeInMB = await file.length() / (1024 * 1024);
      if (sizeInMB <= maxSizeMB) {
        onFilePicked(file);
      }
    }
  }
  // ... build()
}
```

### Used in
SCR-L19, SCR-L22, SCR-L25, SCR-L30, SCR-I09

---

## 17. CommentTile

> **File**: `lib/widgets/comment_tile.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `comment` | `EvidenceComment` | Dữ liệu comment |
| `authorName` | `String` | Tên người comment |
| `isInstructor` | `bool` | Hiển thị badge "GV" |

### Layout

```
[Av]  Nguyễn Văn Bình  [GV]     08/06 · 15:30
      ┌────────────────────────────────────┐
      │ Bài nộp tốt! Ghi chú đầy đủ và   │
      │ có ví dụ minh họa rõ ràng.        │  bg=#F1F5F9, radius 12
      └────────────────────────────────────┘

[Av]  Lê Văn Minh                08/06 · 17:30
      ┌────────────────────────────────────┐
      │ Vâng em cảm ơn thầy ạ.            │  bg=#EEF2FF (nếu currentUser)
      └────────────────────────────────────┘
```

### Used in
SCR-L36, SCR-I19

---

## 18. MilestoneCard

> **File**: `lib/widgets/milestone_card.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `milestone` | `Milestone` | Dữ liệu milestone |
| `isSubmitted` | `bool` | Đã nộp chưa |
| `stepNumber` | `int` | Số thứ tự (1-4) |
| `onTap` | `VoidCallback` | Navigate |

### Layout

```
  ①  Milestone 1: Setup & Architecture
     Due: 20/06/2026                ✓ Đã nộp (green)

  ②  Milestone 2: Authentication
     Due: 05/07/2026                ○ Chưa nộp (grey)

  ③  Milestone 3: Activities
     Due: 20/07/2026                🔒 Chưa đến hạn

  ④  Milestone 4: Review
     Due: 05/08/2026
```

### Used in
SCR-L27, SCR-L28, SCR-L39, SCR-I14

---

## 19. RatingBar

> **File**: `lib/widgets/rating_bar.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `rating` | `double` | Giá trị hiện tại (0-5) |
| `onRatingChanged` | `Function(double)?` | Callback (null = readonly) |
| `size` | `double` | Kích thước sao (default: 32) |

### Layout

```
Interactive:  ★ ★ ★ ★ ☆    (4/5) — màu: #F59E0B
Readonly:     ★ ★ ★ ☆ ☆    (3/5) — màu: #F59E0B
```

### Code

```dart
class AppRatingBar extends StatefulWidget {
  final double rating;
  final Function(double)? onRatingChanged;
  final double size;

  const AppRatingBar({super.key, required this.rating, this.onRatingChanged, this.size = 32});

  @override
  State<AppRatingBar> createState() => _AppRatingBarState();
}

class _AppRatingBarState extends State<AppRatingBar> {
  late double _rating;

  @override
  void initState() { super.initState(); _rating = widget.rating; }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) => GestureDetector(
      onTap: widget.onRatingChanged != null ? () => setState(() { _rating = i + 1.0; widget.onRatingChanged!(_rating); }) : null,
      child: Icon(i < _rating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFF59E0B), size: widget.size),
    )),
  );
}
```

### Used in
SCR-L33, SCR-L34

---

## 20. FilterChipGroup

> **File**: `lib/widgets/filter_chip_group.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `options` | `List<String>` | Danh sách options |
| `selected` | `String` | Option đang chọn |
| `onSelected` | `Function(String)` | Callback |
| `scrollable` | `bool` | Horizontal scroll (default: false) |

### Layout

```
[All] [Pending] [Approved] [Rejected]
   ↑ selected: filled primary bg
              ↑ unselected: outlined
```

### Code

```dart
class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final Function(String) onSelected;
  final bool scrollable;

  const FilterChipGroup({super.key, required this.options, required this.selected, required this.onSelected, this.scrollable = false});

  @override
  Widget build(BuildContext context) {
    final chips = options.map((opt) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(opt),
        selected: opt == selected,
        onSelected: (_) => onSelected(opt),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: opt == selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500),
        checkmarkColor: Colors.white,
      ),
    )).toList();

    return scrollable
        ? SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: chips))
        : Wrap(spacing: 8, children: chips);
  }
}
```

### Used in
SCR-I17 (Evidence filter), SCR-L13 (Material type filter), SCR-L38

---

## 21. ConfirmDialog

> **File**: `lib/widgets/confirm_dialog.dart` | **Status**: ❌ Cần implement

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `title` | `String` | Tiêu đề dialog |
| `message` | `String` | Nội dung |
| `confirmLabel` | `String` | Text nút xác nhận |
| `cancelLabel` | `String` | Text nút hủy (default: "Hủy") |
| `isDanger` | `bool` | Nút xác nhận màu đỏ |

### Layout

```
┌──────────────────────────────────┐
│                                  │
│  Xác nhận Approve                │  18sp Bold
│                                  │
│  Bạn có chắc muốn Approve bài    │  14sp
│  nộp của Lê Văn Minh?            │
│                                  │
│  ┌───────────┐  ┌──────────────┐ │
│  │   Hủy    │  │  ✅ APPROVE  │ │
│  └───────────┘  └──────────────┘ │
└──────────────────────────────────┘
```

### Code

```dart
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDanger;

  const ConfirmDialog({super.key, required this.title, required this.message, required this.confirmLabel, this.cancelLabel = 'Hủy', this.isDanger = false});

  static Future<bool?> show(BuildContext context, {required String title, required String message, required String confirmLabel, bool isDanger = false}) {
    return showDialog<bool>(context: context, builder: (_) => ConfirmDialog(title: title, message: message, confirmLabel: confirmLabel, isDanger: isDanger));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(title, style: AppTextStyles.heading3),
    content: Text(message, style: AppTextStyles.bodyMedium),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel)),
      AppButton(label: confirmLabel, onPressed: () => Navigator.pop(context, true), variant: isDanger ? ButtonVariant.danger : ButtonVariant.primary, isFullWidth: false),
    ],
  );
}
```

```dart
// Usage
final confirmed = await ConfirmDialog.show(
  context,
  title: 'Xác nhận Approve',
  message: 'Bạn có chắc muốn Approve bài nộp này?',
  confirmLabel: 'APPROVE',
);
if (confirmed == true) { /* proceed */ }
```

### Used in
SCR-I18 (Approve/Reject), Bất kỳ action nguy hiểm nào

---

## 22. ProgressStepCard

> **File**: `lib/widgets/progress_step_card.dart` | **Status**: ❌ Cần implement

Dùng trong Learning Path Overview — step indicator có connector line.

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `title` | `String` | Tiêu đề |
| `subtitle` | `String` | Ví dụ: "4/5 hoạt động" |
| `state` | `StepState` | completed / current / locked |
| `showConnector` | `bool` | Hiện đường nối xuống |
| `onTap` | `VoidCallback` | Navigate |

### Used in
SCR-L11

---

## 23. SkeletonLoader

> **File**: `lib/widgets/skeleton_loader.dart` | **Status**: ❌ Cần implement

Shimmer loading placeholder khi đang fetch data.

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `type` | `SkeletonType` | card / listTile / text / circle |
| `count` | `int` | Số lượng item (default: 3) |

### Layout

```
Đang load danh sách:
┌────────────────────────────────┐
│ ████████████████████░░░░░░░░░  │  Shimmer effect
│ ████████░░░░░░░░░░░░░░░░░░░░░  │  màu: #E2E8F0 → #F1F5F9
│ ████████████░░░░░░░░░░░░░░░░░  │  cycle: 1500ms
└────────────────────────────────┘
(repeat 3 times)
```

### Code

```dart
// Dùng package: shimmer: ^3.0.0
class SkeletonLoader extends StatelessWidget {
  final SkeletonType type;
  final int count;

  const SkeletonLoader({super.key, this.type = SkeletonType.listTile, this.count = 3});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.border,
    highlightColor: AppColors.surfaceVariant,
    child: ListView.separated(
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => _buildSkeleton(),
    ),
  );

  Widget _buildSkeleton() => switch (type) {
    SkeletonType.card     => Container(height: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
    SkeletonType.listTile => Container(height: 72, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
    SkeletonType.text     => Container(height: 16, width: double.infinity, color: Colors.white),
    SkeletonType.circle   => const CircleAvatar(backgroundColor: Colors.white, radius: 20),
  };
}
```

### Used in
Tất cả màn hình có fetch API

---

## 24. AppBarWidget

> **File**: `lib/widgets/app_bar_widget.dart` | **Status**: ❌ Cần implement

Custom AppBar tùy chỉnh cho các màn hình.

### Variants

```
Standard:
┌──────────────────────────────────────┐
│ ←  Tiêu đề màn hình          [🔔 2]  │  AppBar
└──────────────────────────────────────┘

Dashboard Header (colored):
┌──────────────────────────────────────┐
│ 👋 Xin chào, Lê Văn Minh!    [🔔 2]  │  bg=primary, text=white
│ Hôm nay bạn học gì?                  │  subtitle
└──────────────────────────────────────┘
```

### Props

| Prop | Type | Mô tả |
|------|------|-------|
| `title` | `String` | Tiêu đề |
| `subtitle` | `String?` | Subtitle (dashboard variant) |
| `showBack` | `bool` | Hiện nút back |
| `notificationCount` | `int` | Badge số thông báo |
| `actions` | `List<Widget>?` | Action buttons bên phải |
| `isColored` | `bool` | Dashboard style (primary bg) |

---

## 25. LearnerBottomNav

> **File**: `lib/widgets/learner_bottom_nav.dart` | **Status**: ❌ Cần implement

### Layout

```
┌──────┬──────┬──────┬──────┐
│  🏠  │  📚  │  📈  │  👤  │   height: 64px
│ Home │Courses│Progrs│Profile│
└──────┴──────┴──────┴──────┘
Active: icon + label = primary, underline indicator 2px
Inactive: icon + label = textHint
```

### Tabs

| Index | Label | Icon | Route |
|-------|-------|------|-------|
| 0 | Home | `home_rounded` | `/home` |
| 1 | Courses | `book_rounded` | `/courses` |
| 2 | Progress | `insights_rounded` | `/progress` |
| 3 | Profile | `person_rounded` | `/profile` |

---

## 26. InstructorBottomNav

> **File**: `lib/widgets/instructor_bottom_nav.dart` | **Status**: ❌ Cần implement

### Tabs

| Index | Label | Icon | Route |
|-------|-------|------|-------|
| 0 | Dashboard | `dashboard_rounded` | `/instructor/dashboard` |
| 1 | Courses | `school_rounded` | `/instructor/courses` |
| 2 | Evidence | `task_alt_rounded` | `/instructor/evidence` |
| 3 | Analytics | `bar_chart_rounded` | `/instructor/analytics` |

---

## Component Usage Matrix

| Component | Screens sử dụng |
|-----------|----------------|
| AppButton | L02, L03, L19, L22, L25, L30, L33, I03, I11, I18 |
| AppTextField | L02, L03, L33, I03, I07, I11, I13 |
| StatusBadge | L17–L25, L35, I17, I18 |
| CourseCard | L05, L07, I02 |
| ActivityCard | L05, L12, L17, L20, L23 |
| SectionHeader | L05, L07, I01 |
| EmptyState | Tất cả list screens |
| AppSnackBar | Tất cả screens có action |
| StatCard | L40, I01 |
| NotificationCard | L06 |
| MemberListTile | L10, I05 |
| WeekCard | L11 |
| MaterialListTile | L13, I08 |
| EvidenceCard | L35, I17 |
| FilePickerWidget | L19, L22, L25, L30, I09 |
| CommentTile | L36, I19 |
| MilestoneCard | L27–L29, L39, I14 |
| RatingBar | L33, L34 |
| FilterChipGroup | L13, L38, I17 |
| ConfirmDialog | I18, bất kỳ delete action |
| ProgressStepCard | L11 |
| SkeletonLoader | Tất cả screens fetch API |
| AppBarWidget | Tất cả screens |
| LearnerBottomNav | L05, L07, L37, L40 |
| InstructorBottomNav | I01, I02, I17, I20 |

---

## Thứ tự implement đề xuất

```
Ưu tiên 1 (Core — cần có trước khi code screen):
├── StatusBadge       ← Dùng ở rất nhiều chỗ
├── SectionHeader     ← Dùng ngay ở HomeScreen
├── EmptyState        ← Dùng ở tất cả list
├── AppSnackBar       ← Dùng sau mọi action
├── SkeletonLoader    ← UX loading state
└── LearnerBottomNav + InstructorBottomNav

Ưu tiên 2 (Feature screens):
├── CourseCard        ← SCR-L05, L07
├── ActivityCard      ← SCR-L05, L17, L20, L23
├── WeekCard          ← SCR-L11
└── MaterialListTile  ← SCR-L13

Ưu tiên 3 (Actions):
├── FilePickerWidget  ← Submit Evidence
├── EvidenceCard      ← SCR-L35, I17
├── FilterChipGroup   ← SCR-I17, L13
└── ConfirmDialog     ← SCR-I18 Approve/Reject

Ưu tiên 4 (Analytics & Review):
├── RatingBar         ← SCR-L33
├── MilestoneCard     ← SCR-L27
├── CommentTile       ← SCR-L36
└── StatCard          ← SCR-L40, I01
```
