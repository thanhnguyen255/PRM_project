# ENTITY ↔ UI MAPPING — FLIPPED CLASSROOM

> **Mục đích**: Tài liệu truy vết toàn bộ liên kết giữa Backend Entity ↔ API Endpoint ↔ Flutter Screen ↔ Component.
> Dùng để đảm bảo consistency giữa Backend Dev và Frontend Dev.

---

## Table of Contents

1. [User](#1-user)
2. [Course](#2-course)
3. [Class](#3-class)
4. [ClassMember](#4-classmember)
5. [LearningPath](#5-learningpath)
6. [LearningMaterial](#6-learningmaterial)
7. [Activity](#7-activity)
8. [ActivitySubmission (Evidence)](#8-activitysubmission-evidence)
9. [EvidenceComment](#9-evidencecomment)
10. [Project](#10-project)
11. [Milestone](#11-milestone)
12. [MilestoneSubmission](#12-milestonesubmission)
13. [ReviewSession](#13-reviewsession)
14. [ReviewAssignment](#14-reviewassignment)
15. [Feedback](#15-feedback)
16. [Notification](#16-notification)
17. [Reverse Map: Screen → Entities](#reverse-map-screen--entities)
18. [API Contract Summary](#api-contract-summary)

---

## 1. User

**Entity**: `DAL/Models/User.cs`
**Table**: `Users`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component | Ghi chú |
|-------|------|---------------------|-----------|---------|
| `Id` | int | Tất cả (FK reference) | — | Primary key |
| `Email` | string | SCR-L02 (login form), SCR-L03 (register), SCR-L40 (profile info) | AppTextField, ProfileScreen | UNIQUE constraint |
| `PasswordHash` | string | SCR-L02 (input obscure), SCR-L03 (input) | AppTextField (obscureText=true) | Không hiển thị, chỉ send plain text |
| `FullName` | string | SCR-L05 (header), SCR-L10 (member list), SCR-L40 (profile), SCR-I01 (dashboard header) | AppBarWidget, MemberListTile | 16–22sp |
| `Role` | UserRole | SCR-L01 (routing logic), SCR-L40 (profile badge) | SplashScreen logic | 0=Learner, 1=Instructor |
| `AvatarUrl` | string? | SCR-L10, SCR-L33, SCR-L36, SCR-L40, SCR-I18, SCR-I19 | MemberListTile, CommentTile, ProfileScreen | Nullable; fallback = initial letter avatar |
| `CreatedAt` | DateTime | SCR-L40 (profile "Ngày tham gia") | ProfileScreen | Format: dd/MM/yyyy |

### API Endpoints

| Method | Path | Dùng bởi Screen | Request Body / Response |
|--------|------|-----------------|------------------------|
| POST | `/api/auth/register` | SCR-L03 | `{ email, password, fullName }` |
| POST | `/api/auth/login` | SCR-L02 | `{ email, password }` → `{ token, role, userId, fullName }` |
| GET | `/api/users/me` | SCR-L40, SCR-I01 | → `UserDto` |
| PUT | `/api/users/me` | SCR-L41 | `{ fullName, avatarUrl }` |

### Flutter Model

```dart
// lib/models/user_model.dart
class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String role;         // "Learner" | "Instructor"
  final String? avatarUrl;
  final DateTime createdAt;
}
```

---

## 2. Course

**Entity**: `DAL/Models/Course.cs`
**Table**: `Courses`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component | Ghi chú |
|-------|------|---------------------|-----------|---------|
| `Id` | int | URL params, FK | — | — |
| `Title` | string | SCR-L07 (list), SCR-L08 (detail header), SCR-I02, SCR-I03 | CourseCard, AppBarWidget | maxLines: 2, 15–22sp |
| `Description` | string? | SCR-L08 (tab Overview), SCR-I03 (edit form) | AppTextField (5 lines), Text | maxLines: 5 |
| `CoverImageUrl` | string? | SCR-L07, SCR-L08, SCR-I03 | CourseCard (ClipRRect image), ImagePicker | fallback: gradient+school icon |
| `InstructorId` | int | — | — | FK → User |
| `InstructorName` | *(join)* | SCR-L07, SCR-L08 | CourseCard subtitle | JOIN trong DTO |
| `CreatedAt` | DateTime | SCR-L08 (detail info) | Text | Format: dd/MM/yyyy |

### Progress (computed)

| Field (computed) | Nguồn | Hiển thị tại | Component |
|-----------------|-------|--------------|-----------|
| `progressPercent` | COUNT(submissions) / COUNT(activities) | SCR-L07, SCR-L08, SCR-L37 | LinearProgressIndicator in CourseCard |
| `classCount` | COUNT(classes) | SCR-L08 | Text "3 lớp" |

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/courses/my` | SCR-L07, SCR-L05, SCR-I02 |
| GET | `/api/courses/{id}` | SCR-L08 |
| POST | `/api/courses` | SCR-I03 (create) |
| PUT | `/api/courses/{id}` | SCR-I03 (edit) |
| DELETE | `/api/courses/{id}` | SCR-I02 (swipe delete) |

### Flutter Model

```dart
// lib/models/course_model.dart
class CourseModel {
  final int id;
  final String title;
  final String? description;
  final String? coverImageUrl;
  final int instructorId;
  final String instructorName;   // từ JOIN
  final double progressPercent;  // 0.0–1.0, computed
  final int classCount;
  final DateTime createdAt;
}
```

---

## 3. Class

**Entity**: `DAL/Models/Class.cs`
**Table**: `Classes`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | URL params | — |
| `CourseId` | int | FK | — |
| `Name` | string | SCR-L08 (tab Lớp), SCR-L09 (header), SCR-I04 | ListTile title |
| `StartDate` | DateTime? | SCR-L09, SCR-L08 (tab Lớp) | Text "01/06/2026" |
| `EndDate` | DateTime? | SCR-L09 | Text "31/08/2026" |
| `MemberCount` | *(computed)* | SCR-L08, SCR-L09 | Text "32 thành viên" |

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/classes?courseId={id}` | SCR-L08 (tab Lớp), SCR-I04 |
| GET | `/api/classes/{id}` | SCR-L09 |
| POST | `/api/classes` | SCR-I04 (create) |
| PUT | `/api/classes/{id}` | SCR-I04 (edit) |
| DELETE | `/api/classes/{id}` | SCR-I04 |

### Flutter Model

```dart
class ClassModel {
  final int id;
  final int courseId;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final int memberCount;   // computed
}
```

---

## 4. ClassMember

**Entity**: `DAL/Models/ClassMember.cs`
**Table**: `ClassMembers`
**Unique Index**: `(ClassId, UserId)`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `ClassId` | int | FK | — |
| `UserId` | int | FK | — |
| `JoinedAt` | DateTime | SCR-L10 (subtitle "Tham gia: 01/06") | MemberListTile subtitle |
| User.FullName | *(join)* | SCR-L10, SCR-I05 | MemberListTile title |
| User.AvatarUrl | *(join)* | SCR-L10, SCR-I05 | CircleAvatar |
| User.Email | *(join)* | SCR-L10, SCR-I05 | MemberListTile subtitle |

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/classes/{id}/members` | SCR-L10, SCR-I05 |
| POST | `/api/classes/{id}/members` | SCR-I05 (add member by email) |
| DELETE | `/api/classes/{classId}/members/{userId}` | SCR-I05 (remove member) |

---

## 5. LearningPath

**Entity**: `DAL/Models/LearningPath.cs`
**Table**: `LearningPaths`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | URL params | — |
| `ClassId` | int | FK | — |
| `Title` | string | SCR-L11 (WeekCard title), SCR-L12 (AppBar), SCR-I06 | WeekCard, AppBarWidget |
| `WeekNumber` | int | SCR-L11 (step number ①②③), SCR-L12 | ProgressStepCard |
| `CompletedActivities` | *(computed)* | SCR-L11 (4/5 hoạt động), SCR-L12 | WeekCard subtitle |
| `TotalActivities` | *(computed)* | SCR-L11 | WeekCard subtitle |
| `State` | *(computed)* | SCR-L11 | WeekCard (completed/inProgress/locked) |

**State logic**: `completed` nếu tất cả activities đã Approved | `inProgress` nếu có ≥1 activity | `locked` nếu tuần trước chưa xong

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/learning-paths?classId={id}` | SCR-L11, SCR-I06 |
| GET | `/api/learning-paths/{id}` | SCR-L12 |
| POST | `/api/learning-paths` | SCR-I07 |
| PUT | `/api/learning-paths/{id}` | SCR-I07 |
| DELETE | `/api/learning-paths/{id}` | SCR-I06 |

### Flutter Model

```dart
class LearningPathModel {
  final int id;
  final int classId;
  final String title;
  final int weekNumber;
  final int totalActivities;      // computed
  final int completedActivities;  // computed
  final String state;             // "completed" | "inProgress" | "locked"
}
```

---

## 6. LearningMaterial

**Entity**: `DAL/Models/LearningMaterial.cs`
**Table**: `LearningMaterials`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | URL params | — |
| `LearningPathId` | int | FK | — |
| `Title` | string | SCR-L13, SCR-L14, SCR-I08, SCR-I09 | MaterialListTile title |
| `Type` | MaterialType | SCR-L13 (icon + filter), SCR-L14 | MaterialListTile icon (🎬📄🔗), FilterChipGroup |
| `FileUrl` | string? | SCR-L15, SCR-L16 | VideoPlayer, DocumentViewer |
| `LinkUrl` | string? | SCR-L15 (YouTube embed), SCR-L14 | WebView / YouTube player |

**Type → Icon mapping**:
- `Video (0)` → `play_circle_rounded`, màu `#EC4899`
- `Document (1)` → `description_rounded`, màu `#4F46E5`
- `Link (2)` → `link_rounded`, màu `#06B6D4`

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/materials?pathId={id}` | SCR-L13, SCR-I08 |
| GET | `/api/materials/{id}` | SCR-L14 |
| POST | `/api/materials` (multipart) | SCR-I09 |
| PUT | `/api/materials/{id}` | SCR-I08 (edit) |
| DELETE | `/api/materials/{id}` | SCR-I08 (swipe) |

### Flutter Model

```dart
class LearningMaterialModel {
  final int id;
  final int learningPathId;
  final String title;
  final String type;   // "Video" | "Document" | "Link"
  final String? fileUrl;
  final String? linkUrl;
}
```

---

## 7. Activity

**Entity**: `DAL/Models/Activity.cs`
**Table**: `Activities`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | URL params | — |
| `LearningPathId` | int | FK | — |
| `Title` | string | SCR-L17, L18, L20, L21, L23, L24, L05 (upcoming) | ActivityCard title, AppBarWidget |
| `Type` | ActivityType | SCR-L17/L20/L23 (section header), SCR-L18 (badge), SCR-L05 (dot) | ActivityCard (dot color + border), StatusBadge-like chip |
| `Description` | string? | SCR-L18, L21, L24 (detail body) | Text (scrollable) |
| `Deadline` | DateTime? | SCR-L17, L18, L20–L25, L05 | ActivityCard ("⏰ Hạn: …"), urgent red coloring |
| `SubmissionStatus` | *(computed)* | SCR-L17, L20, L23 | StatusBadge (Pending/Approved/Rejected) |

**Type → Color**:
- `PreClass (0)` → `#8B5CF6` (Violet) — dot, left-border, badge bg
- `InClass (1)` → `#EC4899` (Pink)
- `PostClass (2)` → `#F97316` (Orange)

**Deadline urgency** (ActivityCard):
- > 24h → `textHint` (`#94A3B8`)
- ≤ 24h → `#D97706` (warning)
- Overdue → `#DC2626` (error) + strikethrough

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/activities?pathId={id}&type=PreClass` | SCR-L17 |
| GET | `/api/activities?pathId={id}&type=InClass` | SCR-L20 |
| GET | `/api/activities?pathId={id}&type=PostClass` | SCR-L23 |
| GET | `/api/activities/{id}` | SCR-L18, L21, L24 |
| GET | `/api/activities/upcoming?classId={id}` | SCR-L05 (Upcoming section) |
| POST | `/api/activities` | SCR-I11 |
| PUT | `/api/activities/{id}` | SCR-I11 |
| DELETE | `/api/activities/{id}` | SCR-I10 |

### Flutter Model

```dart
class ActivityModel {
  final int id;
  final int learningPathId;
  final String title;
  final String type;           // "PreClass" | "InClass" | "PostClass"
  final String? description;
  final DateTime? deadline;
  final String? submissionStatus;   // "Pending" | "Approved" | "Rejected" | null
}
```

---

## 8. ActivitySubmission (Evidence)

**Entity**: `DAL/Models/ActivitySubmission.cs`
**Table**: `ActivitySubmissions`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | URL params | — |
| `ActivityId` | int | FK | — |
| `UserId` | int | FK | — |
| `FileUrl` | string? | SCR-L35 (preview), SCR-I18 (preview) | Image / PDF preview widget |
| `Note` | string? | SCR-L19/22/25 (input), SCR-L35 (display), SCR-I18 | AppTextField (4 lines), Text Card |
| `Status` | EvidenceStatus | SCR-L17/20/23 (badge), SCR-L18/21/24, SCR-L35, SCR-I17, SCR-I18 | **StatusBadge** (Pending/Approved/Rejected) |
| `SubmittedAt` | DateTime | SCR-L35, SCR-I17, SCR-I18 | Text "Nộp: 08/06 · 10:30" |
| `ReviewedAt` | DateTime? | SCR-L35 (nếu có), SCR-I18 | Text "Duyệt: 08/06 · 15:00" |
| User.FullName | *(join)* | SCR-I17, SCR-I18 | EvidenceCard learnerName |
| Activity.Title | *(join)* | SCR-I17, SCR-I18 | EvidenceCard activityTitle |
| CommentCount | *(computed)* | SCR-I18 (💬 Xem bình luận (3)) | Button label |

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/evidences?classId={id}&status=Pending` | SCR-I17 |
| GET | `/api/evidences?activityId={id}&userId=me` | SCR-L17/20/23 (check submission) |
| GET | `/api/evidences/{id}` | SCR-L35, SCR-I18 |
| POST | `/api/evidences` (multipart) | SCR-L19, L22, L25 |
| PUT | `/api/evidences/{id}/approve` | SCR-I18 (Approve button) |
| PUT | `/api/evidences/{id}/reject` | SCR-I18 (Reject button) |

### DTO shape

```dart
// Request: POST /api/evidences
class SubmitEvidenceRequest {
  final int activityId;
  final String? note;
  final File? file;             // multipart
}

// Response: GET /api/evidences/{id}
class EvidenceDto {
  final int id;
  final int activityId;
  final String activityTitle;
  final String learnerName;
  final String? fileUrl;
  final String? note;
  final String status;          // "Pending" | "Approved" | "Rejected"
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final int commentCount;
}
```

---

## 9. EvidenceComment

**Entity**: `DAL/Models/EvidenceComment.cs`
**Table**: `EvidenceComments`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | — | — |
| `SubmissionId` | int | FK | — |
| `UserId` | int | FK | — |
| `Content` | string | SCR-L36, SCR-I19 | **CommentTile** content |
| `CreatedAt` | DateTime | SCR-L36, SCR-I19 | CommentTile timestamp |
| User.FullName | *(join)* | SCR-L36, SCR-I19 | CommentTile author |
| User.AvatarUrl | *(join)* | SCR-L36, SCR-I19 | CommentTile CircleAvatar |
| User.Role | *(join)* | SCR-L36 | CommentTile "[GV]" badge nếu Instructor |

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/evidences/{id}/comments` | SCR-L36, SCR-I19 |
| POST | `/api/evidences/{id}/comments` | SCR-L36, SCR-I19 (send button) |

### DTO

```dart
class EvidenceCommentDto {
  final int id;
  final String authorName;
  final String? authorAvatar;
  final bool isInstructor;
  final String content;
  final DateTime createdAt;
}
```

---

## 10. Project

**Entity**: `DAL/Models/Project.cs`
**Table**: `Projects`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | URL params | — |
| `ClassId` | int | FK | — |
| `Title` | string | SCR-L26 (list), SCR-L27 (header), SCR-I12 | ListTile title, AppBarWidget |
| `Description` | string? | SCR-L27 (description card), SCR-I13 | Text, AppTextField |
| `MilestoneCount` | *(computed)* | SCR-L26 ("4 milestones") | Text |
| `NextDueDate` | *(computed)* | SCR-L26 | Text ("Due: 20/06") |
| `CompletedMilestones` | *(computed)* | SCR-L27, SCR-L39 | Stepper progress |

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/projects?classId={id}` | SCR-L26, SCR-I12 |
| GET | `/api/projects/{id}` | SCR-L27 |
| POST | `/api/projects` | SCR-I13 |
| PUT | `/api/projects/{id}` | SCR-I13 |
| DELETE | `/api/projects/{id}` | SCR-I12 |

---

## 11. Milestone

**Entity**: `DAL/Models/Milestone.cs`
**Table**: `Milestones`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | URL params | — |
| `ProjectId` | int | FK | — |
| `Title` | string | SCR-L27 (stepper), SCR-L28 (list), SCR-L29 (header), SCR-I14 | **MilestoneCard** title |
| `Description` | string? | SCR-L29 (detail body), SCR-I14 | Text |
| `DueDate` | DateTime? | SCR-L28, SCR-L29, SCR-I14 | MilestoneCard "Due: 20/06/2026" |
| `IsSubmitted` | *(computed)* | SCR-L28, SCR-L27 | MilestoneCard (✓ Đã nộp / ○ Chưa nộp) |
| `StepNumber` | *(computed = index+1)* | SCR-L27, SCR-L28 | MilestoneCard step ①②③④ |

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/milestones?projectId={id}` | SCR-L28, SCR-I14 |
| GET | `/api/milestones/{id}` | SCR-L29 |
| POST | `/api/milestones` | SCR-I14 |
| PUT | `/api/milestones/{id}` | SCR-I14 |
| DELETE | `/api/milestones/{id}` | SCR-I14 |

---

## 12. MilestoneSubmission

**Entity**: `DAL/Models/MilestoneSubmission.cs`
**Table**: `MilestoneSubmissions`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | — | — |
| `MilestoneId` | int | FK | — |
| `UserId` | int | FK | — |
| `FileUrl` | string? | SCR-L30 (file picker preview) | FilePickerWidget |
| `Description` | string? | SCR-L30 (input), SCR-L29 (view if submitted) | AppTextField (5 lines), Text |
| `SubmittedAt` | DateTime | SCR-L29 (if submitted: "Đã nộp lúc …") | Text |

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/milestone-submissions?milestoneId={id}&userId=me` | SCR-L29 |
| POST | `/api/milestone-submissions` (multipart) | SCR-L30 |

---

## 13. ReviewSession

**Entity**: `DAL/Models/ReviewSession.cs`
**Table**: `ReviewSessions`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | URL params | — |
| `ClassId` | int | FK | — |
| `Title` | string | SCR-L31 (list), SCR-L32 (header), SCR-I15 | ListTile title |
| `StartDate` | DateTime | SCR-L31, SCR-I15 | "Từ: 21/06/2026" |
| `EndDate` | DateTime | SCR-L31, SCR-I15 | "Đến: 23/06/2026" |
| `IsOpen` | *(computed)* | SCR-L31 | Badge "Open" (green) / "Closed" (grey) |
| `AssignmentCount` | *(computed)* | SCR-L32 | Text "Cần review 1 bạn" |

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/review-sessions?classId={id}` | SCR-L31, SCR-I15 |
| GET | `/api/review-sessions/{id}` | SCR-L32 |
| POST | `/api/review-sessions` | SCR-I15 (create + auto-assign) |
| DELETE | `/api/review-sessions/{id}` | SCR-I15 |

---

## 14. ReviewAssignment

**Entity**: `DAL/Models/ReviewAssignment.cs`
**Table**: `ReviewAssignments`
**Special**: 2 FK đến User (ReviewerId + RevieweeId) → `DeleteBehavior.NoAction`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | URL params | — |
| `SessionId` | int | FK | — |
| `ReviewerId` | int | FK | — |
| `RevieweeId` | int | FK | — |
| Reviewer.FullName | *(join)* | SCR-I16 | ListTile "Reviewer → Reviewee" |
| Reviewee.FullName | *(join)* | SCR-L32, SCR-L33, SCR-I16 | ListTile, AppBar "Đánh giá: [Name]" |
| `HasFeedback` | *(computed)* | SCR-L32, SCR-I16 | Badge "Done ✓" / "Pending ○" |

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/review-assignments?sessionId={id}&reviewerId=me` | SCR-L32 (my assignments) |
| GET | `/api/review-assignments?sessionId={id}` | SCR-I16 (all assignments) |

---

## 15. Feedback

**Entity**: `DAL/Models/Feedback.cs`
**Table**: `Feedbacks`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | — | — |
| `AssignmentId` | int | FK | — |
| `Content` | string | SCR-L33 (input), SCR-L34 (display) | AppTextField (6 lines), Text Card |
| `Rating` | int | SCR-L33 (star input), SCR-L34 (star display), SCR-I20 (avg) | **RatingBar** (interactive / readonly) |
| `CreatedAt` | DateTime | SCR-L34 | Text timestamp |
| Reviewer.FullName | *(join)* | SCR-L34 | CommentTile-style reviewer info |
| Reviewer.AvatarUrl | *(join)* | SCR-L34 | CircleAvatar |

**Rating display**: 1–5 stars | Color: `#F59E0B` | SCR-I20 shows average rating of class

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| POST | `/api/feedbacks` | SCR-L33 |
| GET | `/api/feedbacks/received?assignmentId={id}` | SCR-L34 |
| GET | `/api/feedbacks?sessionId={id}` | SCR-I16 (monitoring) |

---

## 16. Notification

**Entity**: `DAL/Models/Notification.cs`
**Table**: `Notifications`

### Fields → UI Mapping

| Field | Type | Hiển thị tại Screen | Component |
|-------|------|---------------------|-----------|
| `Id` | int | — | — |
| `UserId` | int | FK | — |
| `Title` | string | SCR-L06 (list), SCR-L05 (badge count) | **NotificationCard** title |
| `Body` | string | SCR-L06 | NotificationCard subtitle |
| `IsRead` | bool | SCR-L06 (bg color), SCR-L05 (badge count) | NotificationCard: unread=`#EEF2FF` bg, AppBarWidget badge |
| `CreatedAt` | DateTime | SCR-L06 | "08/06 · 15:00" |

**Unread badge** (AppBarWidget):
- Count unread → hiển thị `🔔 2` trên AppBar của HomeScreen
- Tự động giảm khi tap vào notification

### API Endpoints

| Method | Path | Dùng bởi Screen |
|--------|------|-----------------|
| GET | `/api/notifications` | SCR-L06, SCR-L05 (count only) |
| GET | `/api/notifications/unread-count` | SCR-L05 AppBar badge |
| PUT | `/api/notifications/{id}/read` | SCR-L06 (tap notification) |
| PUT | `/api/notifications/read-all` | SCR-L06 (mark all read button) |

---

## Reverse Map: Screen → Entities

| Screen | Entities Read | Entities Write |
|--------|--------------|----------------|
| SCR-L01 Splash | User (token check) | — |
| SCR-L02 Login | — | User (auth) |
| SCR-L03 Register | — | User |
| SCR-L05 Home | Course, Activity, Notification | — |
| SCR-L06 Notifications | Notification | Notification (IsRead) |
| SCR-L07 My Courses | Course | — |
| SCR-L08 Course Detail | Course, Class | — |
| SCR-L09 Class Detail | Class, LearningPath, Project, ReviewSession | — |
| SCR-L10 Members | ClassMember, User | — |
| SCR-L11 Learning Path Overview | LearningPath, Activity, ActivitySubmission | — |
| SCR-L12 Week Detail | LearningPath, Activity, LearningMaterial, ActivitySubmission | — |
| SCR-L13 Materials List | LearningMaterial | — |
| SCR-L14 Material Detail | LearningMaterial | — |
| SCR-L15 Video Player | LearningMaterial | — |
| SCR-L16 Document Viewer | LearningMaterial | — |
| SCR-L17 Pre-Class List | Activity, ActivitySubmission | — |
| SCR-L18 Activity Detail | Activity, ActivitySubmission | — |
| SCR-L19 Submit Evidence (Pre) | Activity | **ActivitySubmission** |
| SCR-L20 In-Class List | Activity, ActivitySubmission | — |
| SCR-L21 Activity Detail (In) | Activity, ActivitySubmission | — |
| SCR-L22 Submit Evidence (In) | Activity | **ActivitySubmission** |
| SCR-L23 Post-Class List | Activity, ActivitySubmission | — |
| SCR-L24 Activity Detail (Post) | Activity, ActivitySubmission | — |
| SCR-L25 Submit Reflection | Activity | **ActivitySubmission** |
| SCR-L26 Project List | Project, Milestone | — |
| SCR-L27 Project Detail | Project, Milestone, MilestoneSubmission | — |
| SCR-L28 Milestone List | Milestone, MilestoneSubmission | — |
| SCR-L29 Milestone Detail | Milestone, MilestoneSubmission | — |
| SCR-L30 Submit Milestone | Milestone | **MilestoneSubmission** |
| SCR-L31 Review Sessions | ReviewSession | — |
| SCR-L32 Review Detail | ReviewSession, ReviewAssignment, Feedback | — |
| SCR-L33 Submit Feedback | ReviewAssignment | **Feedback** |
| SCR-L34 Received Feedback | Feedback, ReviewAssignment, User | — |
| SCR-L35 Evidence Detail | ActivitySubmission | — |
| SCR-L36 Evidence Comments | EvidenceComment, User | **EvidenceComment** |
| SCR-L37 Learning Progress | Course, Activity, ActivitySubmission | — |
| SCR-L38 Activity Completion | Activity, ActivitySubmission | — |
| SCR-L39 Project Progress | Milestone, MilestoneSubmission | — |
| SCR-L40 Profile | User | — |
| SCR-L41 Edit Profile | — | **User** |
| SCR-I01 Dashboard | Course, Class, ActivitySubmission, Notification | — |
| SCR-I02 Manage Courses | Course | Course (delete) |
| SCR-I03 Create/Edit Course | — | **Course** |
| SCR-I04 Manage Classes | Class | Class |
| SCR-I05 Class Members | ClassMember, User | ClassMember |
| SCR-I06 Learning Path List | LearningPath | LearningPath (delete) |
| SCR-I07 Create/Edit Path | — | **LearningPath** |
| SCR-I08 Manage Materials | LearningMaterial | LearningMaterial (delete) |
| SCR-I09 Upload Material | — | **LearningMaterial** |
| SCR-I10 Manage Activities | Activity | Activity (delete) |
| SCR-I11 Create/Edit Activity | — | **Activity** |
| SCR-I12 Manage Projects | Project | Project (delete) |
| SCR-I13 Create/Edit Project | — | **Project** |
| SCR-I14 Manage Milestones | Milestone | **Milestone** |
| SCR-I15 Review Sessions | ReviewSession | **ReviewSession** |
| SCR-I16 Review Monitoring | ReviewSession, ReviewAssignment, Feedback | — |
| SCR-I17 Evidence List | ActivitySubmission, User, Activity | — |
| SCR-I18 Evidence Detail | ActivitySubmission, EvidenceComment | ActivitySubmission (Status) |
| SCR-I19 Comment & Feedback | EvidenceComment, User | **EvidenceComment** |
| SCR-I20 Analytics | Course, Activity, ActivitySubmission, Feedback | — |
| SCR-I21 Student Progress | User, Activity, ActivitySubmission | — |

---

## API Contract Summary

> Đây là danh sách **tất cả API cần implement** phân theo entity, với screen nào cần.

### Auth

| # | Method | Path | Screens |
|---|--------|------|---------|
| 1 | POST | `/api/auth/register` | L03 |
| 2 | POST | `/api/auth/login` | L02 |
| 3 | GET | `/api/users/me` | L40, I01 |
| 4 | PUT | `/api/users/me` | L41 |

### Course

| # | Method | Path | Screens |
|---|--------|------|---------|
| 5 | GET | `/api/courses/my` | L05, L07, I02 |
| 6 | GET | `/api/courses/{id}` | L08 |
| 7 | POST | `/api/courses` | I03 |
| 8 | PUT | `/api/courses/{id}` | I03 |
| 9 | DELETE | `/api/courses/{id}` | I02 |

### Class & Members

| # | Method | Path | Screens |
|---|--------|------|---------|
| 10 | GET | `/api/classes?courseId={id}` | L08, I04 |
| 11 | GET | `/api/classes/{id}` | L09 |
| 12 | POST | `/api/classes` | I04 |
| 13 | PUT | `/api/classes/{id}` | I04 |
| 14 | DELETE | `/api/classes/{id}` | I04 |
| 15 | GET | `/api/classes/{id}/members` | L10, I05 |
| 16 | POST | `/api/classes/{id}/members` | I05 |
| 17 | DELETE | `/api/classes/{classId}/members/{userId}` | I05 |

### Learning Path & Materials

| # | Method | Path | Screens |
|---|--------|------|---------|
| 18 | GET | `/api/learning-paths?classId={id}` | L11, I06 |
| 19 | GET | `/api/learning-paths/{id}` | L12 |
| 20 | POST | `/api/learning-paths` | I07 |
| 21 | PUT | `/api/learning-paths/{id}` | I07 |
| 22 | DELETE | `/api/learning-paths/{id}` | I06 |
| 23 | GET | `/api/materials?pathId={id}` | L13, I08 |
| 24 | GET | `/api/materials/{id}` | L14 |
| 25 | POST | `/api/materials` | I09 |
| 26 | PUT | `/api/materials/{id}` | I08 |
| 27 | DELETE | `/api/materials/{id}` | I08 |

### Activities

| # | Method | Path | Screens |
|---|--------|------|---------|
| 28 | GET | `/api/activities?pathId={id}&type=PreClass` | L17 |
| 29 | GET | `/api/activities?pathId={id}&type=InClass` | L20 |
| 30 | GET | `/api/activities?pathId={id}&type=PostClass` | L23 |
| 31 | GET | `/api/activities/{id}` | L18, L21, L24 |
| 32 | GET | `/api/activities/upcoming?classId={id}` | L05 |
| 33 | POST | `/api/activities` | I11 |
| 34 | PUT | `/api/activities/{id}` | I11 |
| 35 | DELETE | `/api/activities/{id}` | I10 |

### Evidence & Comments

| # | Method | Path | Screens |
|---|--------|------|---------|
| 36 | GET | `/api/evidences?classId={id}&status=Pending` | I17 |
| 37 | GET | `/api/evidences?activityId={id}&userId=me` | L17, L20, L23 |
| 38 | GET | `/api/evidences/{id}` | L35, I18 |
| 39 | POST | `/api/evidences` | L19, L22, L25 |
| 40 | PUT | `/api/evidences/{id}/approve` | I18 |
| 41 | PUT | `/api/evidences/{id}/reject` | I18 |
| 42 | GET | `/api/evidences/{id}/comments` | L36, I19 |
| 43 | POST | `/api/evidences/{id}/comments` | L36, I19 |

### Projects & Milestones

| # | Method | Path | Screens |
|---|--------|------|---------|
| 44 | GET | `/api/projects?classId={id}` | L26, I12 |
| 45 | GET | `/api/projects/{id}` | L27 |
| 46 | POST | `/api/projects` | I13 |
| 47 | PUT | `/api/projects/{id}` | I13 |
| 48 | DELETE | `/api/projects/{id}` | I12 |
| 49 | GET | `/api/milestones?projectId={id}` | L28, I14 |
| 50 | GET | `/api/milestones/{id}` | L29 |
| 51 | POST | `/api/milestones` | I14 |
| 52 | PUT | `/api/milestones/{id}` | I14 |
| 53 | DELETE | `/api/milestones/{id}` | I14 |
| 54 | GET | `/api/milestone-submissions?milestoneId={id}&userId=me` | L29 |
| 55 | POST | `/api/milestone-submissions` | L30 |

### Review & Feedback

| # | Method | Path | Screens |
|---|--------|------|---------|
| 56 | GET | `/api/review-sessions?classId={id}` | L31, I15 |
| 57 | GET | `/api/review-sessions/{id}` | L32 |
| 58 | POST | `/api/review-sessions` | I15 |
| 59 | DELETE | `/api/review-sessions/{id}` | I15 |
| 60 | GET | `/api/review-assignments?sessionId={id}&reviewerId=me` | L32 |
| 61 | GET | `/api/review-assignments?sessionId={id}` | I16 |
| 62 | POST | `/api/feedbacks` | L33 |
| 63 | GET | `/api/feedbacks/received?assignmentId={id}` | L34 |
| 64 | GET | `/api/feedbacks?sessionId={id}` | I16 |

### Analytics & Notifications

| # | Method | Path | Screens |
|---|--------|------|---------|
| 65 | GET | `/api/analytics/my-progress` | L37, L38, L39 |
| 66 | GET | `/api/analytics/class/{classId}` | I20 |
| 67 | GET | `/api/analytics/student/{userId}?classId={id}` | I21 |
| 68 | GET | `/api/notifications` | L06 |
| 69 | GET | `/api/notifications/unread-count` | L05 (badge) |
| 70 | PUT | `/api/notifications/{id}/read` | L06 |
| 71 | PUT | `/api/notifications/read-all` | L06 |

---

**Tổng số API**: 71 endpoints | **Tổng screens**: 62 | **Entities**: 16
