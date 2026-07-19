# TECHNICAL SPECIFICATION — FLIPPED CLASSROOM MOBILE APP

> **Version**: 1.0 | **Date**: 2026-06-07  
> **Platform**: Flutter Mobile (Android & iOS)  
> **Status**: Draft

---

## Table of Contents

1. [Context & Goal](#1-context--goal)
2. [Actors & Roles](#2-actors--roles)
3. [Functional Requirements](#3-functional-requirements)
4. [Non-Functional Requirements](#4-non-functional-requirements)
5. [Data Model](#5-data-model)
6. [Error Handling](#6-error-handling)
7. [Acceptance Criteria](#7-acceptance-criteria)
8. [Out of Scope](#8-out-of-scope)

---

## 1. Context & Goal

### Background

Mô hình **Flipped Classroom** (lớp học đảo ngược) đảo ngược quy trình học truyền thống:
- **Truyền thống**: Giảng bài trên lớp → bài tập về nhà
- **Flipped**: Xem tài liệu/video ở nhà **(Pre-Class)** → thực hành, thảo luận trên lớp **(In-Class)** → consolidation sau giờ học **(Post-Class)**

### Problem Statement

Hiện tại, việc quản lý tài liệu, hoạt động và theo dõi tiến độ học tập của mô hình Flipped Classroom được thực hiện rời rạc qua nhiều công cụ khác nhau (email, Google Drive, Excel), gây khó khăn cho cả giảng viên và học viên trong việc phối hợp và theo dõi.

### Goal

Xây dựng một ứng dụng mobile tập trung, cho phép:
- **Giảng viên (Instructor)** tổ chức khóa học, giao tài liệu, quản lý hoạt động và theo dõi tiến độ học viên
- **Học viên (Learner)** truy cập tài liệu, nộp bằng chứng hoàn thành, nhận phản hồi và theo dõi tiến độ cá nhân

### Success Metrics

| Metric | Target |
|--------|--------|
| Tỷ lệ học viên hoàn thành Pre-Class | ≥ 80% |
| Thời gian Instructor review evidence | < 24 giờ |
| Tỷ lệ peer review hoàn thành đúng hạn | ≥ 90% |
| Thời gian tải màn hình chính | < 2 giây |

---

## 2. Actors & Roles

### 2.1 Learner (Học viên)

| Thuộc tính | Mô tả |
|-----------|-------|
| **Định nghĩa** | Người tham gia khóa học, được Instructor thêm vào lớp |
| **Mục tiêu** | Hoàn thành các hoạt động học tập, nộp evidence, nhận feedback |
| **Điều kiện** | Có tài khoản hệ thống, được gán vào ít nhất 1 Class |

**Quyền hạn:**
- ✅ Xem tài liệu học tập (video, PDF, link)
- ✅ Nộp evidence cho Pre/In/Post-class activities
- ✅ Xem và bình luận evidence
- ✅ Nộp Milestone của Project
- ✅ Review và gửi feedback peer (trong Review Sessions)
- ✅ Xem tiến độ học tập cá nhân
- ✅ Chỉnh sửa thông tin cá nhân
- ❌ Không thể tạo/sửa Course, Class, Activity, Material

---

### 2.2 Instructor (Giảng viên)

| Thuộc tính | Mô tả |
|-----------|-------|
| **Định nghĩa** | Người tạo và quản lý khóa học, giao nội dung học tập |
| **Mục tiêu** | Tổ chức nội dung, theo dõi và đánh giá học viên |
| **Điều kiện** | Có tài khoản hệ thống với role = Instructor |

**Quyền hạn:**
- ✅ CRUD Course, Class, Learning Path
- ✅ Upload tài liệu (video, PDF, link)
- ✅ Tạo/sửa/xóa Activity (Pre/In/Post-class)
- ✅ Tạo Project và Milestones
- ✅ Tạo Review Sessions và phân công peer review
- ✅ Review evidence của học viên (Approve / Reject)
- ✅ Bình luận và phản hồi trên evidence
- ✅ Xem analytics tiến độ lớp học và từng học viên
- ❌ Không thể xem evidence của lớp khác

---

## 3. Functional Requirements

### FR-01: Authentication

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01.1 | Học viên và Giảng viên có thể đăng ký tài khoản bằng email + mật khẩu | High |
| FR-01.2 | Người dùng có thể đăng nhập và nhận JWT token | High |
| FR-01.3 | App tự động duy trì đăng nhập khi còn token hợp lệ | High |
| FR-01.4 | Người dùng có thể đăng xuất | High |
| FR-01.5 | Người dùng có thể yêu cầu đặt lại mật khẩu qua email | Medium |
| FR-01.6 | Hệ thống tự động điều hướng theo role sau khi đăng nhập | High |

---

### FR-02: Course & Class Management

| ID | Requirement | Actor | Priority |
|----|-------------|-------|----------|
| FR-02.1 | Instructor tạo, sửa, xóa Course | Instructor | High |
| FR-02.2 | Instructor tạo Class trong Course, gán ngày bắt đầu/kết thúc | Instructor | High |
| FR-02.3 | Instructor thêm/xóa Learner vào Class bằng email | Instructor | High |
| FR-02.4 | Learner xem danh sách Class đã tham gia | Learner | High |
| FR-02.5 | Learner xem danh sách thành viên trong Class | Learner | Medium |

---

### FR-03: Learning Path & Materials

| ID | Requirement | Actor | Priority |
|----|-------------|-------|----------|
| FR-03.1 | Instructor tạo Learning Path theo tuần cho mỗi Class | Instructor | High |
| FR-03.2 | Instructor upload tài liệu: Video, PDF, Link vào Learning Path | Instructor | High |
| FR-03.3 | Learner xem danh sách tài liệu theo từng tuần | Learner | High |
| FR-03.4 | Learner phát video học tập trực tiếp trong app | Learner | High |
| FR-03.5 | Learner đọc file PDF trong app | Learner | High |

---

### FR-04: Activities (Pre / In / Post-Class)

| ID | Requirement | Actor | Priority |
|----|-------------|-------|----------|
| FR-04.1 | Instructor tạo activity, gán loại (Pre/In/Post-class), deadline | Instructor | High |
| FR-04.2 | Learner xem danh sách activity theo loại | Learner | High |
| FR-04.3 | Learner xem hướng dẫn chi tiết từng activity | Learner | High |
| FR-04.4 | Learner nộp evidence (file ảnh/PDF/video ngắn + ghi chú) | Learner | High |
| FR-04.5 | Instructor xem danh sách evidence theo lớp, lọc theo trạng thái | Instructor | High |
| FR-04.6 | Instructor Approve hoặc Reject evidence | Instructor | High |
| FR-04.7 | Learner xem trạng thái evidence đã nộp (Pending / Approved / Rejected) | Learner | High |
| FR-04.8 | Cả Learner và Instructor có thể bình luận trên evidence | Both | Medium |

---

### FR-05: Projects & Milestones

| ID | Requirement | Actor | Priority |
|----|-------------|-------|----------|
| FR-05.1 | Instructor tạo Project, gán cho Class | Instructor | High |
| FR-05.2 | Instructor tạo Milestones cho Project với deadline | Instructor | High |
| FR-05.3 | Learner xem danh sách Project và Milestones | Learner | High |
| FR-05.4 | Learner nộp deliverable cho từng Milestone (file + mô tả) | Learner | High |
| FR-05.5 | Learner theo dõi tiến độ hoàn thành Project | Learner | Medium |

---

### FR-06: Review & Peer Feedback

| ID | Requirement | Actor | Priority |
|----|-------------|-------|----------|
| FR-06.1 | Instructor tạo Review Session, gán thời gian bắt đầu/kết thúc | Instructor | High |
| FR-06.2 | Hệ thống tự động hoặc Instructor phân công Learner review lẫn nhau | Instructor | High |
| FR-06.3 | Learner xem danh sách bạn cần review | Learner | High |
| FR-06.4 | Learner xem evidence của người được review và gửi feedback (rating + comment) | Learner | High |
| FR-06.5 | Learner xem feedback nhận được từ bạn | Learner | High |
| FR-06.6 | Instructor theo dõi trạng thái peer review của từng học viên | Instructor | Medium |

---

### FR-07: Learning Progress & Analytics

| ID | Requirement | Actor | Priority |
|----|-------------|-------|----------|
| FR-07.1 | Learner xem % tiến độ hoàn thành hoạt động tổng thể | Learner | High |
| FR-07.2 | Learner xem trạng thái hoàn thành từng activity | Learner | High |
| FR-07.3 | Learner xem tiến độ từng Milestone của Project | Learner | Medium |
| FR-07.4 | Instructor xem thống kê lớp: tỷ lệ hoàn thành, biểu đồ tiến độ | Instructor | High |
| FR-07.5 | Instructor xem tiến độ chi tiết từng học viên | Instructor | Medium |

---

### FR-08: Notifications

| ID | Requirement | Actor | Priority |
|----|-------------|-------|----------|
| FR-08.1 | Learner nhận thông báo khi có activity mới | Learner | Medium |
| FR-08.2 | Learner nhận thông báo khi evidence được Approve/Reject | Learner | High |
| FR-08.3 | Learner nhận thông báo nhắc deadline activity/milestone | Learner | Medium |
| FR-08.4 | Người dùng có thể xem danh sách thông báo và đánh dấu đã đọc | Both | Medium |

---

### FR-09: Profile

| ID | Requirement | Actor | Priority |
|----|-------------|-------|----------|
| FR-09.1 | Người dùng xem thông tin cá nhân | Both | Medium |
| FR-09.2 | Người dùng cập nhật tên và ảnh đại diện | Both | Medium |

---

## 4. Non-Functional Requirements

### 4.1 Performance

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-P01 | Thời gian tải danh sách màn hình chính | < 2 giây |
| NFR-P02 | Thời gian phản hồi API | < 1 giây (95th percentile) |
| NFR-P03 | Thời gian upload file evidence (< 10MB) | < 5 giây |
| NFR-P04 | App không crash khi không có mạng | Phải hiện thông báo lỗi |

### 4.2 Security

| ID | Requirement |
|----|-------------|
| NFR-S01 | JWT token phải được lưu an toàn (`SharedPreferences` cho dev, `flutter_secure_storage` cho production) |
| NFR-S02 | Token hết hạn sau **60 phút**, Refresh token hết hạn sau **7 ngày** |
| NFR-S03 | Password phải được hash bằng **BCrypt** trước khi lưu vào DB |
| NFR-S04 | Tất cả API (trừ auth) phải yêu cầu JWT hợp lệ trong header |
| NFR-S05 | Instructor chỉ có thể xem/chỉnh sửa dữ liệu của lớp mình quản lý |
| NFR-S06 | Learner chỉ có thể xem evidence của chính mình (trừ khi là reviewer) |

### 4.3 Usability

| ID | Requirement |
|----|-------------|
| NFR-U01 | App hỗ trợ **Android** (API 21+) và **iOS** (12+) |
| NFR-U02 | Giao diện phải responsive trên màn hình 5" đến 6.7" |
| NFR-U03 | Tất cả form phải có validation với thông báo lỗi rõ ràng bằng tiếng Việt |
| NFR-U04 | Mọi thao tác async phải hiển thị loading indicator |
| NFR-U05 | Màn hình lỗi phải có nút "Thử lại" |

### 4.4 Reliability

| ID | Requirement |
|----|-------------|
| NFR-R01 | App phải hoạt động offline ở mức tối thiểu (hiển thị dữ liệu đã cache) |
| NFR-R02 | API uptime ≥ 99% trong giờ học (7:00 – 22:00) |
| NFR-R03 | Dữ liệu người dùng không bị mất khi app bị kill process |

### 4.5 Scalability

| ID | Requirement |
|----|-------------|
| NFR-SC01 | Hệ thống hỗ trợ đồng thời tối thiểu **200 users** |
| NFR-SC02 | Mỗi file upload tối đa **50MB** |
| NFR-SC03 | Database có thể scale horizontal khi cần |

---

## 5. Data Model

### 5.1 Entity Relationship Overview

```
User (1) ──────────────── (*) Course          [Instructor creates]
User (*) ──────────────── (*) Class            [via ClassMember]
Course (1) ─────────────── (*) Class
Class (1) ──────────────── (*) LearningPath
LearningPath (1) ────────── (*) LearningMaterial
LearningPath (1) ────────── (*) Activity
Activity (1) ────────────── (*) ActivitySubmission   [Learner submits]
ActivitySubmission (1) ───── (*) EvidenceComment
Class (1) ──────────────── (*) Project
Project (1) ─────────────── (*) Milestone
Milestone (1) ───────────── (*) MilestoneSubmission  [Learner submits]
Class (1) ──────────────── (*) ReviewSession
ReviewSession (1) ────────── (*) ReviewAssignment
ReviewAssignment (1) ─────── (*) Feedback
User (1) ──────────────── (*) Notification
```

### 5.2 Core Entities

#### User
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| Email | nvarchar(255) | UNIQUE, NOT NULL | |
| PasswordHash | nvarchar(500) | NOT NULL | BCrypt hash |
| FullName | nvarchar(100) | NOT NULL | |
| AvatarUrl | nvarchar(500) | NULL | |
| Role | int | NOT NULL | 0=Learner, 1=Instructor |
| CreatedAt | datetime | NOT NULL | |

#### Course
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| Title | nvarchar(200) | NOT NULL | |
| Description | nvarchar(2000) | NULL | |
| CoverImageUrl | nvarchar(500) | NULL | |
| InstructorId | int | FK → User | |
| CreatedAt | datetime | NOT NULL | |

#### Class
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| CourseId | int | FK → Course | |
| Name | nvarchar(100) | NOT NULL | |
| StartDate | datetime | NOT NULL | |
| EndDate | datetime | NOT NULL | |

#### ClassMember
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| ClassId | int | FK → Class | |
| UserId | int | FK → User | |
| JoinedAt | datetime | NOT NULL | |

#### LearningPath
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| ClassId | int | FK → Class | |
| Title | nvarchar(200) | NOT NULL | |
| WeekNumber | int | NOT NULL | |

#### LearningMaterial
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| LearningPathId | int | FK → LearningPath | |
| Title | nvarchar(200) | NOT NULL | |
| Type | int | NOT NULL | 0=Video, 1=Document, 2=Link |
| FileUrl | nvarchar(500) | NULL | |
| LinkUrl | nvarchar(500) | NULL | |

#### Activity
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| LearningPathId | int | FK → LearningPath | |
| Title | nvarchar(200) | NOT NULL | |
| Description | nvarchar(3000) | NULL | |
| Type | int | NOT NULL | 0=PreClass, 1=InClass, 2=PostClass |
| Deadline | datetime | NULL | |

#### ActivitySubmission (Evidence)
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| ActivityId | int | FK → Activity | |
| UserId | int | FK → User | |
| FileUrl | nvarchar(500) | NULL | |
| Note | nvarchar(2000) | NULL | |
| Status | int | NOT NULL | 0=Pending, 1=Approved, 2=Rejected |
| SubmittedAt | datetime | NOT NULL | |
| ReviewedAt | datetime | NULL | |

#### EvidenceComment
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| SubmissionId | int | FK → ActivitySubmission | |
| UserId | int | FK → User | |
| Content | nvarchar(1000) | NOT NULL | |
| CreatedAt | datetime | NOT NULL | |

#### Project
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| ClassId | int | FK → Class | |
| Title | nvarchar(200) | NOT NULL | |
| Description | nvarchar(3000) | NULL | |

#### Milestone
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| ProjectId | int | FK → Project | |
| Title | nvarchar(200) | NOT NULL | |
| Description | nvarchar(2000) | NULL | |
| DueDate | datetime | NOT NULL | |

#### MilestoneSubmission
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| MilestoneId | int | FK → Milestone | |
| UserId | int | FK → User | |
| FileUrl | nvarchar(500) | NULL | |
| Description | nvarchar(2000) | NULL | |
| SubmittedAt | datetime | NOT NULL | |

#### ReviewSession
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| ClassId | int | FK → Class | |
| Title | nvarchar(200) | NOT NULL | |
| StartDate | datetime | NOT NULL | |
| EndDate | datetime | NOT NULL | |

#### ReviewAssignment
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| SessionId | int | FK → ReviewSession | |
| ReviewerId | int | FK → User | |
| RevieweeId | int | FK → User | |

#### Feedback
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| AssignmentId | int | FK → ReviewAssignment | |
| Content | nvarchar(2000) | NOT NULL | |
| Rating | int | NOT NULL | 1–5 |
| CreatedAt | datetime | NOT NULL | |

#### Notification
| Field | Type | Constraint | Mô tả |
|-------|------|------------|-------|
| Id | int | PK, Auto | |
| UserId | int | FK → User | |
| Title | nvarchar(200) | NOT NULL | |
| Body | nvarchar(500) | NOT NULL | |
| IsRead | bit | NOT NULL, Default=0 | |
| CreatedAt | datetime | NOT NULL | |

---

## 6. Error Handling

### 6.1 HTTP Error Codes

| HTTP Code | Tình huống | Thông báo hiển thị |
|-----------|------------|-------------------|
| 400 Bad Request | Dữ liệu gửi lên không hợp lệ | Thông báo cụ thể từ server (validation error) |
| 401 Unauthorized | Token hết hạn hoặc không hợp lệ | "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại." |
| 403 Forbidden | Không có quyền truy cập | "Bạn không có quyền thực hiện hành động này." |
| 404 Not Found | Tài nguyên không tồn tại | "Không tìm thấy dữ liệu yêu cầu." |
| 409 Conflict | Dữ liệu đã tồn tại (email trùng) | "Email này đã được sử dụng." |
| 413 Payload Too Large | File upload quá 50MB | "File quá lớn. Vui lòng chọn file dưới 50MB." |
| 500 Internal Server Error | Lỗi server | "Đã có lỗi xảy ra. Vui lòng thử lại sau." |

### 6.2 Network Errors

| Tình huống | Xử lý |
|------------|-------|
| Không có kết nối mạng | Hiển thị banner "Không có kết nối. Dữ liệu có thể chưa cập nhật." |
| Request timeout (> 15s) | Hiển thị dialog "Kết nối chậm. Vui lòng thử lại." + nút Retry |
| Server không phản hồi | Hiển thị `ErrorWidget` với nút "Thử lại" |

### 6.3 Form Validation Errors

| Field | Rule | Thông báo lỗi |
|-------|------|---------------|
| Email | Không rỗng + đúng format | "Vui lòng nhập email hợp lệ." |
| Password | Tối thiểu 6 ký tự | "Mật khẩu phải có ít nhất 6 ký tự." |
| Confirm Password | Khớp với Password | "Mật khẩu xác nhận không khớp." |
| Full Name | Không rỗng | "Vui lòng nhập họ và tên." |
| Rating (Feedback) | 1–5 | "Vui lòng chọn đánh giá từ 1 đến 5 sao." |
| File upload | < 50MB, đúng định dạng | "File không hợp lệ hoặc quá 50MB." |

### 6.4 Business Logic Errors

| Tình huống | Xử lý |
|------------|-------|
| Learner nộp evidence sau deadline | Cảnh báo "Đã quá hạn nộp." nhưng vẫn cho phép nộp (Instructor quyết định) |
| Learner đã nộp evidence, nộp lại | Cho phép nộp lại, ghi đè submission cũ |
| Reviewer tự review chính mình | Backend từ chối, hiển thị "Không thể tự review bản thân." |
| Upload file sai định dạng | "Chỉ chấp nhận file ảnh (JPG, PNG), PDF, và video (MP4, MOV)." |

### 6.5 Error Handling Strategy (Flutter)

```dart
// Mọi lời gọi service đều được bọc trong try-catch
try {
  final data = await service.fetchData();
  // success
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    // show timeout dialog
  } else if (e.response?.statusCode == 401) {
    // redirect to login
  } else {
    // show generic error
  }
} catch (e) {
  // show generic error
}
```

---

## 7. Acceptance Criteria

### AC-01: Authentication

| ID | Scenario | Expected Result |
|----|----------|-----------------|
| AC-01.1 | Learner đăng nhập với email/password đúng | Chuyển đến Home Dashboard, lưu token |
| AC-01.2 | Đăng nhập với password sai | Hiển thị "Email hoặc mật khẩu không đúng." |
| AC-01.3 | Đăng ký với email đã tồn tại | Hiển thị "Email này đã được sử dụng." |
| AC-01.4 | Mở app khi token còn hạn | Tự động chuyển đến Dashboard, không yêu cầu đăng nhập |
| AC-01.5 | Mở app khi token hết hạn | Chuyển về màn hình Login |
| AC-01.6 | Instructor đăng nhập | Chuyển đến Instructor Dashboard |

### AC-02: Evidence Submission

| ID | Scenario | Expected Result |
|----|----------|-----------------|
| AC-02.1 | Learner nộp evidence với file hợp lệ | Trạng thái chuyển sang "Pending", hiện thông báo thành công |
| AC-02.2 | Learner nộp file > 50MB | Hiển thị lỗi "File quá lớn" trước khi upload |
| AC-02.3 | Instructor Approve evidence | Trạng thái chuyển sang "Approved", Learner nhận thông báo |
| AC-02.4 | Instructor Reject evidence | Trạng thái chuyển sang "Rejected", Learner nhận thông báo |
| AC-02.5 | Learner xem evidence đã Rejected | Hiển thị trạng thái "Rejected" và comment của Instructor |

### AC-03: Learning Path & Materials

| ID | Scenario | Expected Result |
|----|----------|-----------------|
| AC-03.1 | Learner mở video | Video player khởi động, phát được bình thường |
| AC-03.2 | Learner mở PDF | PDF viewer hiển thị toàn bộ nội dung |
| AC-03.3 | Instructor upload tài liệu | Tài liệu xuất hiện trong Learning Path của lớp |
| AC-03.4 | Learner xem tuần chưa mở khóa | Hiển thị trạng thái "Locked" |

### AC-04: Peer Review

| ID | Scenario | Expected Result |
|----|----------|-----------------|
| AC-04.1 | Learner gửi feedback với rating + comment | Feedback được lưu, người được review nhận thông báo |
| AC-04.2 | Learner cố review chính mình | Nút submit bị vô hiệu hóa hoặc hiện lỗi |
| AC-04.3 | Learner xem feedback nhận được | Hiển thị danh sách feedback với rating và comment |
| AC-04.4 | Instructor xem monitoring | Hiển thị bảng: ai đã review, ai chưa |

### AC-05: Analytics

| ID | Scenario | Expected Result |
|----|----------|-----------------|
| AC-05.1 | Learner xem tiến độ | Hiển thị % hoàn thành chính xác theo số activity đã approved |
| AC-05.2 | Instructor xem analytics lớp | Hiển thị biểu đồ tỷ lệ hoàn thành theo tuần |
| AC-05.3 | Instructor chọn xem tiến độ 1 học viên | Hiển thị chi tiết từng activity/milestone của học viên đó |

---

## 8. Out of Scope

Các tính năng sau **không** nằm trong phạm vi phiên bản 1.0:

| # | Tính năng | Lý do |
|---|-----------|-------|
| 1 | **Live Chat / Real-time Messaging** | Cần WebSocket/SignalR, phức tạp hơn REST API |
| 2 | **Video Conferencing** (Zoom/Meet integration) | Ngoài phạm vi, dùng công cụ bên ngoài |
| 3 | **Tự động phân công peer review** (thuật toán) | Làm thủ công trong v1, tự động hóa ở v2 |
| 4 | **Push Notification** (FCM) | Chỉ in-app notification trong v1 |
| 5 | **Dark Mode** | Chỉ Light mode trong v1 |
| 6 | **Đa ngôn ngữ** (i18n) | Chỉ Tiếng Việt trong v1 |
| 7 | **Export báo cáo PDF/Excel** | Xem xét trong v2 |
| 8 | **Tích hợp LMS bên ngoài** (Moodle, Canvas) | Ngoài phạm vi dự án |
| 9 | **Gamification** (điểm, huy hiệu) | Xem xét trong v2 |
| 10 | **Admin panel** (quản trị hệ thống) | Web admin sẽ được phát triển riêng |
