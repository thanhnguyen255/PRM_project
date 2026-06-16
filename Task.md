# 🗓️ Agile Sprint Plan — Flipped Classroom App (Fullstack)
> **Team**: 2 người fullstack | **Mô hình**: Agile Scrum | **2 Sprint × 2 tuần**  
> **Tech Stack**: Flutter · ASP.NET Core · SQL Server

---

## 📋 Nguyên tắc phân chia

> [!IMPORTANT]
> Chia theo **Feature (tính năng)**, không chia theo layer.  
> Mỗi người sở hữu **end-to-end** một nhóm tính năng: tự làm API → ViewModel → UI → Test.  
> Tránh conflict khi 2 người cùng sửa 1 file.

| | Member A | Member B |
|---|---|---|
| **Phụ trách** | Auth + Learner core flow | Instructor tools + Admin features |
| **Backend** | Controller/Service của feature mình | Controller/Service của feature mình |
| **Frontend** | Screens/ViewModel của feature mình | Screens/ViewModel của feature mình |

---

## 🏃 Sprint 1 — Nền tảng & Core (Tuần 1–2)

**Sprint Goal**: Learner đăng nhập, xem lớp học, duyệt tài liệu. Instructor tạo nội dung.

---

### Member A — Auth + Learner Flow (Fullstack)

#### Backend (ASP.NET Core)
| # | Task | Ngày |
|---|------|------|
| A1.1 | Setup project chung: ASP.NET Core, EF Core, SQL Server, Swagger, JWT middleware | 0.5 |
| A1.2 | Migration: bảng `User` | 0.5 |
| A1.3 | `AuthController`: `POST /auth/register`, `POST /auth/login`, `POST /auth/forgot-password` | 1.5 |
| A1.4 | Migration: `Class`, `ClassMember` | 0.5 |
| A1.5 | `ClassController` (Learner): `GET /classes` (của learner), `GET /classes/:id`, `GET /classes/:id/members` | 1 |
| A1.6 | `LearningPathController` (Learner): `GET /classes/:id/paths`, `GET /paths/:id` | 0.5 |
| A1.7 | `MaterialController` (Learner): `GET /paths/:id/materials` | 0.5 |
| A1.8 | `ActivityController` (Learner): `GET /paths/:id/activities`, `GET /activities/:id` | 0.5 |
| A1.9 | `NotificationController`: `GET /notifications`, `PUT /notifications/read-all`, `PUT /notifications/:id/read` | 0.5 |
| A1.10 | `ProfileController`: `GET /profile`, `PUT /profile` | 0.5 |

#### Frontend (Flutter)
| # | Task | Ngày |
|---|------|------|
| A1.11 | Setup: xóa `app.dart`, cấu hình `ApiService` base URL, SharedPreferences token | 0.5 |
| A1.12 | `SplashScreen` auto-login thật, `LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen` | 1.5 |
| A1.13 | `HomeScreen` (Learner): danh sách lớp từ API, CourseDetailScreen | 1 |
| A1.14 | `ClassDetailScreen`: thông tin lớp, tiến độ, quick actions — API thật | 0.5 |
| A1.15 | `MembersScreen`: thành viên từ API | 0.5 |
| A1.16 | `LearningPathScreen` + `LearningPathDetailScreen`: tuần học + tab Pre/In/Post | 1 |
| A1.17 | `MaterialsScreen`: danh sách tài liệu, `VideoPlayerScreen`, `DocumentViewerScreen` | 1 |
| A1.18 | `PreClassActivityScreen`, `InClassActivityScreen`, `PostClassActivityScreen` | 1 |
| A1.19 | `NotificationsScreen`: API thật, mark read | 0.5 |
| A1.20 | `ProfileScreen` + `EditProfileScreen`: xem/sửa thông tin thật | 0.5 |

**Tổng A: ~12 ngày công**

---

### Member B — Instructor Tools (Fullstack)

