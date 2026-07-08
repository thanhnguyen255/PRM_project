# API SPECIFICATION BY SCREEN — FLIPPED CLASSROOM

> **Base URL**: `http://DESKTOP-KN8VR1N:5111/api`
> **Auth**: Bearer JWT Token — Header: `Authorization: Bearer <token>`
> **Content-Type**: `application/json` (trừ upload: `multipart/form-data`)
> **Version**: 1.0

---

## Quy ước chung

### Response wrapper

Mọi API đều trả về cấu trúc chuẩn:

```json
// Thành công
{
  "success": true,
  "data": { ... },
  "message": null
}

// Thất bại
{
  "success": false,
  "data": null,
  "message": "Mô tả lỗi"
}
```

### HTTP Status Codes

| Code | Ý nghĩa |
|------|---------|
| `200` | OK — thành công, có data |
| `201` | Created — tạo mới thành công |
| `204` | No Content — thành công, không có data (delete) |
| `400` | Bad Request — sai dữ liệu đầu vào |
| `401` | Unauthorized — không có / sai token |
| `403` | Forbidden — không có quyền |
| `404` | Not Found — không tìm thấy |
| `409` | Conflict — vi phạm unique constraint (email đã tồn tại) |
| `500` | Internal Server Error |

### JWT Token

Sau khi login, lưu token vào `SharedPreferences`:
```dart
await prefs.setString('token', response.token);
await prefs.setString('role', response.role);
await prefs.setInt('userId', response.userId);
```

---

## Table of Contents

