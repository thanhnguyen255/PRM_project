# SCREEN DESIGN SPECIFICATION — FLIPPED CLASSROOM

> **Platform**: Flutter Mobile (Android & iOS)
> **Total Screens**: 62 (41 Learner + 21 Instructor)
> **Design System**: Material Design 3 | Font: Inter | Primary: `#4F46E5`
> **Version**: 1.0

---

## Table of Contents

- [Design Tokens](#design-tokens)
- [Part 1 — Learner App (41 screens)](#part-1--learner-app)
- [Part 2 — Instructor App (21 screens)](#part-2--instructor-app)
- [Navigation Flow](#navigation-flow)

---

## Design Tokens

| Token | Value |
|-------|-------|
| Primary | `#4F46E5` (Indigo 600) |
| Secondary | `#06B6D4` (Cyan 500) |
| Success | `#10B981` |
| Warning | `#F59E0B` |
| Error | `#EF4444` |
| Background | `#F8FAFC` |
| Surface | `#FFFFFF` |
| Text Primary | `#0F172A` |
| Text Secondary | `#64748B` |
| Border | `#E2E8F0` |
| Border Radius (card) | `12px` |
| Border Radius (button) | `10px` |
| Screen Padding | `16px` |

---

# Part 1 — Learner App

## 1.1 Authentication

---

### SCR-L01 · Splash Screen

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/auth/splash_screen.dart` |
| **Route** | `/splash` |
| **Auth** | Không cần |
| **Status** | ✅ Đã implement |

**Layout**:
```
┌──────────────────────────────┐
│                              │
│                              │
│    [Icon school 80px]        │  Center, white
│                              │
│   Flipped Classroom     28sp │  white, Bold
│  Học tập hiệu quả hơn   14sp│  white70
│                              │
│   ════════════════════       │  LinearProgressIndicator
│                              │
└──────────────────────────────┘
Background: LinearGradient(#4F46E5 → #06B6D4)
```

**Logic**:
- Delay 2 giây → kiểm tra role từ SharedPreferences
- Role = `Learner` → `/home`
- Role = `Instructor` → `/instructor/dashboard`
- Không có token → `/login`

---

### SCR-L02 · Login Screen

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/auth/login_screen.dart` |
| **Route** | `/login` |
| **API** | `POST /api/auth/login` |
| **Status** | ✅ Đã implement |

**Layout**:
```
┌──────────────────────────────┐
│                              │
│  Xin chào 👋            28sp │
│  Đăng nhập để tiếp tục  14sp│
│                              │
│  Email *                     │
│  ┌──────────────────────┐    │
│  │ email@example.com    │    │
│  └──────────────────────┘    │
│                              │
│  Mật khẩu *                  │
│  ┌──────────────────────┐    │
│  │ ••••••••          👁 │    │
│  └──────────────────────┘    │
│                 Quên MK? ──► │
│                              │
│  ┌──────────────────────┐    │
│  │      ĐĂNG NHẬP       │    │  Primary btn, height 52
│  └──────────────────────┘    │
│                              │
│  Chưa có tài khoản?          │
│  Đăng ký ngay ──────────►    │  TextButton → /register
└──────────────────────────────┘
```

**Validation**: Email format | Password ≥ 6 ký tự

---

### SCR-L03 · Register Screen

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/auth/register_screen.dart` |
| **Route** | `/register` |
| **API** | `POST /api/auth/register` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ←  Tạo tài khoản        22sp │
│                              │
│  Họ và tên *                 │
│  ┌──────────────────────┐    │
│  └──────────────────────┘    │
│  Email *                     │
│  ┌──────────────────────┐    │
│  └──────────────────────┘    │
│  Mật khẩu *                  │
│  ┌──────────────────────┐    │
│  └──────────────────────┘    │
│  Xác nhận mật khẩu *         │
│  ┌──────────────────────┐    │
│  └──────────────────────┘    │
│                              │
│  ┌──────────────────────┐    │
│  │       ĐĂNG KÝ        │    │
│  └──────────────────────┘    │
│                              │
│  Đã có tài khoản? Đăng nhập  │
└──────────────────────────────┘
```

**Validation**: Email unique | Password match | FullName không trống

---

### SCR-L04 · Forgot Password Screen

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/auth/forgot_password_screen.dart` |
| **Route** | `/forgot-password` |
| **API** | `POST /api/auth/forgot-password` *(Out of scope v1.0)* |
| **Status** | ❌ Out of scope |

**Layout**: AppBar "Quên mật khẩu" + Email field + Nút "Gửi OTP"

---

## 1.2 Dashboard

---

### SCR-L05 · Home Dashboard

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/home/home_screen.dart` |
| **Route** | `/home` |
| **API** | `GET /api/courses/my`, `GET /api/notifications` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ 👋 Xin chào, [Name]!    🔔 2 │  bg=primary, white
│ Hôm nay bạn học gì?          │
├──────────────────────────────┤
│  KHÓA HỌC CỦA TÔI   Xem tất│
│  ╔══════════╗ ╔══════════╗   │
│  ║[img]     ║ ║[img]     ║   │  Horizontal scroll
│  ║PRM393    ║ ║SWP391    ║   │
│  ║████░ 75% ║ ║██░░░ 40% ║   │
│  ╚══════════╝ ╚══════════╝   │
├──────────────────────────────┤
│  HOẠT ĐỘNG SẮP ĐẾN           │
│  ┌──────────────────────────┐│
│  │ ●Pre Đọc chương 3        ││  ActivityCard
│  │ ⏰ Hạn: 09/06 23:59      ││
│  │               [Pending]  ││
│  └──────────────────────────┘│
│  ┌──────────────────────────┐│
│  │ ●In  Bài tập nhóm        ││
│  │ ⏰ Hạn: 10/06 17:00      ││
│  └──────────────────────────┘│
├──────────────────────────────┤
│  🏠    📚    📈    👤         │  BottomNav
└──────────────────────────────┘
```

**Components**: CourseCard (horizontal scroll), ActivityCard, Bottom Navigation

---

### SCR-L06 · Notifications

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/notifications/notifications_screen.dart` |
| **Route** | `/notifications` |
| **API** | `GET /api/notifications`, `PUT /api/notifications/{id}/read` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ←  Thông báo          🗑 Xóa │
│  [Đánh dấu tất cả đã đọc]   │
├──────────────────────────────┤
│  ┌────────────────────────┐  │
│  │ 🔵 Evidence được duyệt  │  │  Unread: bg=#EEF2FF
│  │ Bài nộp tuần 3...  12sp│  │
│  │          08/06 15:00   │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ ⚪ Hoạt động mới        │  │  Read: bg=white
│  │ Tuần 2 đã có...    12sp│  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

**Behavior**: Tap → mark as read + navigate tới màn hình liên quan

---

## 1.3 Course & Class

---

### SCR-L07 · My Courses

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/course/my_courses_screen.dart` |
| **Route** | `/courses` (Tab 2 BottomNav) |
| **API** | `GET /api/courses/my` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│  Khóa học của tôi            │
│  🔍 Tìm kiếm khóa học...     │
├──────────────────────────────┤
│  ┌────────────────────────┐  │
│  │[Cover Image 120px]     │  │
│  ├────────────────────────┤  │
│  │ PRM393 - Mobile Dev    │  │  16sp Bold
│  │ 👤 Nguyen Van Binh     │  │  14sp
│  │ 📅 12 tuần             │  │  12sp
│  │ ████████████░░░░  75%  │  │  LinearProgressIndicator
│  └────────────────────────┘  │
│  (Repeat CourseCard)         │
└──────────────────────────────┘
```

---

### SCR-L08 · Course Detail

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/course/course_detail_screen.dart` |
| **Route** | `/courses/:courseId` |
| **API** | `GET /api/courses/{id}` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← PRM393 Mobile Dev          │
│ [Cover Image - 200px]        │
├──────────────────────────────┤
│ PRM393 - Mobile Dev     22sp │
│ 👤 Nguyen Van Binh      14sp │
│ 📅 12 tuần · 32 học viên     │
│                              │
│ ┌──────┬──────────┬────────┐ │
│ │Lớp HK│ Tài liệu │ Tiến độ│ │  TabBar
│ └──────┴──────────┴────────┘ │
│                              │
│ [Tab content: Class list]    │
│ ┌──────────────────────────┐ │
│ │📅 SE1801 · 01/06–30/08   │ │
│ │32 thành viên          ►  │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

**Tabs**: Lớp học kỳ | Tài liệu | Tiến độ

---

### SCR-L09 · Class Detail

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/course/class_detail_screen.dart` |
| **Route** | `/classes/:classId` |
| **API** | `GET /api/classes/{id}` |
| **Status** | ❌ Chưa implement |

**Layout**: AppBar + Class info card + TabBar (Lộ trình | Thành viên | Dự án | Review)

---

### SCR-L10 · Members List

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/course/members_screen.dart` |
| **Route** | `/classes/:classId/members` |
| **API** | `GET /api/classes/{id}/members` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Thành viên lớp     32 người│
│ 🔍 Tìm thành viên...         │
├──────────────────────────────┤
│ [Avatar 40px] Lê Văn Minh   │  ListTile
│               learner1@...   │
│ [Avatar 40px] Phạm Thị Lan  │
└──────────────────────────────┘
```

---

## 1.4 Learning Path

---

### SCR-L11 · Learning Path Overview

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/learning_path/learning_path_screen.dart` |
| **Route** | `/classes/:classId/learning-path` |
| **API** | `GET /api/learning-paths/:classId` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Lộ trình học               │
│ ████████████░░░░  75%   22sp │
│ 18/24 hoạt động         14sp │
├──────────────────────────────┤
│  ╔══════════════════════╗    │
│  ║ ✅ Tuần 1 · Intro    ║    │  Completed - green border
│  ╚══════╦═══════════════╝    │
│         │ (connector line)   │
│  ╔══════╩═══════════════╗    │
│  ║ 🔵 Tuần 2 · Chapter 2║    │  In Progress - blue border
│  ╚══════╦═══════════════╝    │
│         │                    │
│  ╔══════╩═══════════════╗    │
│  ║ 🔒 Tuần 3 · Chapter 3║    │  Locked - grey border
│  ╚══════════════════════╝    │
└──────────────────────────────┘
```

**States**: Completed (✅ green) | In Progress (🔵 blue) | Locked (🔒 grey)

---

### SCR-L12 · Learning Path Detail (Week Detail)

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/learning_path/week_detail_screen.dart` |
| **Route** | `/learning-paths/:pathId` |
| **API** | `GET /api/learning-paths/:pathId/activities` |
| **Status** | ❌ Chưa implement |

**Layout**: AppBar "Tuần 1: Giới thiệu Flutter" + sections Pre/In/Post-class activities + Materials section

---

## 1.5 Learning Materials

---

### SCR-L13 · Learning Materials List

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/materials/materials_screen.dart` |
| **Route** | `/learning-paths/:pathId/materials` |
| **API** | `GET /api/materials/:pathId` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Tài liệu học              │
│ [Video][Document][Link] ─ filter chips
├──────────────────────────────┤
│ 🎬 Video Dart cơ bản 30 phút│  ListTile
│    youtube.com          12sp │
│ 📄 Slide Tuần 1             │  ListTile
│    PDF · 2.4MB          12sp │
│ 🔗 Flutter Docs             │  ListTile
│    flutter.dev          12sp │
└──────────────────────────────┘
```

---

### SCR-L14 · Material Detail

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/materials/material_detail_screen.dart` |
| **Route** | `/materials/:materialId` |
| **Status** | ❌ Chưa implement |

**Layout**: Title + Description + Preview thumbnail + Action button (Xem video / Tải tài liệu / Mở link)

---

### SCR-L15 · Video Player

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/materials/video_player_screen.dart` |
| **Package** | `youtube_player_flutter` hoặc `video_player` |
| **Status** | ❌ Chưa implement |

**Layout**: Full-screen video player + title + description bên dưới

---

### SCR-L16 · Document Viewer

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/materials/document_viewer_screen.dart` |
| **Package** | `flutter_pdfview` hoặc open external |
| **Status** | ❌ Chưa implement |

---

## 1.6 Pre-Class Activities

---

### SCR-L17 · Pre-Class Activities List

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/activities/pre_class/pre_class_list_screen.dart` |
| **Route** | `/learning-paths/:pathId/pre-class` |
| **API** | `GET /api/activities/:pathId?type=PreClass` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Pre-Class Activities       │
├──────────────────────────────┤
│ ┌──────────────────────────┐ │
│ │ ● Xem video chương 3     │ │  ActivityCard
│ │   ⏰ Hạn: 09/06 23:59    │ │  badge: Pending (vàng)
│ │                [Pending] │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ ● Đọc slide tuần 3       │ │
│ │   ⏰ Hạn: 09/06 23:59    │ │  badge: Approved (xanh)
│ │              [Approved✓] │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │ ● Bài tập trắc nghiệm    │ │
│ │   ⏰ Hạn: 10/06 23:59    │ │  badge: Rejected (đỏ)
│ │              [Rejected✗] │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

**Badge Colors**: Pending=`#FEF3C7` | Approved=`#D1FAE5` | Rejected=`#FEE2E2`

---

### SCR-L18 · Activity Detail (Pre-Class)

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/activities/pre_class/pre_class_detail_screen.dart` |
| **Route** | `/activities/:activityId` |
| **API** | `GET /api/activities/{id}` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Xem video chương 3         │
│ [●PreClass badge]            │
│                              │
│ Mô tả                        │
│ Xem video 'Dart cơ bản...' và│
│ ghi chú các điểm chính về:   │
│ variables, functions...      │
│                              │
│ ⏰ Hạn nộp: 09/06/2026 23:59 │
│                              │
│ Trạng thái: [Pending badge]  │
│                              │
│ ┌──────────────────────────┐ │
│ │      NỘP BẰNG CHỨNG      │ │  Primary btn
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │    XEM BÌNH LUẬN (2)     │ │  Secondary btn
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

---

### SCR-L19 · Submit Activity Evidence (Pre-Class)

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/activities/pre_class/submit_evidence_screen.dart` |
| **Route** | `/activities/:activityId/submit` |
| **API** | `POST /api/evidences` (multipart/form-data) |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Nộp bằng chứng             │
│                              │
│  Ghi chú / Mô tả             │
│  ┌────────────────────────┐  │
│  │ Nhập ghi chú...        │  │  4 lines, maxLines=8
│  │                        │  │
│  └────────────────────────┘  │
│                              │
│  File đính kèm               │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│  │  📎 Chọn file           │  │  Dashed border
│  │  JPG, PNG, PDF, MP4    │  │
│  │  Tối đa 50MB           │  │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
│                              │
│  [Preview: filename.pdf]     │  Hiện sau khi chọn file
│                              │
│  ┌────────────────────────┐  │
│  │          NỘP           │  │  Primary btn
│  └────────────────────────┘  │
└──────────────────────────────┘

**Logic**: Chỉ cho phép nộp (hoặc nộp lại) khi trạng thái là `null`, `Pending` hoặc `Rejected`. Nếu trạng thái là `Approved`, ẩn nút NỘP.
```

---

## 1.7 In-Class Activities

### SCR-L20 · In-Class Activities List

Tương tự SCR-L17 nhưng badge màu `#EC4899` (Pink) cho type InClass.

| **File** | `screens/learner/activities/in_class/in_class_list_screen.dart` |
|----------|----------------------------------------------------------------|
| **Route** | `/learning-paths/:pathId/in-class` |
| **Status** | ❌ Chưa implement |

---

### SCR-L21 · Activity Detail (In-Class)

Tương tự SCR-L18. File: `in_class_detail_screen.dart`

---

### SCR-L22 · Submit Activity Evidence (In-Class)

Tương tự SCR-L19. File: `screens/learner/activities/in_class/submit_evidence_screen.dart`

---

## 1.8 Post-Class Activities

### SCR-L23 · Post-Class Activities List

Tương tự SCR-L17 nhưng badge màu `#F97316` (Orange) cho type PostClass.

| **File** | `screens/learner/activities/post_class/post_class_list_screen.dart` |
|----------|---------------------------------------------------------------------|
| **Status** | ❌ Chưa implement |

---

### SCR-L24 · Activity Detail (Post-Class)

Tương tự SCR-L18. File: `post_class_detail_screen.dart`

---

### SCR-L25 · Submit Reflection / Evidence (Post-Class)

Tương tự SCR-L19 nhưng label "Reflection" thay vì "Bằng chứng".
File: `screens/learner/activities/post_class/submit_reflection_screen.dart`

---

## 1.9 Projects & Milestones

---

### SCR-L26 · Project List

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/projects/project_list_screen.dart` |
| **Route** | `/classes/:classId/projects` |
| **API** | `GET /api/projects/:classId` |
| **Status** | ❌ Chưa implement |

**Layout**: List cards — Project title + số milestone + deadline gần nhất

---

### SCR-L27 · Project Detail

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/projects/project_detail_screen.dart` |
| **Route** | `/projects/:projectId` |
| **API** | `GET /api/projects/{id}` |
| **Status** | ❌ Chưa implement |

**Layout**: Title + Description + Milestone timeline (4 milestones dạng stepper)

---

### SCR-L28 · Milestone List

| **File** | `screens/learner/projects/milestone_list_screen.dart` |
|----------|----------------------------------------------------|
| **Route** | `/projects/:projectId/milestones` |
| **Status** | ❌ Chưa implement |

---

### SCR-L29 · Milestone Detail

| **File** | `screens/learner/projects/milestone_detail_screen.dart` |
|----------|---------------------------------------------------------|
| **Route** | `/milestones/:milestoneId` |
| **Status** | ❌ Chưa implement |

**Layout**: Title + Description + DueDate + Submission status + Nút "Nộp"

---

### SCR-L30 · Submit Milestone

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/projects/submit_milestone_screen.dart` |
| **Route** | `/milestones/:milestoneId/submit` |
| **API** | `POST /api/milestone-submissions` |
| **Status** | ❌ Chưa implement |

Tương tự SCR-L19 với thêm field "Mô tả báo cáo"

---

## 1.10 Review & Critique

---

### SCR-L31 · Review Sessions

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/review/review_sessions_screen.dart` |
| **Route** | `/classes/:classId/reviews` |
| **API** | `GET /api/review-sessions/:classId` |
| **Status** | ❌ Chưa implement |

**Layout**: List ReviewSession cards — Title + Start/End date + status (Open/Closed)

---

### SCR-L32 · Review Detail

| **File** | `screens/learner/review/review_detail_screen.dart` |
|----------|--------------------------------------------------|
| **Route** | `/review-sessions/:sessionId` |
| **Status** | ❌ Chưa implement |

**Layout**: Session info + danh sách bạn cần review + danh sách received feedback

---

### SCR-L33 · Submit Feedback

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/review/submit_feedback_screen.dart` |
| **Route** | `/review-assignments/:assignmentId/feedback` |
| **API** | `POST /api/feedbacks` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Đánh giá: Phạm Thị Lan    │
│                              │
│  Nhận xét *                  │
│  ┌────────────────────────┐  │
│  │ Nhập nhận xét...       │  │  6 lines
│  └────────────────────────┘  │
│                              │
│  Điểm đánh giá               │
│  ★ ★ ★ ★ ☆  (4/5)           │  RatingBar widget
│                              │
│  ┌────────────────────────┐  │
│  │    GỬI ĐÁNH GIÁ        │  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

---

### SCR-L34 · Received Feedback

| **File** | `screens/learner/review/received_feedback_screen.dart` |
|----------|------------------------------------------------------|
| **Route** | `/review-sessions/:sessionId/received` |
| **API** | `GET /api/feedbacks/received/:assignmentId` |
| **Status** | ❌ Chưa implement |

**Layout**: List feedback cards — Avatar reviewer + Rating ★ + Content + timestamp

---

## 1.11 Evidence & Comments

---

### SCR-L35 · Evidence Detail

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/evidence/evidence_detail_screen.dart` |
| **Route** | `/evidences/:submissionId` |
| **API** | `GET /api/evidences/{id}` |
| **Status** | ❌ Chưa implement |

**Layout**: File preview + Note + Status badge + ReviewedAt + Comment button

---

### SCR-L36 · Evidence Comments

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/evidence/evidence_comments_screen.dart` |
| **Route** | `/evidences/:submissionId/comments` |
| **API** | `GET /api/evidences/{id}/comments`, `POST /api/evidences/{id}/comments` |
| **Status** | ❌ Chưa implement |

**Layout**: Chat-style comment list + text input ở bottom

---

## 1.12 Learning Progress

---

### SCR-L37 · Learning Progress

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/progress/progress_screen.dart` |
| **Route** | `/progress` (Tab 3 BottomNav) |
| **API** | `GET /api/analytics/my-progress` |
| **Package** | `fl_chart` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Tiến độ học tập            │
├──────────────────────────────┤
│  Tổng quan                   │
│  ┌────────────────────────┐  │
│  │  [Donut Chart 160px]   │  │  fl_chart
│  │       75%              │  │
│  │   Hoàn thành           │  │
│  └────────────────────────┘  │
│                              │
│  Chi tiết theo tuần          │
│  W1  ████████████  100%      │
│  W2  ████████░░░░   75%      │
│  W3  ████░░░░░░░░   40%      │
│                              │
│  Tổng kết                    │
│  ✅ Đã hoàn thành      18    │
│  ⏳ Đang chờ duyệt      4    │
│  ❌ Chưa nộp            2    │
└──────────────────────────────┘
```

---

### SCR-L38 · Activity Completion

| **File** | `screens/learner/progress/activity_completion_screen.dart` |
|----------|----------------------------------------------------------|
| **Route** | `/progress/activities` |
| **Status** | ❌ Chưa implement |

**Layout**: List tất cả activities + status + deadline (filter: All/Done/Pending/Missed)

---

### SCR-L39 · Project Progress

| **File** | `screens/learner/progress/project_progress_screen.dart` |
|----------|---------------------------------------------------------|
| **Status** | ❌ Chưa implement |

**Layout**: Stepper hiển thị 4 milestones với trạng thái

---

## 1.13 Profile

---

### SCR-L40 · Profile

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/learner/profile/profile_screen.dart` |
| **Route** | `/profile` (Tab 4 BottomNav) |
| **API** | `GET /api/users/me` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│  Hồ sơ cá nhân               │
│                              │
│      [Avatar 80px]           │
│   Lê Văn Minh           18sp │
│   learner1@student.edu.vn    │
│                              │
│  ┌──────────┬─────────────┐  │
│  │    3     │     22      │  │  Stat cards
│  │ Khóa học │HĐ hoàn thành│  │
│  └──────────┴─────────────┘  │
│                              │
│  ┌──────────────────────┐    │
│  │ ✏️  Chỉnh sửa hồ sơ  │    │  ListTile
│  └──────────────────────┘    │
│  ┌──────────────────────┐    │
│  │ 🔑  Đổi mật khẩu     │    │
│  └──────────────────────┘    │
│  ┌──────────────────────┐    │
│  │ 🚪  Đăng xuất        │    │  text: error color
│  └──────────────────────┘    │
└──────────────────────────────┘
```

---

### SCR-L41 · Edit Profile

| **File** | `screens/learner/profile/edit_profile_screen.dart` |
|----------|--------------------------------------------------|
| **Route** | `/profile/edit` |
| **API** | `PUT /api/users/me` |
| **Status** | ❌ Chưa implement |

**Layout**: Avatar picker + FullName field + Save button

---

---

# Part 2 — Instructor App

## 2.1 Dashboard

---

### SCR-I01 · Instructor Dashboard

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/instructor/dashboard/dashboard_screen.dart` |
| **Route** | `/instructor/dashboard` (Tab 1 BottomNav) |
| **API** | `GET /api/courses/my`, `GET /api/evidences/pending-count` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ Xin chào, GV Bình! 👋   🔔  │  bg=primary, white
├──────────────────────────────┤
│  Thống kê nhanh              │
│  ┌──────┬──────┬──────────┐  │
│  │  3   │  12  │    5     │  │
│  │ Lớp  │Evid. │ Review   │  │  3 stat cards
│  │đạydạy│chờ duyệt│ chờ  │  │
│  └──────┴──────┴──────────┘  │
│                              │
│  Lớp đang dạy                │
│  ┌──────────────────────────┐│
│  │ PRM393 - SE1801          ││
│  │ 32 học viên · 8 tuần    ││
│  └──────────────────────────┘│
│                              │
│  Evidence cần duyệt   Xem ► │
│  ┌──────────────────────────┐│
│  │[Avatar] Lê Văn Minh      ││
│  │ Tuần 3 Pre-Class    08:30││  [Pending]
│  └──────────────────────────┘│
├──────────────────────────────┤
│ 📊  📚  ✅  📈               │  Instructor BottomNav
└──────────────────────────────┘
```

---

## 2.2 Course Management

---

### SCR-I02 · Manage Courses

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/instructor/courses/manage_courses_screen.dart` |
| **Route** | `/instructor/courses` (Tab 2) |
| **API** | `GET /api/courses/my` |
| **Status** | ❌ Chưa implement |

**Layout**: List CourseCard + FAB (+) → tạo course mới

---

### SCR-I03 · Create / Edit Course

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/instructor/courses/create_edit_course_screen.dart` |
| **Route** | `/instructor/courses/new`, `/instructor/courses/:id/edit` |
| **API** | `POST /api/courses`, `PUT /api/courses/{id}` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Tạo khóa học mới           │
│                              │
│ ┌──────────────────────────┐ │
│ │                          │ │
│ │  + Chọn ảnh bìa          │ │  ImagePicker, height 200
│ │  (dashed border)         │ │
│ └──────────────────────────┘ │
│                              │
│ Tên khóa học *               │
│ ┌──────────────────────────┐ │
│ └──────────────────────────┘ │
│ Mô tả                        │
│ ┌──────────────────────────┐ │
│ │                          │ │  5 lines
│ └──────────────────────────┘ │
│                              │
│ ┌──────────────────────────┐ │
│ │            LƯU           │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

---

## 2.3 Class Management

---

### SCR-I04 · Manage Classes

| **File** | `screens/instructor/classes/manage_classes_screen.dart` |
|----------|-------------------------------------------------------|
| **API** | `GET /api/classes?courseId=x` |
| **Status** | ❌ Chưa implement |

**Layout**: List class cards + FAB → tạo lớp mới (chọn Course, tên lớp, ngày bắt đầu/kết thúc)

---

### SCR-I05 · Class Members

| **File** | `screens/instructor/classes/class_members_screen.dart` |
|----------|------------------------------------------------------|
| **API** | `GET /api/classes/{id}/members` |
| **Status** | ❌ Chưa implement |

**Layout**: List members + nút "Thêm học viên" (nhập email)

---

## 2.4 Learning Path Management

---

### SCR-I06 · Learning Path List

| **File** | `screens/instructor/learning_path/learning_path_list_screen.dart` |
|----------|------------------------------------------------------------------|
| **API** | `GET /api/learning-paths/:classId` |
| **Status** | ❌ Chưa implement |

**Layout**: List tuần học + FAB → thêm tuần mới

---

### SCR-I07 · Create / Edit Learning Path

| **File** | `screens/instructor/learning_path/create_edit_path_screen.dart` |
|----------|----------------------------------------------------------------|
| **API** | `POST /api/learning-paths`, `PUT /api/learning-paths/{id}` |
| **Status** | ❌ Chưa implement |

**Layout**: Title field + WeekNumber field + Lưu

---

## 2.5 Material Management

---

### SCR-I08 · Manage Materials

| **File** | `screens/instructor/materials/manage_materials_screen.dart` |
|----------|-----------------------------------------------------------|
| **API** | `GET /api/materials/:pathId` |
| **Status** | ❌ Chưa implement |

**Layout**: List materials + FAB → upload mới. Swipe to delete.

---

### SCR-I09 · Upload Material

| **File** | `screens/instructor/materials/upload_material_screen.dart` |
|----------|------------------------------------------------------------|
| **API** | `POST /api/materials` (multipart) |
| **Status** | ❌ Chưa implement |

**Layout**: Title + Type selector (Video/Document/Link) + File picker / URL field + Lưu

---

## 2.6 Activity Management

---

### SCR-I10 · Manage Activities

| **File** | `screens/instructor/activities/manage_activities_screen.dart` |
|----------|--------------------------------------------------------------|
| **API** | `GET /api/activities/:pathId` |
| **Status** | ❌ Chưa implement |

**Layout**: Grouped by type (Pre/In/Post) + FAB → tạo activity mới

---

### SCR-I11 · Create / Edit Activity

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/instructor/activities/create_edit_activity_screen.dart` |
| **API** | `POST /api/activities`, `PUT /api/activities/{id}` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Tạo hoạt động             │
│                              │
│ Tên hoạt động *              │
│ ┌──────────────────────────┐ │
│ └──────────────────────────┘ │
│ Loại hoạt động *             │
│ ○ Pre-Class                  │  RadioButton
│ ○ In-Class                   │
│ ○ Post-Class                 │
│ Mô tả                        │
│ ┌──────────────────────────┐ │
│ │                          │ │  5 lines
│ └──────────────────────────┘ │
│ Deadline                     │
│ ┌──────────────────────────┐ │
│ │ 10/06/2026 23:59     📅 │ │  DateTimePicker
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │            LƯU           │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

---

## 2.7 Project Management

---

### SCR-I12 · Manage Projects

| **File** | `screens/instructor/projects/manage_projects_screen.dart` |
|----------|----------------------------------------------------------|
| **API** | `GET /api/projects/:classId` |
| **Status** | ❌ Chưa implement |

---

### SCR-I13 · Create / Edit Project

| **File** | `screens/instructor/projects/create_edit_project_screen.dart` |
|----------|--------------------------------------------------------------|
| **API** | `POST /api/projects`, `PUT /api/projects/{id}` |
| **Status** | ❌ Chưa implement |

**Layout**: Title + Description + Lưu

---

### SCR-I14 · Manage Milestones

| **File** | `screens/instructor/projects/manage_milestones_screen.dart` |
|----------|-------------------------------------------------------------|
| **API** | `GET /api/milestones/:projectId`, `POST`, `PUT`, `DELETE` |
| **Status** | ❌ Chưa implement |

**Layout**: List milestones + DueDate + FAB + Swipe to edit/delete

---

## 2.8 Review Management

---

### SCR-I15 · Review Sessions

| **File** | `screens/instructor/review/review_sessions_screen.dart` |
|----------|--------------------------------------------------------|
| **API** | `GET /api/review-sessions/:classId` |
| **Status** | ❌ Chưa implement |

**Layout**: List sessions + FAB → tạo phiên review mới (Title + StartDate + EndDate + auto-assign)

---

### SCR-I16 · Review Monitoring

| **File** | `screens/instructor/review/review_monitoring_screen.dart` |
|----------|----------------------------------------------------------|
| **API** | `GET /api/review-assignments/:sessionId`, `PUT /api/review-assignments/{id}/reassign` |
| **Status** | ❌ Chưa implement |

**Layout**: List assignments — Reviewer → Reviewee + Feedback status (Done/Pending) + Nút "Re-assign" hoặc "Chấm thay (Override)" cho Instructor nếu Reviewer không hoàn thành.

---

## 2.9 Evidence Review

---

### SCR-I17 · Evidence List

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/instructor/evidence_review/evidence_list_screen.dart` |
| **Route** | `/instructor/evidence` (Tab 3) |
| **API** | `GET /api/evidences?classId=x&status=Pending` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Evidence cần duyệt         │
│ [All][Pending][Approved][Rejected]  Filter chips
├──────────────────────────────┤
│ ┌──────────────────────────┐ │
│ │[Av] Lê Văn Minh          │ │
│ │ Tuần 3 · Pre-Class       │ │
│ │ Nộp: 08/06 · 08:30       │ │
│ │                [Pending] │ │
│ └──────────────────────────┘ │
│ ┌──────────────────────────┐ │
│ │[Av] Phạm Thị Lan         │ │
│ │ Tuần 3 · In-Class        │ │
│ │ Nộp: 08/06 · 14:15       │ │
│ │                [Pending] │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

---

### SCR-I18 · Evidence Detail (Instructor)

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/instructor/evidence_review/evidence_detail_screen.dart` |
| **Route** | `/instructor/evidence/:submissionId` |
| **API** | `GET /api/evidences/{id}`, `PUT /api/evidences/{id}/approve`, `PUT /api/evidences/{id}/reject` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Chi tiết Evidence          │
│                              │
│ [Preview Image / PDF 200px]  │
│                              │
│ Lê Văn Minh             16sp │
│ Tuần 3 · Pre-Class      14sp │
│ Nộp: 08/06/2026 · 08:30 12sp│
│                              │
│ Ghi chú của học viên:        │
│ "Em đã xem video và hoàn..." │  Card bg=#F8FAFC
│                              │
│ ┌───────────┐ ┌───────────┐  │
│ │ ✅APPROVE │ │ ❌REJECT  │  │  2 buttons side by side
│ └───────────┘ └───────────┘  │
│ ┌──────────────────────────┐ │
│ │  💬 Xem bình luận (3)    │ │  Secondary btn
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

---

### SCR-I19 · Comment & Feedback

| **File** | `screens/instructor/evidence_review/comment_screen.dart` |
|----------|--------------------------------------------------------|
| **API** | `GET/POST /api/evidences/{id}/comments` |
| **Status** | ❌ Chưa implement |

**Layout**: Chat-style comments + text input + Gửi button

---

## 2.10 Analytics

---

### SCR-I20 · Learning Analytics

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/instructor/analytics/analytics_screen.dart` |
| **Route** | `/instructor/analytics` (Tab 4) |
| **API** | `GET /api/analytics/class/:classId` |
| **Package** | `fl_chart` |
| **Status** | ❌ Chưa implement |

**Layout**:
```
┌──────────────────────────────┐
│ ← Thống kê học tập           │
│  PRM393 · SE1801        14sp │
├──────────────────────────────┤
│  Tỷ lệ hoàn thành            │
│  ┌────────────────────────┐  │
│  │  [Donut Chart 150px]   │  │  68% overall
│  └────────────────────────┘  │
│                              │
│  Tiến độ theo tuần           │
│  ┌────────────────────────┐  │
│  │  [Bar Chart 200px]     │  │
│  │  W1  W2  W3  W4  W5    │  │
│  └────────────────────────┘  │
│                              │
│  Học viên tích cực nhất      │
│  🥇 Lê Văn Minh    22/24     │
│  🥈 Phạm Thị Lan   20/24     │
│  🥉 Hoàng Văn Hùng 18/24     │
└──────────────────────────────┘
```

---

### SCR-I21 · Student Progress Analytics

| **File** | `screens/instructor/analytics/student_progress_screen.dart` |
|----------|-------------------------------------------------------------|
| **Route** | `/instructor/analytics/student/:userId` |
| **API** | `GET /api/analytics/student/:userId?classId=x` |
| **Status** | ❌ Chưa implement |

**Layout**: Avatar + tên + Donut chart tiến độ + Danh sách activity status theo tuần

---

## 2.11 Profile

---

### SCR-I22 · Profile

| Thuộc tính | Giá trị |
|------------|---------|
| **File** | `screens/instructor/profile/profile_screen.dart` |
| **Route** | `/instructor/profile` (Tab 5 BottomNav) |
| **API** | `GET /api/users/me` |
| **Status** | ❌ Chưa implement |

**Layout**: Tương tự SCR-L40 Profile của Learner nhưng hiển thị badge "Giảng viên" và thông số lớp đang dạy.

---

### SCR-I23 · Edit Profile

| **File** | `screens/instructor/profile/edit_profile_screen.dart` |
|----------|--------------------------------------------------|
| **Route** | `/instructor/profile/edit` |
| **API** | `PUT /api/users/me` |
| **Status** | ❌ Chưa implement |

**Layout**: Tương tự SCR-L41 Edit Profile.

---

---

# Navigation Flow

## Learner Flow

```
/splash
  ├── /login
  │    └── /register
  └── /home  (BottomNav Tab 1)
       ├── /notifications
       ├── /courses  (BottomNav Tab 2)
       │    └── /courses/:id  (Course Detail)
       │         └── /classes/:id  (Class Detail)
       │              ├── /members
       │              ├── /learning-paths
       │              │    └── /learning-paths/:pathId
       │              │         ├── /materials
       │              │         │    └── /materials/:id
       │              │         ├── /pre-class
       │              │         │    └── /activities/:id
       │              │         │         ├── /submit
       │              │         │         └── /comments
       │              │         ├── /in-class (tương tự)
       │              │         └── /post-class (tương tự)
       │              ├── /projects
       │              │    └── /projects/:id → /milestones
       │              └── /reviews
       │                   └── /review-sessions/:id
       ├── /progress  (BottomNav Tab 3)
       └── /profile  (BottomNav Tab 4)
            └── /profile/edit
```

## Instructor Flow

```
/instructor/dashboard  (BottomNav Tab 1)
├── /instructor/courses  (BottomNav Tab 2)
│    └── /instructor/courses/:id/edit
│         ├── /classes → /classes/:id
│         │    ├── /members
│         │    ├── /learning-path
│         │    │    ├── /materials → upload
│         │    │    └── /activities → create/edit
│         │    ├── /projects → milestones
│         │    └── /reviews → monitoring
├── /instructor/evidence  (BottomNav Tab 3)
│    └── /instructor/evidence/:id → comments
└── /instructor/analytics  (BottomNav Tab 4)
     └── /instructor/analytics/student/:userId
```

---

## Screen Count Summary

| Category | Count | Status |
|----------|-------|--------|
| Auth (Learner) | 4 | 2✅ 2❌ |
| Dashboard (Learner) | 2 | 0✅ 2❌ |
| Course & Class | 4 | 0✅ 4❌ |
| Learning Path | 2 | 0✅ 2❌ |
| Materials | 4 | 0✅ 4❌ |
| Pre-Class Activities | 3 | 0✅ 3❌ |
| In-Class Activities | 3 | 0✅ 3❌ |
| Post-Class Activities | 3 | 0✅ 3❌ |
| Projects & Milestones | 5 | 0✅ 5❌ |
| Review & Critique | 4 | 0✅ 4❌ |
| Evidence & Comments | 2 | 0✅ 2❌ |
| Progress | 3 | 0✅ 3❌ |
| Profile | 2 | 0✅ 2❌ |
| **Learner Total** | **41** | **2✅ 39❌** |
| Instructor Dashboard | 1 | 0✅ 1❌ |
| Course Management | 2 | 0✅ 2❌ |
| Class Management | 2 | 0✅ 2❌ |
| Learning Path Mgmt | 2 | 0✅ 2❌ |
| Material Management | 2 | 0✅ 2❌ |
| Activity Management | 2 | 0✅ 2❌ |
| Project Management | 3 | 0✅ 3❌ |
| Review Management | 2 | 0✅ 2❌ |
| Evidence Review | 3 | 0✅ 3❌ |
| Analytics | 2 | 0✅ 2❌ |
| Profile | 2 | 0✅ 2❌ |
| **Instructor Total** | **23** | **0✅ 23❌** |
| **GRAND TOTAL** | **64** | **2✅ 62❌** |