#### Backend (ASP.NET Core)
| # | Task | Ngày |
|---|------|------|
| B1.1 | Migration: bảng `Course` | 0.5 |
| B1.2 | `CourseController`: `GET /courses` (của instructor), `GET /courses/:id`, `POST /courses`, `PUT /courses/:id`, `DELETE /courses/:id` | 1 |
| B1.3 | `ClassController` (Instructor): `POST /classes`, `POST /classes/:id/members`, `DELETE /classes/:id/members/:uid` | 1 |
| B1.4 | Migration: `LearningPath`, `LearningMaterial`, `Activity` | 0.5 |
| B1.5 | `LearningPathController` (Instructor): `POST /paths`, `DELETE /paths/:id` | 0.5 |
| B1.6 | `MaterialController` (Instructor): `POST /materials`, `DELETE /materials/:id` | 0.5 |
| B1.7 | `ActivityController` (Instructor): `POST /activities`, `PUT /activities/:id`, `DELETE /activities/:id` | 1 |
| B1.8 | Migration: `ActivitySubmission`, `EvidenceComment` | 0.5 |
| B1.9 | `EvidenceController` (Instructor): `GET /evidences?classId=X`, `GET /evidences/:id`, `PUT /evidences/:id/status` (approve/reject) | 1 |
| B1.10 | `EvidenceCommentController`: `GET /evidences/:id/comments`, `POST /evidences/:id/comments` | 0.5 |

#### Frontend (Flutter)
| # | Task | Ngày |
|---|------|------|
| B1.11 | `InstructorDashboardScreen`: tab layout, thống kê nhanh | 0.5 |
| B1.12 | `ManageCoursesTab` + `CreateEditCourseScreen`: CRUD course thật | 1 |
| B1.13 | `ManageClassesScreen` + tạo lớp + thêm/xóa thành viên | 1 |
| B1.14 | `ManageLearningPathsScreen`: tạo tuần, upload tài liệu | 1 |
| B1.15 | `ManageActivitiesScreen`: tạo activity Pre/In/Post-class, deadline | 1 |
| B1.16 | `EvidenceDetailScreen` (Instructor): xem evidence, Approve/Reject | 1 |
| B1.17 | Evidence list cho instructor: lọc theo trạng thái (Pending/Approved/Rejected) | 0.5 |
| B1.18 | `EvidenceCommentsScreen`: bình luận thật (cả learner lẫn instructor xài chung screen) | 0.5 |

**Tổng B: ~12.5 ngày công**

---

### 🎯 Sprint 1 — Definition of Done

- [ ] Learner đăng nhập → thấy lớp học từ DB thật
- [ ] Learner duyệt tài liệu video/PDF
- [ ] Learner xem hoạt động Pre/In/Post-class
- [ ] Instructor tạo course → class → learning path → activity
- [ ] Instructor xem và duyệt evidence
- [ ] Không crash khi không có data hoặc lỗi mạng

---

## 🏃 Sprint 2 — Tính năng nâng cao (Tuần 3–4)

**Sprint Goal**: Nộp evidence file thật, Peer review, Projects, Analytics.

---

### Member A — Evidence Submission + Progress (Fullstack)

#### Backend (ASP.NET Core)
| # | Task | Ngày |
|---|------|------|
| A2.1 | `EvidenceController` (Learner): `POST /evidences` (submit với file upload — `IFormFile`), `GET /activities/:id/my-evidence`, `GET /evidences/:id` | 1.5 |
| A2.2 | File storage: lưu file vào server hoặc cloud (Azure Blob / local), trả về URL | 1 |
| A2.3 | Trigger notification khi Instructor approve/reject (gọi từ `EvidenceController`) | 0.5 |
| A2.4 | `AnalyticsController`: `GET /analytics/my-progress?classId=X` (% hoàn thành, activity breakdown) | 1 |
| A2.5 | `AnalyticsController`: `GET /analytics/class/:id` (thống kê lớp), `GET /analytics/class/:id/student/:uid` | 1 |
| A2.6 | Fix bugs Sprint 1, optimize query N+1, thêm pagination nếu cần | 1 |

#### Frontend (Flutter)
| # | Task | Ngày |
|---|------|------|
| A2.7 | `SubmitEvidenceScreen`: tích hợp `file_picker` / `image_picker` thật, upload multipart | 1.5 |
| A2.8 | `LearnerEvidenceDetailScreen`: xem evidence đã nộp, trạng thái, link file | 0.5 |
| A2.9 | `ProgressScreen`: % hoàn thành thật, danh sách activity theo trạng thái | 1 |
| A2.10 | `ClassAnalyticsScreen` (Instructor): biểu đồ tỷ lệ lớp học (dùng `fl_chart` hoặc bảng đơn giản) | 1 |
| A2.11 | Kết nối notification: badge count trên icon, auto refresh | 0.5 |
| A2.12 | Bug fix Sprint 1 (Auth edge cases, loading states, empty states) | 1 |

**Tổng A Sprint 2: ~10.5 ngày công**

---

### Member B — Projects + Peer Review (Fullstack)

