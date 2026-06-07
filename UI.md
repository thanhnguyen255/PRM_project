# UI SPECIFICATION — FLIPPED CLASSROOM MOBILE APP

> **Version**: 1.0 | **Platform**: Flutter Mobile (Android & iOS)  
> **Design System**: Material Design 3  
> **Primary Font**: Inter

---

## Table of Contents

1. [Design System](#1-design-system)
2. [Color Palette](#2-color-palette)
3. [Typography](#3-typography)
4. [Spacing & Layout](#4-spacing--layout)
5. [Component Library](#5-component-library)
6. [Navigation Structure](#6-navigation-structure)
7. [Screen UI Specs — Learner](#7-screen-ui-specs--learner)
8. [Screen UI Specs — Instructor](#8-screen-ui-specs--instructor)
9. [Icons & Illustrations](#9-icons--illustrations)
10. [Animation & Transitions](#10-animation--transitions)

---

## 1. Design System

### Principles

| Principle | Mô tả |
|-----------|-------|
| **Clarity** | Thông tin rõ ràng, không gây nhầm lẫn — mỗi màn hình có 1 mục tiêu chính |
| **Consistency** | Component, spacing, màu sắc nhất quán toàn app |
| **Feedback** | Mọi hành động người dùng đều có phản hồi (loading, success, error) |
| **Accessibility** | Contrast ratio tối thiểu 4.5:1, font size tối thiểu 14sp |

### Design Tokens (Flutter — `app_colors.dart`, `app_theme.dart`)

```dart
// config/app_colors.dart
class AppColors {
  // Primary
  static const primary        = Color(0xFF4F46E5); // Indigo 600
  static const primaryLight   = Color(0xFF818CF8); // Indigo 400
  static const primaryDark    = Color(0xFF3730A3); // Indigo 800

  // Secondary
  static const secondary      = Color(0xFF06B6D4); // Cyan 500
  static const secondaryLight = Color(0xFF67E8F9); // Cyan 300

  // Status
  static const success        = Color(0xFF10B981); // Emerald 500
  static const warning        = Color(0xFFF59E0B); // Amber 500
  static const error          = Color(0xFFEF4444); // Red 500
  static const info           = Color(0xFF3B82F6); // Blue 500

  // Neutral
  static const background     = Color(0xFFF8FAFC); // Slate 50
  static const surface        = Color(0xFFFFFFFF); // White
  static const surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const border         = Color(0xFFE2E8F0); // Slate 200
  static const textPrimary    = Color(0xFF0F172A); // Slate 900
  static const textSecondary  = Color(0xFF64748B); // Slate 500
  static const textHint       = Color(0xFF94A3B8); // Slate 400
  static const textOnPrimary  = Color(0xFFFFFFFF); // White

  // Activity Type Colors
  static const preClass       = Color(0xFF8B5CF6); // Violet 500
  static const inClass        = Color(0xFFEC4899); // Pink 500
  static const postClass      = Color(0xFFF97316); // Orange 500
}
```

---

## 2. Color Palette

### Primary Colors

| Tên | Hex | Dùng cho |
|-----|-----|---------|
| `primary` | `#4F46E5` | Button chính, active nav, header accent |
| `primaryLight` | `#818CF8` | Hover state, chip selected |
| `primaryDark` | `#3730A3` | Pressed state |

### Status Colors

| Tên | Hex | Dùng cho |
|-----|-----|---------|
| `success` | `#10B981` | Approved, Completed, upload success |
| `warning` | `#F59E0B` | Deadline gần, Pending |
| `error` | `#EF4444` | Rejected, lỗi, required field |
| `info` | `#3B82F6` | Thông tin, In Progress |

### Activity Type Colors

| Activity | Hex | Badge color |
|----------|-----|------------|
| Pre-Class | `#8B5CF6` | Violet |
| In-Class | `#EC4899` | Pink |
| Post-Class | `#F97316` | Orange |

### Evidence Status Colors

| Status | Background | Text |
|--------|------------|------|
| Pending | `#FEF3C7` | `#D97706` |
| Approved | `#D1FAE5` | `#059669` |
| Rejected | `#FEE2E2` | `#DC2626` |

---

## 3. Typography

### Font

```yaml
# pubspec.yaml
fonts:
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf    # weight: 400
      - asset: assets/fonts/Inter-Medium.ttf     # weight: 500
      - asset: assets/fonts/Inter-SemiBold.ttf   # weight: 600
      - asset: assets/fonts/Inter-Bold.ttf       # weight: 700
```

### Text Styles

| Style Name | Size | Weight | Dùng cho |
|------------|------|--------|---------|
| `heading1` | 28sp | Bold 700 | Tên màn hình lớn |
| `heading2` | 22sp | SemiBold 600 | Section title |
| `heading3` | 18sp | SemiBold 600 | Card title, AppBar title |
| `bodyLarge` | 16sp | Regular 400 | Body text chính |
| `bodyMedium` | 14sp | Regular 400 | Body text phụ, placeholder |
| `bodySmall` | 12sp | Regular 400 | Caption, timestamp |
| `labelLarge` | 16sp | Medium 500 | Button text |
| `labelMedium` | 14sp | Medium 500 | Chip, badge |
| `labelSmall` | 12sp | Medium 500 | Tag, label nhỏ |

```dart
// config/app_text_styles.dart
class AppTextStyles {
  static const heading1   = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const heading2   = TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const heading3   = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const bodyLarge  = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const bodySmall  = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textHint);
  static const labelLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
}
```

---

## 4. Spacing & Layout

### Spacing Scale

```dart
// config/app_spacing.dart
class AppSpacing {
  static const double xs  =  4.0;
  static const double sm  =  8.0;
  static const double md  = 12.0;
  static const double lg  = 16.0;
  static const double xl  = 20.0;
  static const double xl2 = 24.0;
  static const double xl3 = 32.0;
  static const double xl4 = 40.0;
  static const double xl5 = 48.0;
}
```

### Layout Rules

| Rule | Value |
|------|-------|
| Screen horizontal padding | `16px` (left & right) |
| Card border radius | `12px` |
| Button border radius | `10px` |
| Input border radius | `10px` |
| Bottom navigation height | `64px` |
| AppBar height | `56px` (default Material) |
| List item height (standard) | `72px` |
| Avatar size (list) | `40px` |
| Avatar size (profile) | `80px` |
| FAB size | `56px` |

---

## 5. Component Library

### 5.1 AppButton

```
┌─────────────────────────────┐
│       [ LABEL TEXT ]        │   height: 52px
└─────────────────────────────┘   border-radius: 10px
```

| Variant | Background | Text Color | Dùng cho |
|---------|-----------|-----------|---------|
| Primary | `#4F46E5` | White | Hành động chính (Đăng nhập, Nộp) |
| Secondary | `#EEF2FF` | `#4F46E5` | Hành động phụ |
| Danger | `#FEE2E2` | `#DC2626` | Xóa, Reject |
| Outline | Transparent | `#4F46E5` | Border `1px solid #4F46E5` |
| Disabled | `#E2E8F0` | `#94A3B8` | Khi không thể nhấn |

**States**: Normal → Hovered (opacity 0.9) → Pressed (scale 0.97) → Loading (CircularProgressIndicator)

---

### 5.2 AppTextField

```
Label *
┌─────────────────────────────────┐
│  placeholder text          [icon]│   height: 52px
└─────────────────────────────────┘
  Helper text / Error message
```

| State | Border Color | Label Color |
|-------|-------------|------------|
| Default | `#E2E8F0` | `#64748B` |
| Focused | `#4F46E5` | `#4F46E5` |
| Error | `#EF4444` | `#EF4444` |
| Disabled | `#F1F5F9` | `#94A3B8` |

---

### 5.3 CourseCard

```
┌────────────────────────────────┐
│  [Cover Image]                 │  height: 120px
│                                │
├────────────────────────────────┤
│  Course Title              16sp│
│  Instructor Name           14sp│  padding: 12px
│  ████████████░░░ 75%       12sp│  (progress bar)
└────────────────────────────────┘
  border-radius: 12px, shadow: sm
```

---

### 5.4 ActivityCard

```
┌─────────────────────────────────────┐
│ [●PreClass] Activity Title      16sp│
│ Deadline: 10/06/2026            12sp│  padding: 16px
│                      [Pending badge]│
└─────────────────────────────────────┘
```

**Badge Colors**: theo Evidence Status Colors ở phần 2

---

### 5.5 StatusBadge

```
 ┌────────────┐
 │  ● Pending │   padding: 4px 10px, border-radius: 20px
 └────────────┘
```

| Status | BG | Text |
|--------|----|------|
| Pending | `#FEF3C7` | `#D97706` |
| Approved | `#D1FAE5` | `#059669` |
| Rejected | `#FEE2E2` | `#DC2626` |
| Locked | `#F1F5F9` | `#94A3B8` |
| In Progress | `#EFF6FF` | `#2563EB` |

---

### 5.6 LoadingWidget

- Centered `CircularProgressIndicator` với màu `primary`
- Chiếm toàn bộ diện tích nội dung (không block AppBar)

---

### 5.7 EmptyStateWidget

```
        [Illustration icon - 120px]

        Chưa có dữ liệu                 18sp SemiBold
        Hãy thêm nội dung mới           14sp, textSecondary

        [  + Thêm ngay  ]               (nếu cần action)
```

---

### 5.8 SnackBar (Toast)

| Type | Icon | BG Color | Dùng cho |
|------|------|---------|---------|
| Success | ✅ | `#059669` | Nộp thành công, lưu thành công |
| Error | ❌ | `#DC2626` | Lỗi API, validation |
| Warning | ⚠️ | `#D97706` | Cảnh báo deadline |
| Info | ℹ️ | `#2563EB` | Thông tin chung |

Duration: **3 giây** | Position: **bottom**

---

### 5.9 Bottom Navigation Bar

```
┌──────┬──────┬──────┬──────┐
│  🏠  │  📚  │  📈  │  👤  │   height: 64px
│ Home │Course│Progrs│Profle│
└──────┴──────┴──────┴──────┘
```

**Learner**: Home | Courses | Progress | Profile  
**Instructor**: Dashboard | Courses | Evidence | Analytics

- Active item: icon + label màu `primary`, underline indicator
- Inactive item: icon + label màu `textHint`

---

## 6. Navigation Structure

### Learner — Bottom Nav Tabs

| Tab | Icon | Root Screen |
|-----|------|------------|
| Home | `home_rounded` | SCR-L05 Home Dashboard |
| Courses | `book_rounded` | SCR-L07 My Courses |
| Progress | `insights_rounded` | SCR-L37 Learning Progress |
| Profile | `person_rounded` | SCR-L40 Profile |

### Instructor — Bottom Nav Tabs

| Tab | Icon | Root Screen |
|-----|------|------------|
| Dashboard | `dashboard_rounded` | SCR-I01 |
| Courses | `school_rounded` | SCR-I02 Manage Courses |
| Evidence | `task_rounded` | SCR-I17 Evidence List |
| Analytics | `bar_chart_rounded` | SCR-I20 Analytics |

---

## 7. Screen UI Specs — Learner

### SCR-L01 — Splash Screen

```
┌──────────────────────────────┐
│                              │
│                              │
│       [App Logo 120px]       │
│                              │
│    Flipped Classroom    28sp │
│   Học tập hiệu quả hơn  14sp│
│                              │
│    ════════════════          │
│     LinearProgressIndicator  │
│                              │
└──────────────────────────────┘
BG: gradient(#4F46E5 → #06B6D4), text: white
```

---

### SCR-L02 — Login Screen

```
┌──────────────────────────────┐
│ ← [Back]                     │  AppBar (transparent)
│                              │
│  Xin chào 👋             28sp│
│  Đăng nhập để tiếp tục   14sp│
│                              │
│  Email *                     │
│  ┌──────────────────────┐    │
│  │  email@example.com   │    │
│  └──────────────────────┘    │
│                              │
│  Mật khẩu *                  │
│  ┌──────────────────────┐    │
│  │  ••••••••         👁 │    │
│  └──────────────────────┘    │
│                 Quên MK? ──► │
│                              │
│  ┌──────────────────────┐    │
│  │      ĐĂNG NHẬP       │    │  Primary button
│  └──────────────────────┘    │
│                              │
│  Chưa có tài khoản?          │
│  Đăng ký ngay ──────────►    │
└──────────────────────────────┘
```

---

### SCR-L03 — Register Screen

```
┌──────────────────────────────┐
│ ← [Back]          Đăng ký    │
│                              │
│  Tạo tài khoản          22sp │
│                              │
│  Họ và tên *                 │
│  ┌──────────────────────┐    │
│  │  Nguyễn Văn A        │    │
│  └──────────────────────┘    │
│                              │
│  Email *                     │
│  ┌──────────────────────┐    │
│  └──────────────────────┘    │
│                              │
│  Mật khẩu *                  │
│  ┌──────────────────────┐    │
│  └──────────────────────┘    │
│                              │
│  Xác nhận mật khẩu *         │
│  ┌──────────────────────┐    │
│  └──────────────────────┘    │
│                              │
│  ┌──────────────────────┐    │
│  │       ĐĂNG KÝ        │    │
│  └──────────────────────┘    │
└──────────────────────────────┘
```

---

### SCR-L05 — Home Dashboard

```
┌──────────────────────────────┐
│  👋 Xin chào, Minh!     🔔 2 │  Header: bg=primary, text=white
│  Hôm nay bạn học gì?         │
├──────────────────────────────┤
│  KHÓA HỌC CỦA TÔI       Xem│  Section header
│  ┌──────────┐ ┌──────────┐   │
│  │[img]     │ │[img]     │   │  Horizontal scroll
│  │PRM393    │ │SWP490    │   │
│  │████░ 75% │ │██░░░ 40% │   │
│  └──────────┘ └──────────┘   │
├──────────────────────────────┤
│  HOẠT ĐỘNG SẮP ĐẾN           │
│  ┌──────────────────────────┐ │
│  │ ●PreClass  Đọc chương 3  │ │
│  │ ⏰ Hạn: 09/06 23:59      │ │  ActivityCard
│  └──────────────────────────┘ │
│  ┌──────────────────────────┐ │
│  │ ●InClass   Bài tập nhóm  │ │
│  │ ⏰ Hạn: 10/06 17:00      │ │
│  └──────────────────────────┘ │
├──────────────────────────────┤
│  🏠    📚    📈    👤         │  Bottom Nav
└──────────────────────────────┘
```

---

### SCR-L07 — My Courses

```
┌──────────────────────────────┐
│  Khóa học của tôi            │  AppBar
│  🔍 Tìm kiếm...              │  Search bar
├──────────────────────────────┤
│  ┌────────────────────────┐  │
│  │ [Cover Image]          │  │
│  │                        │  │  CourseCard
│  │ PRM393 - Mobile Dev    │  │
│  │ GV: Nguyen Van B  📅12w│  │
│  │ ████████████░░░░  75%  │  │
│  └────────────────────────┘  │
│                              │
│  ┌────────────────────────┐  │
│  │ [Cover Image]          │  │
│  │ SWP490 - Capstone      │  │
│  │ GV: Tran Thi C    📅 8w│  │
│  │ ████░░░░░░░░░░░░  40%  │  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

### SCR-L08 — Course Detail

```
┌──────────────────────────────┐
│ ← PRM393 Mobile Dev          │  AppBar
│  [Cover Image full width]    │  200px height
│                              │
│  PRM393 - Mobile Dev    22sp │
│  👤 GV: Nguyen Van B    14sp │
│  📅 12 tuần · 32 học viên    │
│                              │
│  ┌──────┬──────────┬───────┐ │
│  │Lớp HK│ Tài liệu │Tiến độ│ │  Tab bar
│  └──────┴──────────┴───────┘ │
│                              │
│  Danh sách lớp:              │
│  ┌────────────────────────┐  │
│  │ 📅 L01 - 03/06 → 30/08│  │
│  │ 32 thành viên      ►   │  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

### SCR-L11 — Learning Path Overview

```
┌──────────────────────────────┐
│ ← Lộ trình học               │
│  ████████████░░░░  75%  22sp │  Overall progress
│  18/24 hoạt động        14sp │
├──────────────────────────────┤
│  ┌────────────────────────┐  │
│  │ ✅ Tuần 1 · Intro      │  │  Completed (green)
│  └─────────────┬──────────┘  │
│                │              │
│  ┌─────────────▼──────────┐  │
│  │ 🔵 Tuần 2 · Chapter 2  │  │  In Progress (blue)
│  └─────────────┬──────────┘  │
│                │              │
│  ┌─────────────▼──────────┐  │
│  │ 🔒 Tuần 3 · Chapter 3  │  │  Locked (grey)
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

### SCR-L17/L20/L23 — Activity List

```
┌──────────────────────────────┐
│ ← Pre-Class Activities       │
├──────────────────────────────┤
│  ┌────────────────────────┐  │
│  │ ●  Xem video chương 3  │  │
│  │    ⏰ Hạn: 09/06        │  │
│  │              [Pending]  │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ ●  Đọc slide tuần 3    │  │
│  │    ⏰ Hạn: 09/06        │  │
│  │             [Approved ✓]│  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ ●  Bài tập trắc nghiệm │  │
│  │    ⏰ Hạn: 10/06        │  │
│  │              [Rejected ✗]│  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

### SCR-L19/L22/L25 — Submit Evidence

```
┌──────────────────────────────┐
│ ← Nộp bằng chứng             │
│                              │
│  Mô tả / Ghi chú             │
│  ┌────────────────────────┐  │
│  │ Nhập ghi chú...        │  │  multiline, 4 lines
│  │                        │  │
│  │                        │  │
│  └────────────────────────┘  │
│                              │
│  File đính kèm               │
│  ┌────────────────────────┐  │
│  │                        │  │
│  │   📎 Chọn file         │  │  Dashed border
│  │   JPG, PNG, PDF, MP4   │  │
│  │   Tối đa 50MB          │  │
│  └────────────────────────┘  │
│                              │
│  [Preview ảnh/file tên]      │
│                              │
│  ┌────────────────────────┐  │
│  │          NỘP           │  │  Primary button
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

### SCR-L37 — Learning Progress

```
┌──────────────────────────────┐
│ ← Tiến độ học tập            │
├──────────────────────────────┤
│  Tổng quan                   │
│  ┌────────────────────────┐  │
│  │  [Donut Chart 150px]   │  │
│  │       75%              │  │  fl_chart
│  │   Hoàn thành           │  │
│  └────────────────────────┘  │
│                              │
│  Chi tiết theo tuần          │
│  Tuần 1  ████████████ 100%   │
│  Tuần 2  ████████░░░░  75%   │
│  Tuần 3  ████░░░░░░░░  40%   │
│                              │
│  Hoạt động                   │
│  ✅ Đã hoàn thành      18    │
│  ⏳ Đang chờ duyệt      4    │
│  ❌ Chưa nộp            2    │
└──────────────────────────────┘
```

---

### SCR-L40 — Profile

```
┌──────────────────────────────┐
│  Hồ sơ cá nhân               │
│                              │
│       [Avatar 80px]          │  Center
│                              │
│    Nguyễn Văn Minh      18sp │
│    minhnv@email.com     14sp │
│                              │
│  ┌──────────┬─────────────┐  │
│  │    3     │     72      │  │  Stats card
│  │ Khóa học │ HĐ hoàn thành│  │
│  └──────────┴─────────────┘  │
│                              │
│  ┌────────────────────────┐  │
│  │ ✏️  Chỉnh sửa hồ sơ    │  │  List tile
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ 🔑  Đổi mật khẩu       │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ 🚪  Đăng xuất      ►   │  │  Red text
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

## 8. Screen UI Specs — Instructor

### SCR-I01 — Instructor Dashboard

```
┌──────────────────────────────┐
│  Xin chào, GV Bình! 👋  🔔  │  Header: primary bg
├──────────────────────────────┤
│  Thống kê nhanh              │
│  ┌──────┬──────┬──────────┐  │
│  │  3   │  12  │    5     │  │
│  │ Lớp  │Evidence│ Review │  │  Stat cards row
│  │đang dạy│ chờ  │ chờ    │  │
│  └──────┴──────┴──────────┘  │
│                              │
│  Lớp đang dạy                │
│  ┌────────────────────────┐  │
│  │ PRM393 - L01           │  │
│  │ 32 học viên · 8 tuần   │  │
│  └────────────────────────┘  │
│                              │
│  Evidence cần duyệt     Xem ►│
│  ┌────────────────────────┐  │
│  │ Minh - Tuần 3 Pre-Class│  │
│  │ ⏰ Nộp lúc 08:30        │  │  [Pending badge]
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

### SCR-I03 — Create/Edit Course

```
┌──────────────────────────────┐
│ ← Tạo khóa học mới           │
│                              │
│  [Cover Image Picker]        │  Dashed box 200px height
│  + Chọn ảnh bìa              │  tap to pick image
│                              │
│  Tên khóa học *              │
│  ┌────────────────────────┐  │
│  └────────────────────────┘  │
│                              │
│  Mô tả                       │
│  ┌────────────────────────┐  │
│  │                        │  │  5 lines
│  └────────────────────────┘  │
│                              │
│  ┌────────────────────────┐  │
│  │        LƯU             │  │  Primary button
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

### SCR-I17 — Evidence List

```
┌──────────────────────────────┐
│ ← Evidence cần duyệt         │
│                              │
│ [All][Pending][Approved][Rejected]  Filter chips
│                              │
│  ┌────────────────────────┐  │
│  │ [Avatar] Nguyễn Văn Minh│ │
│  │ Tuần 3 · Pre-Class     │  │
│  │ Nộp: 08/06 · 08:30     │  │
│  │               [Pending]│  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ [Avatar] Trần Thị Lan  │  │
│  │ Tuần 3 · In-Class      │  │
│  │ Nộp: 08/06 · 14:15     │  │
│  │              [Pending] │  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

### SCR-I18 — Evidence Detail (Instructor)

```
┌──────────────────────────────┐
│ ← Chi tiết Evidence          │
│                              │
│  [Preview Image / PDF icon]  │  200px height
│                              │
│  Nguyễn Văn Minh        16sp │
│  Tuần 3 · Pre-Class     14sp │
│  Nộp lúc: 08/06 08:30   12sp │
│                              │
│  Ghi chú của học viên:       │
│  "Em đã xem video và hoàn... │
│                              │
│  ┌─────────────┐ ┌─────────┐ │
│  │  ✅ APPROVE │ │ ❌ REJECT│ │  2 buttons side by side
│  └─────────────┘ └─────────┘ │
│                              │
│  ┌────────────────────────┐  │
│  │  💬 Xem bình luận (3)  │  │  Secondary button
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

### SCR-I20 — Learning Analytics

```
┌──────────────────────────────┐
│ ← Thống kê học tập           │
│  PRM393 · L01           14sp │
│                              │
│  Tỷ lệ hoàn thành            │
│  ┌────────────────────────┐  │
│  │  [Donut Chart 150px]   │  │
│  │       68%              │  │
│  └────────────────────────┘  │
│                              │
│  Tiến độ theo tuần           │
│  ┌────────────────────────┐  │
│  │  [Bar Chart 200px]     │  │  fl_chart
│  │  W1  W2  W3  W4  W5    │  │
│  └────────────────────────┘  │
│                              │
│  Học viên tích cực nhất      │
│  🥇 Nguyễn Văn Minh  22/24  │
│  🥈 Trần Thị Lan     20/24  │
│  🥉 Lê Văn Hùng      18/24  │
└──────────────────────────────┘
```

---

## 9. Icons & Illustrations

### Icon Library

Dùng **Material Icons Rounded** (built-in Flutter):

| Màn hình / Feature | Icon |
|--------------------|------|
| Home | `home_rounded` |
| Courses | `book_rounded` |
| Progress | `insights_rounded` |
| Profile | `person_rounded` |
| Dashboard (Instructor) | `dashboard_rounded` |
| Evidence | `task_alt_rounded` |
| Analytics | `bar_chart_rounded` |
| Notification | `notifications_rounded` |
| Video | `play_circle_rounded` |
| Document/PDF | `description_rounded` |
| Link | `link_rounded` |
| Upload | `upload_file_rounded` |
| Camera/Image | `photo_camera_rounded` |
| Deadline | `schedule_rounded` |
| Project | `folder_special_rounded` |
| Milestone | `flag_rounded` |
| Review | `rate_review_rounded` |
| Feedback | `thumb_up_rounded` |
| Members | `group_rounded` |
| Settings | `settings_rounded` |
| Logout | `logout_rounded` |
| Add / FAB | `add_rounded` |
| Edit | `edit_rounded` |
| Delete | `delete_outline_rounded` |
| Back | `arrow_back_rounded` |
| Approved | `check_circle_rounded` |
| Rejected | `cancel_rounded` |
| Pending | `pending_rounded` |

---

## 10. Animation & Transitions

### Page Transitions

| Loại | Thư viện / Cách dùng |
|------|---------------------|
| Push (đi vào màn mới) | Slide từ phải sang trái (GoRouter default) |
| Pop (quay lại) | Slide từ trái sang phải |
| Bottom Sheet | Slide từ dưới lên |
| Dialog | Fade + scale |

### Micro-animations

| Element | Animation |
|---------|-----------|
| Button nhấn | Scale 0.97 + opacity 0.9 trong 100ms |
| Card tap | Ripple effect (Material InkWell) |
| Loading indicator | CircularProgressIndicator xoay |
| Progress bar | Animate từ 0 → giá trị thực khi vào màn |
| Status badge | FadeIn khi load |
| SnackBar | Slide up từ dưới, auto-dismiss sau 3s |
| FAB | Scale + rotate 45° khi mở menu |
| Tab switch | Animated underline indicator |

### Loading States

```
Skeleton Loading (khi fetch data):
┌────────────────────────────┐
│ ████████████████████░░░░░ │  Shimmer effect
│ ████████░░░░░░░░░░░░░░░░░ │  màu: #E2E8F0 → #F1F5F9
│ ████████████░░░░░░░░░░░░░ │
└────────────────────────────┘
Package: shimmer ^3.0.0
```

### Duration Guidelines

| Animation | Duration |
|-----------|----------|
| Micro-interaction (button) | 100ms |
| Page transition | 250ms |
| Modal/Bottom sheet | 300ms |
| Progress bar fill | 500ms |
| Skeleton shimmer cycle | 1500ms |