### Learner
- [SCR-L01 Splash](#scr-l01-splash-screen)
- [SCR-L02 Login](#scr-l02-login-screen)
- [SCR-L03 Register](#scr-l03-register-screen)
- [SCR-L05 Home Dashboard](#scr-l05-home-dashboard)
- [SCR-L06 Notifications](#scr-l06-notifications)
- [SCR-L07 My Courses](#scr-l07-my-courses)
- [SCR-L08 Course Detail](#scr-l08-course-detail)
- [SCR-L09 Class Detail](#scr-l09-class-detail)
- [SCR-L10 Members List](#scr-l10-members-list)
- [SCR-L11 Learning Path Overview](#scr-l11-learning-path-overview)
- [SCR-L12 Week Detail](#scr-l12-week-detail)
- [SCR-L13 Materials List](#scr-l13-materials-list)
- [SCR-L17/20/23 Activity Lists](#scr-l17-l20-l23-activity-lists)
- [SCR-L18/21/24 Activity Detail](#scr-l18-l21-l24-activity-detail)
- [SCR-L19/22/25 Submit Evidence](#scr-l19-l22-l25-submit-evidence)
- [SCR-L26 Project List](#scr-l26-project-list)
- [SCR-L27 Project Detail](#scr-l27-project-detail)
- [SCR-L28 Milestone List](#scr-l28-milestone-list)
- [SCR-L29 Milestone Detail](#scr-l29-milestone-detail)
- [SCR-L30 Submit Milestone](#scr-l30-submit-milestone)
- [SCR-L31 Review Sessions](#scr-l31-review-sessions)
- [SCR-L32 Review Detail](#scr-l32-review-detail)
- [SCR-L33 Submit Feedback](#scr-l33-submit-feedback)
- [SCR-L34 Received Feedback](#scr-l34-received-feedback)
- [SCR-L35 Evidence Detail](#scr-l35-evidence-detail)
- [SCR-L36 Evidence Comments](#scr-l36-evidence-comments)
- [SCR-L37/38/39 Progress](#scr-l37-l38-l39-progress)
- [SCR-L40 Profile](#scr-l40-profile)
- [SCR-L41 Edit Profile](#scr-l41-edit-profile)

### Instructor
- [SCR-I01 Dashboard](#scr-i01-instructor-dashboard)
- [SCR-I02/I03 Course Management](#scr-i02-i03-course-management)
- [SCR-I04/I05 Class Management](#scr-i04-i05-class-management)
- [SCR-I06/I07 Learning Path Management](#scr-i06-i07-learning-path-management)
- [SCR-I08/I09 Material Management](#scr-i08-i09-material-management)
- [SCR-I10/I11 Activity Management](#scr-i10-i11-activity-management)
- [SCR-I12/I13/I14 Project Management](#scr-i12-i13-i14-project-management)
- [SCR-I15/I16 Review Management](#scr-i15-i16-review-management)
- [SCR-I17 Evidence List](#scr-i17-evidence-list)
- [SCR-I18 Evidence Detail](#scr-i18-evidence-detail)
- [SCR-I19 Comment & Feedback](#scr-i19-comment--feedback)
- [SCR-I20/I21 Analytics](#scr-i20-i21-analytics)

---

# AUTHENTICATION (Public — Không cần token)

---

## SCR-L01 Splash Screen

**Mục đích**: Kiểm tra token còn hiệu lực không, route tới màn hình phù hợp.

### Logic (không cần API call)

```dart
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('token');
final role = prefs.getString('role');

if (token == null) → navigate '/login'
if (role == 'Instructor') → navigate '/instructor/dashboard'
else → navigate '/home'
```

> *(Optional)* Có thể call `GET /api/users/me` để verify token còn sống, nếu 401 → xóa token → redirect login.

---

## SCR-L02 Login Screen

### API: POST `/api/auth/login`

**Auth**: Không cần  
**Content-Type**: `application/json`

**Request Body**:
```json
{
  "email": "learner1@student.edu.vn",
  "password": "Password@123"
}
```

**Response 200**:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": 3,
    "fullName": "Lê Văn Minh",
    "role": "Learner",
    "avatarUrl": null,
    "expiresAt": "2026-07-07T04:00:00Z"
  }
}
```

**Response 401**:
```json
{
  "success": false,
  "data": null,
  "message": "Email hoặc mật khẩu không đúng."
}
```

**Sau khi login thành công**:
```dart
// Lưu vào SharedPreferences
prefs.setString('token', data.token);
prefs.setInt('userId', data.userId);
prefs.setString('fullName', data.fullName);
prefs.setString('role', data.role);

// Route
if (data.role == 'Instructor') → '/instructor/dashboard'
else → '/home'
```

---

## SCR-L03 Register Screen

### API: POST `/api/auth/register`

**Auth**: Không cần  
**Content-Type**: `application/json`

**Request Body**:
```json
{
  "fullName": "Nguyễn Văn A",
  "email": "student@example.com",
  "password": "Password@123"
}
```

**Validation (Frontend)**:
- `fullName`: không trống
- `email`: format hợp lệ
- `password`: ≥ 8 ký tự, có chữ hoa, chữ thường, số
- `confirmPassword`: phải trùng password

**Response 201**:
```json
{
  "success": true,
  "data": {
    "token": "eyJ...",
    "userId": 7,
    "fullName": "Nguyễn Văn A",
    "role": "Learner"
  }
}
```

**Response 409** (email đã tồn tại):
```json
{
  "success": false,
  "data": null,
  "message": "Email này đã được sử dụng."
}
```

---

# LEARNER — DASHBOARD

---

## SCR-L05 Home Dashboard

**Auth**: Bearer Token (Learner)

### API 1: GET `/api/courses/my`

**Purpose**: Lấy danh sách khóa học đang tham gia (CourseCard horizontal scroll)

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "PRM392 - Mobile Application Development",
      "coverImageUrl": null,
      "instructorName": "Nguyễn Văn Bình",
      "progressPercent": 0.75,
      "activeClassId": 1,
      "activeClassName": "SE1801"
    }
  ]
}
```

### API 2: GET `/api/activities/upcoming?classId={classId}`

**Purpose**: Lấy activities sắp đến deadline (Upcoming section)

**Query Params**:
- `classId` — ID lớp học
- `limit` — số lượng tối đa (default: 5)

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "title": "Nghiên cứu Flutter Widgets",
      "type": "PreClass",
      "deadline": "2026-06-15T23:59:00Z",
      "submissionStatus": null,
      "learningPathTitle": "Tuần 2: Widgets & Layouts"
    }
  ]
}
```

### API 3: GET `/api/notifications/unread-count`

**Purpose**: Badge số thông báo chưa đọc trên AppBar

**Response 200**:
```json
{
  "success": true,
  "data": { "count": 3 }
}
```

---

## SCR-L06 Notifications

**Auth**: Bearer Token (Learner)

### API 1: GET `/api/notifications`

**Query Params**: `page` (default: 1), `pageSize` (default: 20)

**Response 200**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 1,
        "title": "Evidence được duyệt ✅",
        "body": "Bài nộp '[Pre-Class] Xem video Dart cơ bản' đã được Approved.",
        "isRead": true,
        "createdAt": "2026-06-08T15:00:00Z"
      },
      {
        "id": 2,
        "title": "Hoạt động mới tuần 2 📚",
        "body": "Tuần 2 đã có hoạt động mới...",
        "isRead": false,
        "createdAt": "2026-06-11T08:00:00Z"
      }
    ],
    "totalCount": 5,
    "unreadCount": 3
  }
}
```

### API 2: PUT `/api/notifications/{id}/read`

**Purpose**: Đánh dấu 1 notification đã đọc (khi tap vào)

**Response 204**: No Content

### API 3: PUT `/api/notifications/read-all`

**Purpose**: Đánh dấu tất cả đã đọc

**Response 204**: No Content

---

# LEARNER — COURSE & CLASS

---

## SCR-L07 My Courses

**Auth**: Bearer Token (Learner)

### API: GET `/api/courses/my`

*(Cùng response như SCR-L05 API 1)*

**Query Params (optional)**:
- `search` — tìm theo tên khóa học

---

## SCR-L08 Course Detail

**Auth**: Bearer Token

### API: GET `/api/courses/{id}`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "PRM392 - Mobile Application Development",
    "description": "Khóa học phát triển ứng dụng di động...",
    "coverImageUrl": null,
    "instructorName": "Nguyễn Văn Bình",
    "instructorAvatar": null,
    "createdAt": "2026-06-01T00:00:00Z",
    "classes": [
      {
        "id": 1,
        "name": "PRM392 - SE1801",
        "startDate": "2026-06-01",
        "endDate": "2026-08-31",
        "memberCount": 32
      },
      {
        "id": 2,
        "name": "PRM392 - SE1802",
        "startDate": "2026-06-01",
        "endDate": "2026-08-31",
        "memberCount": 28
      }
    ]
  }
}
```

---

## SCR-L09 Class Detail

**Auth**: Bearer Token

### API: GET `/api/classes/{id}`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "courseId": 1,
    "courseTitle": "PRM392 - Mobile Dev",
    "name": "PRM392 - SE1801",
    "startDate": "2026-06-01",
    "endDate": "2026-08-31",
    "memberCount": 32,
    "weekCount": 3,
    "progressPercent": 0.75
  }
}
```

---

## SCR-L10 Members List

**Auth**: Bearer Token

### API: GET `/api/classes/{id}/members`

**Query Params**: `search` (optional)

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "userId": 3,
      "fullName": "Lê Văn Minh",
      "email": "learner1@student.edu.vn",
      "avatarUrl": null,
      "joinedAt": "2026-06-07T00:00:00Z"
    }
  ]
}
```

---

# LEARNER — LEARNING PATH

---

## SCR-L11 Learning Path Overview

**Auth**: Bearer Token

### API: GET `/api/learning-paths?classId={classId}`

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Tuần 1: Giới thiệu Flutter & Dart",
      "weekNumber": 1,
      "totalActivities": 3,
      "completedActivities": 3,
      "state": "completed"
    },
    {
      "id": 2,
      "title": "Tuần 2: Widgets & Layouts",
      "weekNumber": 2,
      "totalActivities": 2,
      "completedActivities": 1,
      "state": "inProgress"
    },
    {
      "id": 3,
      "title": "Tuần 3: State Management",
      "weekNumber": 3,
      "totalActivities": 1,
      "completedActivities": 0,
      "state": "locked"
    }
  ]
}
```

**State logic** (tính trên server):
- `completed` = completedActivities == totalActivities && totalActivities > 0
- `inProgress` = completedActivities > 0 && < totalActivities
- `locked` = tuần trước chưa `completed`

---

## SCR-L12 Week Detail

**Auth**: Bearer Token

### API: GET `/api/learning-paths/{id}`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "classId": 1,
    "title": "Tuần 1: Giới thiệu Flutter & Dart",
    "weekNumber": 1,
    "materials": [
      {
        "id": 1,
        "title": "Video: Dart cơ bản trong 30 phút",
        "type": "Video",
        "linkUrl": "https://youtube.com/..."
      }
    ],
    "preClassActivities": [
      {
        "id": 1,
        "title": "[Pre-Class] Xem video Dart cơ bản",
        "type": "PreClass",
        "deadline": "2026-06-08T23:59:00Z",
        "submissionStatus": "Approved"
      }
    ],
    "inClassActivities": [ ... ],
    "postClassActivities": [ ... ]
  }
}
```

---

## SCR-L13 Materials List

**Auth**: Bearer Token

### API: GET `/api/materials?pathId={pathId}`

**Query Params**: `type` (optional: Video / Document / Link)

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Video: Dart cơ bản trong 30 phút",
      "type": "Video",
      "fileUrl": null,
      "linkUrl": "https://youtube.com/watch?v=veMhOYRib9o"
    },
    {
      "id": 2,
      "title": "Slide: Giới thiệu Flutter & Dart",
      "type": "Document",
      "fileUrl": "/materials/week1-intro-flutter.pdf",
      "linkUrl": null
    }
  ]
}
```

---

# LEARNER — ACTIVITIES

---

## SCR-L17, L20, L23 Activity Lists

**Auth**: Bearer Token

### API: GET `/api/activities?pathId={pathId}&type={type}`

**Query Params**:
- `pathId` — ID của learning path
- `type` — `PreClass` | `InClass` | `PostClass`

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "[Pre-Class] Xem video Dart cơ bản",
      "type": "PreClass",
      "description": "Xem video và ghi chú...",
      "deadline": "2026-06-08T23:59:00Z",
      "submissionId": 1,
      "submissionStatus": "Approved",
      "submittedAt": "2026-06-08T10:30:00Z"
    },
    {
      "id": 4,
      "title": "[Pre-Class] Nghiên cứu Flutter Widgets",
      "type": "PreClass",
      "description": "Đọc tài liệu về các Widget cơ bản...",
      "deadline": "2026-06-15T23:59:00Z",
      "submissionId": null,
      "submissionStatus": null,
      "submittedAt": null
    }
  ]
}
```

---

## SCR-L18, L21, L24 Activity Detail

**Auth**: Bearer Token

### API: GET `/api/activities/{id}`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "learningPathId": 1,
    "learningPathTitle": "Tuần 1: Giới thiệu Flutter & Dart",
    "title": "[Pre-Class] Xem video Dart cơ bản",
    "type": "PreClass",
    "description": "Xem video 'Dart cơ bản trong 30 phút' và ghi chú các điểm chính về: variables, functions, classes, async/await.",
    "deadline": "2026-06-08T23:59:00Z",
    "submission": {
      "id": 1,
      "status": "Approved",
      "isLate": false,
      "note": "Em đã xem video và ghi chú đầy đủ.",
      "fileUrl": "/evidences/learner1-week1-pre-notes.pdf",
      "submittedAt": "2026-06-08T10:30:00Z",
      "reviewedAt": "2026-06-08T15:00:00Z",
      "commentCount": 1
    }
  }
}
```

---

## SCR-L19, L22, L25 Submit Evidence

**Auth**: Bearer Token (Learner)

### API: POST `/api/evidences`

**Content-Type**: `multipart/form-data`

**Form Fields**:
| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `activityId` | int | ✅ | ID activity |
| `note` | string | ❌ | Ghi chú của học viên |
| `file` | File | ❌ | File đính kèm (JPG/PNG/PDF/MP4, max 50MB) |

> Ít nhất `note` hoặc `file` phải có.

**Response 201**:
```json
{
  "success": true,
  "data": {
    "id": 6,
    "activityId": 4,
    "status": "Pending",
    "submittedAt": "2026-06-15T14:30:00Z"
  },
  "message": "Nộp evidence thành công!"
}
```

**Response 409** (Đã duyệt, không được nộp lại):
```json
{
  "success": false,
  "data": null,
  "message": "Bài nộp đã được phê duyệt, bạn không thể nộp lại."
}
```
*(Nếu đã nộp và trạng thái là Pending hoặc Rejected, hệ thống sẽ tự động update evidence cũ thay vì báo lỗi)*

**Response 400** (quá hạn):
```json
{
  "success": false,
  "data": null,
  "message": "Hoạt động này đã hết hạn nộp."
}
```

---

# LEARNER — PROJECTS & MILESTONES

---

## SCR-L26 Project List

**Auth**: Bearer Token

### API: GET `/api/projects?classId={classId}`

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Dự án: Xây dựng ứng dụng Flipped Classroom",
      "description": "Nhóm sẽ xây dựng ứng dụng mobile...",
      "milestoneCount": 4,
      "completedMilestones": 1,
      "nextMilestoneTitle": "Milestone 2: Authentication",
      "nextMilestoneDueDate": "2026-07-05"
    }
  ]
}
```

---

## SCR-L27 Project Detail

**Auth**: Bearer Token

### API: GET `/api/projects/{id}`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "classId": 1,
    "title": "Dự án: Xây dựng ứng dụng Flipped Classroom",
    "description": "Nhóm sẽ xây dựng ứng dụng mobile...",
    "milestones": [
      {
        "id": 1,
        "title": "Milestone 1: Setup & Architecture",
        "dueDate": "2026-06-20",
        "stepNumber": 1,
        "isSubmitted": true,
        "submittedAt": "2026-06-19T22:00:00Z"
      },
      {
        "id": 2,
        "title": "Milestone 2: Authentication & Core Features",
        "dueDate": "2026-07-05",
        "stepNumber": 2,
        "isSubmitted": false,
        "submittedAt": null
      }
    ]
  }
}
```

---

## SCR-L28 Milestone List

**Auth**: Bearer Token

### API: GET `/api/milestones?projectId={projectId}`

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Milestone 1: Setup & Architecture",
      "description": "Thiết lập project, định nghĩa kiến trúc...",
      "dueDate": "2026-06-20",
      "stepNumber": 1,
      "isSubmitted": true
    }
  ]
}
```

---

## SCR-L29 Milestone Detail

**Auth**: Bearer Token

### API: GET `/api/milestones/{id}`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "projectId": 1,
    "projectTitle": "Dự án: Flipped Classroom",
    "title": "Milestone 1: Setup & Architecture",
    "description": "Thiết lập project, định nghĩa kiến trúc hệ thống...",
    "dueDate": "2026-06-20",
    "stepNumber": 1,
    "mySubmission": {
      "id": 1,
      "description": "Nhóm đã hoàn thành setup...",
      "fileUrl": "/milestones/group1-ms1-report.pdf",
      "submittedAt": "2026-06-19T22:00:00Z"
    }
  }
}
```

---

## SCR-L30 Submit Milestone

**Auth**: Bearer Token (Learner)

### API: POST `/api/milestone-submissions`

**Content-Type**: `multipart/form-data`

**Form Fields**:
| Field | Type | Required | Mô tả |
|-------|------|----------|-------|
| `milestoneId` | int | ✅ | ID milestone |
| `description` | string | ❌ | Mô tả báo cáo |
| `file` | File | ❌ | File báo cáo |

**Response 201**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "milestoneId": 2,
    "submittedAt": "2026-07-04T20:00:00Z"
  }
}
```

---

# LEARNER — REVIEW & FEEDBACK

---

## SCR-L31 Review Sessions

**Auth**: Bearer Token

### API: GET `/api/review-sessions?classId={classId}`

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Peer Review - Milestone 1",
      "startDate": "2026-06-21",
      "endDate": "2026-06-23",
      "isOpen": false,
      "myAssignmentCount": 1,
      "myCompletedCount": 1
    }
  ]
}
```

---

## SCR-L32 Review Detail

**Auth**: Bearer Token

### API: GET `/api/review-sessions/{id}`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "classId": 1,
    "title": "Peer Review - Milestone 1",
    "startDate": "2026-06-21",
    "endDate": "2026-06-23",
    "isOpen": false,
    "myAssignments": [
      {
        "id": 1,
        "revieweeId": 4,
        "revieweeName": "Phạm Thị Lan",
        "revieweeAvatar": null,
        "hasFeedback": true
      }
    ],
    "receivedFeedbackCount": 1
  }
}
```

---

## SCR-L33 Submit Feedback

**Auth**: Bearer Token (Learner)

### API: POST `/api/feedbacks`

**Request Body**:
```json
{
  "assignmentId": 1,
  "content": "Nhóm bạn đã làm rất tốt phần setup. Kiến trúc rõ ràng...",
  "rating": 4
}
```

**Validation**:
- `content`: không trống, max 2000 ký tự
- `rating`: 1–5 (int)

**Response 201**:
```json
{
  "success": true,
  "data": {
    "id": 3,
    "assignmentId": 1,
    "rating": 4,
    "createdAt": "2026-06-22T10:00:00Z"
  }
}
```

**Response 409** (đã feedback rồi):
```json
{
  "success": false,
  "message": "Bạn đã gửi feedback cho phiên review này."
}
```

---

## SCR-L34 Received Feedback

**Auth**: Bearer Token

### API: GET `/api/feedbacks/received?sessionId={sessionId}`

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 2,
      "reviewerName": "Hoàng Văn Hùng",
      "reviewerAvatar": null,
      "content": "Bài nộp đúng hạn, có đầy đủ nội dung...",
      "rating": 3,
      "createdAt": "2026-06-22T14:00:00Z"
    }
  ]
}
```

---

# LEARNER — EVIDENCE & COMMENTS

---

## SCR-L35 Evidence Detail

**Auth**: Bearer Token

### API: GET `/api/evidences/{id}`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "activityId": 1,
    "activityTitle": "[Pre-Class] Xem video Dart cơ bản",
    "activityType": "PreClass",
    "learnerName": "Lê Văn Minh",
    "fileUrl": "/evidences/learner1-week1-pre-notes.pdf",
    "note": "Em đã xem video và ghi chú đầy đủ...",
    "status": "Approved",
    "submittedAt": "2026-06-08T10:30:00Z",
    "reviewedAt": "2026-06-08T15:00:00Z",
    "commentCount": 1
  }
}
```

---

## SCR-L36 Evidence Comments

**Auth**: Bearer Token

### API 1: GET `/api/evidences/{id}/comments`

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "authorId": 1,
      "authorName": "Nguyễn Văn Bình",
      "authorAvatar": null,
      "isInstructor": true,
      "content": "Bài nộp tốt! Ghi chú đầy đủ và có ví dụ minh họa rõ ràng.",
      "createdAt": "2026-06-08T15:00:00Z"
    }
  ]
}
```

### API 2: POST `/api/evidences/{id}/comments`

**Request Body**:
```json
{
  "content": "Vâng em cảm ơn thầy ạ."
}
```

**Response 201**:
```json
{
  "success": true,
  "data": {
    "id": 4,
    "authorName": "Lê Văn Minh",
    "isInstructor": false,
    "content": "Vâng em cảm ơn thầy ạ.",
    "createdAt": "2026-06-09T08:00:00Z"
  }
}
```

---

# LEARNER — PROGRESS

---

## SCR-L37, L38, L39 Progress

**Auth**: Bearer Token

### API: GET `/api/analytics/my-progress`

**Query Params**: `classId` (optional, nếu không có thì lấy tất cả)

**Response 200**:
```json
{
  "success": true,
  "data": {
    "overallPercent": 0.75,
    "totalActivities": 24,
    "completedActivities": 18,
    "pendingActivities": 4,
    "missedActivities": 2,
    "weeklyBreakdown": [
      {
        "weekNumber": 1,
        "weekTitle": "Tuần 1: Giới thiệu Flutter",
        "totalActivities": 3,
        "completedActivities": 3,
        "percent": 1.0
      },
      {
        "weekNumber": 2,
        "weekTitle": "Tuần 2: Widgets & Layouts",
        "totalActivities": 2,
        "completedActivities": 1,
        "percent": 0.5
      }
    ],
    "activityDetails": [
      {
        "activityId": 1,
        "title": "[Pre-Class] Xem video Dart cơ bản",
        "type": "PreClass",
        "deadline": "2026-06-08T23:59:00Z",
        "status": "Approved"
      }
    ],
    "milestoneProgress": [
      {
        "milestoneId": 1,
        "title": "Milestone 1: Setup",
        "dueDate": "2026-06-20",
        "isSubmitted": true
      }
    ]
  }
}
```

---

# LEARNER — PROFILE

---

## SCR-L40 Profile

**Auth**: Bearer Token

### API: GET `/api/users/me`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": 3,
    "email": "learner1@student.edu.vn",
    "fullName": "Lê Văn Minh",
    "role": "Learner",
    "avatarUrl": null,
    "createdAt": "2026-06-07T00:00:00Z",
    "stats": {
      "enrolledCourses": 3,
      "completedActivities": 22
    }
  }
}
```

---

## SCR-L41 Edit Profile

**Auth**: Bearer Token

### API: PUT `/api/users/me`

**Content-Type**: `multipart/form-data`

**Form Fields**:
| Field | Type | Required |
|-------|------|----------|
| `fullName` | string | ✅ |
| `avatar` | File (image) | ❌ |

**Response 200**:
```json
{
  "success": true,
  "data": {
    "fullName": "Lê Văn Minh (Updated)",
    "avatarUrl": "/avatars/user_3.jpg"
  }
}
```

---

---

# INSTRUCTOR — DASHBOARD

---

## SCR-I01 Instructor Dashboard

**Auth**: Bearer Token (Instructor)

### API 1: GET `/api/users/me`

*(Cùng response như SCR-L40 nhưng role = "Instructor")*

### API 2: GET `/api/courses/my`

*(Cùng response như SCR-L07)*

### API 3: GET `/api/evidences/pending-count`

**Response 200**:
```json
{
  "success": true,
  "data": { "count": 12 }
}
```

### API 4: GET `/api/evidences?status=Pending&limit=5`

**Purpose**: Danh sách evidence mới cần duyệt (preview 5 items)

*(Cùng format như SCR-I17)*

---

# INSTRUCTOR — COURSE MANAGEMENT

---

## SCR-I02, I03 Course Management

**Auth**: Bearer Token (Instructor)

### API 1: GET `/api/courses/my` — (SCR-I02)

*(Cùng response như SCR-L07)*

### API 2: POST `/api/courses` — (SCR-I03 Create)

**Content-Type**: `multipart/form-data`

**Form Fields**:
| Field | Type | Required |
|-------|------|----------|
| `title` | string | ✅ max 200 |
| `description` | string | ❌ max 2000 |
| `coverImage` | File (image) | ❌ |

**Response 201**:
```json
{
  "success": true,
  "data": {
    "id": 3,
    "title": "PRM393 - Advanced Mobile Dev",
    "description": "...",
    "coverImageUrl": null,
    "createdAt": "2026-06-07T00:00:00Z"
  }
}
```

### API 3: PUT `/api/courses/{id}` — (SCR-I03 Edit)

*(Form fields tương tự POST)*

**Response 200**: Updated course object

### API 4: DELETE `/api/courses/{id}` — (SCR-I02 swipe delete)

**Response 204**: No Content

**Response 400**: Nếu còn classes con thì không cho xóa.

---

# INSTRUCTOR — CLASS MANAGEMENT

---

## SCR-I04, I05 Class Management

**Auth**: Bearer Token (Instructor)

### API 1: GET `/api/classes?courseId={courseId}` — (SCR-I04)

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "PRM392 - SE1801",
      "startDate": "2026-06-01",
      "endDate": "2026-08-31",
      "memberCount": 32
    }
  ]
}
```

### API 2: POST `/api/classes` — (SCR-I04 Create)

**Request Body**:
```json
{
  "courseId": 1,
  "name": "PRM392 - SE1803",
  "startDate": "2026-06-01",
  "endDate": "2026-08-31"
}
```

### API 3: GET `/api/classes/{id}/members` — (SCR-I05)

*(Cùng response như SCR-L10)*

### API 4: POST `/api/classes/{id}/members` — (SCR-I05 Add member)

**Request Body**:
```json
{ "email": "newstudent@student.edu.vn" }
```

**Response 201**: `{ userId, fullName, email }`

**Response 404**: Email không tồn tại trong hệ thống.

### API 5: DELETE `/api/classes/{classId}/members/{userId}` — (SCR-I05 Remove)

**Response 204**: No Content

---

# INSTRUCTOR — LEARNING PATH & MATERIAL

---

## SCR-I06, I07 Learning Path Management

### API 1: GET `/api/learning-paths?classId={id}` — (SCR-I06)

*(Cùng response như SCR-L11)*

### API 2: POST `/api/learning-paths` — (SCR-I07)

**Request Body**:
```json
{
  "classId": 1,
  "title": "Tuần 4: Navigation & Routing",
  "weekNumber": 4
}
```

### API 3: PUT `/api/learning-paths/{id}` — (SCR-I07 Edit)

*(Body tương tự POST)*

### API 4: DELETE `/api/learning-paths/{id}` — (SCR-I06)

---

## SCR-I08, I09 Material Management

### API 1: GET `/api/materials?pathId={id}` — (SCR-I08)

*(Cùng response như SCR-L13)*

### API 2: POST `/api/materials` — (SCR-I09 Upload)

**Content-Type**: `multipart/form-data`

**Form Fields**:
| Field | Type | Required |
|-------|------|----------|
| `learningPathId` | int | ✅ |
| `title` | string | ✅ max 200 |
| `type` | string | ✅ Video / Document / Link |
| `file` | File | ❌ (nếu type=Video/Document) |
| `linkUrl` | string | ❌ (nếu type=Video/Link) |

**Response 201**: Created material object

### API 3: DELETE `/api/materials/{id}` — (SCR-I08 swipe)

---

# INSTRUCTOR — ACTIVITY MANAGEMENT

---

## SCR-I10, I11 Activity Management

### API 1: GET `/api/activities?pathId={id}` — (SCR-I10)

*(Cùng response nhưng không có submissionStatus)*

### API 2: POST `/api/activities` — (SCR-I11)

**Request Body**:
```json
{
  "learningPathId": 2,
  "title": "[Pre-Class] Tìm hiểu về Provider",
  "type": "PreClass",
  "description": "Đọc tài liệu về Provider state management...",
  "deadline": "2026-06-22T23:59:00Z"
}
```

**Validation**:
- `type`: phải là `PreClass` | `InClass` | `PostClass`
- `deadline`: phải sau `DateTime.now()`

**Response 201**: Created activity object

### API 3: PUT `/api/activities/{id}` — (SCR-I11 Edit)

### API 4: DELETE `/api/activities/{id}` — (SCR-I10)

---

# INSTRUCTOR — PROJECT MANAGEMENT

---

## SCR-I12, I13, I14 Project Management

### API 1: GET `/api/projects?classId={id}` — (SCR-I12)

### API 2: POST `/api/projects` — (SCR-I13)

**Request Body**:
```json
{
  "classId": 1,
  "title": "Dự án: App quản lý thư viện",
  "description": "Nhóm sẽ xây dựng..."
}
```

### API 3: PUT/DELETE `/api/projects/{id}`

### API 4: GET `/api/milestones?projectId={id}` — (SCR-I14)

### API 5: POST `/api/milestones` — (SCR-I14 Create)

**Request Body**:
```json
{
  "projectId": 1,
  "title": "Milestone 1: Database Design",
  "description": "Thiết kế ERD và tạo database...",
  "dueDate": "2026-06-25"
}
```

### API 6: PUT/DELETE `/api/milestones/{id}`

---

# INSTRUCTOR — REVIEW MANAGEMENT

---

## SCR-I15, I16 Review Management

### API 1: GET `/api/review-sessions?classId={id}` — (SCR-I15)

*(Cùng response như SCR-L31)*

### API 2: POST `/api/review-sessions` — (SCR-I15 Create)

**Request Body**:
```json
{
  "classId": 1,
  "title": "Peer Review - Milestone 2",
  "startDate": "2026-07-06",
  "endDate": "2026-07-08",
  "autoAssign": true
}
```

> `autoAssign: true` → server tự tạo ReviewAssignments theo round-robin.

**Response 201**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "title": "Peer Review - Milestone 2",
    "assignmentsCreated": 32
  }
}
```

### API 3: GET `/api/review-assignments?sessionId={id}` — (SCR-I16)

**Response 200**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "reviewerName": "Lê Văn Minh",
      "revieweeName": "Phạm Thị Lan",
      "status": 1,
      "hasFeedback": true,
      "feedbackRating": 4
    },
    {
      "id": 2,
      "reviewerName": "Phạm Thị Lan",
      "revieweeName": "Hoàng Văn Hùng",
      "status": 2,
      "hasFeedback": false,
      "feedbackRating": null
    }
  ]
}
```

### API 4: PUT `/api/review-assignments/{id}/reassign`

**Purpose**: Instructor phân công lại hoặc chấm thay.

**Request Body**:
```json
{
  "newReviewerId": 5
}
```

**Response 200**:
```json
{
  "success": true,
  "message": "Phân công lại thành công."
}
```

---

# INSTRUCTOR — EVIDENCE REVIEW

---

## SCR-I17 Evidence List

**Auth**: Bearer Token (Instructor)

### API: GET `/api/evidences?classId={classId}&status={status}`

**Query Params**:
- `classId` — bắt buộc
- `status` — `Pending` | `Approved` | `Rejected` | (bỏ trống = All)
- `page`, `pageSize`

**Response 200**:
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": 2,
        "learnerId": 4,
        "learnerName": "Phạm Thị Lan",
        "learnerAvatar": null,
        "activityTitle": "[Pre-Class] Xem video Dart cơ bản",
        "activityType": "PreClass",
        "status": "Pending",
        "submittedAt": "2026-06-08T22:45:00Z",
        "hasFile": true
      }
    ],
    "totalCount": 12,
    "pendingCount": 4
  }
}
```

---

## SCR-I18 Evidence Detail (Instructor)

**Auth**: Bearer Token (Instructor)

### API 1: GET `/api/evidences/{id}`

*(Cùng response như SCR-L35)*

### API 2: PUT `/api/evidences/{id}/approve`

**Request Body**: (Optional comment)
```json
{ "comment": "Bài nộp tốt!" }
```

**Response 200**:
```json
{
  "success": true,
  "data": {
    "id": 2,
    "status": "Approved",
    "reviewedAt": "2026-06-08T16:00:00Z"
  },
  "message": "Đã Approve evidence."
}
```

**Side effect**: Tự động tạo Notification cho Learner.

### API 3: PUT `/api/evidences/{id}/reject`

**Request Body**:
```json
{ "comment": "Em cần xem lại và nộp lại." }
```

*(Cùng response format, status = "Rejected")*

**Side effect**: Tạo Notification + EvidenceComment tự động.

---

## SCR-I19 Comment & Feedback

*(Cùng API như SCR-L36 — GET và POST `/api/evidences/{id}/comments`)*

---

# INSTRUCTOR — ANALYTICS

---

## SCR-I20, I21 Analytics

**Auth**: Bearer Token (Instructor)

### API 1: GET `/api/analytics/class/{classId}` — (SCR-I20)

**Response 200**:
```json
{
  "success": true,
  "data": {
    "classId": 1,
    "className": "PRM392 - SE1801",
    "memberCount": 32,
    "overallCompletionPercent": 0.68,
    "weeklyCompletion": [
      { "weekNumber": 1, "completionPercent": 1.0 },
      { "weekNumber": 2, "completionPercent": 0.75 },
      { "weekNumber": 3, "completionPercent": 0.4 }
    ],
    "averageRating": 3.5,
    "topLearners": [
      { "userId": 3, "fullName": "Lê Văn Minh", "completedActivities": 22, "total": 24 },
      { "userId": 4, "fullName": "Phạm Thị Lan", "completedActivities": 20, "total": 24 }
    ],
    "evidenceStats": {
      "total": 96,
      "approved": 65,
      "pending": 18,
      "rejected": 13
    }
  }
}
```

### API 2: GET `/api/analytics/student/{userId}?classId={classId}` — (SCR-I21)

**Response 200**:
```json
{
  "success": true,
  "data": {
    "userId": 3,
    "fullName": "Lê Văn Minh",
    "avatarUrl": null,
    "completionPercent": 0.92,
    "totalActivities": 24,
    "completedActivities": 22,
    "weeklyDetail": [
      {
        "weekNumber": 1,
        "activities": [
          { "title": "Pre-Class", "status": "Approved" },
          { "title": "In-Class", "status": "Approved" },
          { "title": "Post-Class", "status": "Pending" }
        ]
      }
    ],
    "averageFeedbackRating": 4.0
  }
}
```

---

# INSTRUCTOR — PROFILE

---

## SCR-I22 Profile

**Auth**: Bearer Token (Instructor)

### API: GET `/api/users/me`

*(Cùng response như SCR-L40)*

---

## SCR-I23 Edit Profile

**Auth**: Bearer Token (Instructor)

### API: PUT `/api/users/me`

*(Cùng format như SCR-L41)*

---

---

## Error Handling Summary

### Flutter ApiService — interceptor xử lý lỗi

```dart
// lib/services/api_service.dart
_dio.interceptors.add(InterceptorsWrapper(
  onError: (DioException e, handler) {
    switch (e.response?.statusCode) {
      case 401:
        // Token hết hạn → clear prefs → navigate '/login'
        _clearAndRedirect();
        break;
      case 403:
        AppSnackBar.show(context, 'Bạn không có quyền thực hiện thao tác này.', type: SnackType.error);
        break;
      case 404:
        AppSnackBar.show(context, 'Không tìm thấy dữ liệu.', type: SnackType.error);
        break;
      case 500:
        AppSnackBar.show(context, 'Lỗi hệ thống. Vui lòng thử lại.', type: SnackType.error);
        break;
    }
    handler.next(e);
  },
));
```

---

## API Implementation Priority

| # | Endpoint Group | Screens cần | Priority |
|---|---------------|------------|---------|
| 1 | Auth (login, register, /me) | L01, L02, L03, L40 | 🔴 Cao |
| 2 | Courses (my, detail) | L05, L07, L08, I02 | 🔴 Cao |
| 3 | Classes + Members | L09, L10, I04, I05 | 🔴 Cao |
| 4 | Learning Paths + Activities | L11, L12, L17–L24 | 🟡 Trung bình |
| 5 | Materials | L13, L14, I08 | 🟡 Trung bình |
| 6 | Evidence (submit, list, approve/reject) | L19–L25, I17, I18 | 🟡 Trung bình |
| 7 | Comments | L36, I19 | 🟡 Trung bình |
| 8 | Projects + Milestones | L26–L30, I12–I14 | 🟢 Thấp |
| 9 | Review + Feedback | L31–L34, I15, I16 | 🟢 Thấp |
| 10 | Analytics | L37–L39, I20, I21 | 🟢 Thấp |
| 11 | Notifications | L05, L06 | 🟢 Thấp |