#### Backend (ASP.NET Core)
| # | Task | Ngày |
|---|------|------|
| B2.1 | Migration: `Project`, `Milestone`, `MilestoneSubmission` | 0.5 |
| B2.2 | `ProjectController`: `GET /projects?classId=X`, `GET /projects/:id`, `POST /projects`, `DELETE /projects/:id` | 1 |
| B2.3 | `MilestoneController`: `GET /projects/:id/milestones`, `POST /milestones`, `DELETE /milestones/:id`, `POST /milestones/:id/submit` | 1 |
| B2.4 | Migration: `ReviewSession`, `ReviewAssignment`, `Feedback` | 0.5 |
| B2.5 | `ReviewSessionController`: `POST /review-sessions`, `GET /review-sessions?classId=X`, `GET /review-sessions/:id`, `POST /review-sessions/:id/assign` | 1.5 |
| B2.6 | `FeedbackController`: `GET /assignments/:id`, `POST /assignments/:id/feedback`, `GET /sessions/:id/my-assignments`, `GET /sessions/:id/received-feedback` | 1 |
| B2.7 | `ReviewMonitorController`: `GET /review-sessions/:id/monitor` (ai đã review, ai chưa) | 0.5 |

#### Frontend (Flutter)
| # | Task | Ngày |
|---|------|------|
| B2.8 | `LearnerProjectsScreen`: danh sách project + milestones từ API | 1 |
| B2.9 | `LearnerProjectDetailScreen`: chi tiết project, submit milestone thật | 1 |
| B2.10 | `ManageProjectsScreen` (Instructor): tạo project + milestone | 0.5 |
| B2.11 | `ReviewSessionsScreen` (Learner): danh sách session, xem người cần review | 1 |
| B2.12 | `ReviewDetailScreen`: xem evidence của người được review, gửi feedback (rating + comment) | 1.5 |
| B2.13 | `SubmitFeedbackScreen`: form rating sao + textarea | 0.5 |
| B2.14 | `InstructorReviewScreen`: tạo session, phân công | 0.5 |
| B2.15 | `ReviewMonitorScreen`: bảng trạng thái ai đã/chưa review | 0.5 |

**Tổng B Sprint 2: ~11.5 ngày công**

---

### 🎯 Sprint 2 — Definition of Done

- [ ] Learner nộp evidence với file ảnh/PDF thật
- [ ] Instructor approve → Learner nhận notification
- [ ] Learner xem và nộp milestone project
- [ ] Learner tham gia peer review, gửi feedback có rating
- [ ] Instructor xem monitoring peer review
- [ ] ProgressScreen hiển thị % chính xác từ DB

---

## 📊 Timeline tổng quan

```
         Tuần 1–2 (Sprint 1)           Tuần 3–4 (Sprint 2)
         ─────────────────────          ─────────────────────
Member A  Auth + Learner UI/API    →    Evidence submit + Progress
Member B  Instructor UI/API        →    Projects + Peer Review

Shared:   Setup project (ngày 1)        Fix bugs, integration test
```

---

## 🔄 Agile Ceremonies

| Event | Khi nào | Thời gian |
|-------|---------|-----------|
| **Sprint Planning** | Thứ 2 đầu sprint | 1 giờ |
| **Daily Standup** | Mỗi ngày sáng | 10 phút |
| **Sprint Review / Demo** | Thứ 6 tuần 2 và 4 | 30 phút |
| **Retrospective** | Sau Review | 20 phút |

---

## 📁 Tránh conflict — Quy ước code

| Quy tắc | Chi tiết |
|---------|---------|
| **Backend** | A và B làm Controller riêng, không đụng nhau |
| **Frontend** | A làm screens `learner/`, B làm screens `instructor/` |
| **Shared** | `widgets/`, `viewmodels/`, `config/` — ai sửa thì báo team trước |
| **Git** | Mỗi người 1 branch: `feature/member-a` và `feature/member-b`, merge cuối sprint |

---

## ⚠️ Rủi ro & Xử lý

| Rủi ro | Giải pháp |
|--------|-----------|
| File upload phức tạp (multipart) | A làm tuần 3 sớm nhất, dùng mock URL tạm nếu cần |
| B chưa có API, frontend bị block | Dùng `json` hard-coded tạm, define response schema trước |
| DB migration conflict | Chạy migration theo thứ tự: A làm `User`, B làm `Course` → merge → tiếp tục |
| Thời gian Sprint 2 không đủ | Cắt: Analytics (A2.5) và ReviewMonitor (B2.15) làm sau nếu cần |
