# Kiến Trúc Tổng Thể — Flipped Classroom App

> **Stack**: Flutter (MVVM + Provider) ↔ ASP.NET Core (3-Layer) ↔ SQL Server

---

## 1. Sơ Đồ Hệ Thống

```
┌─────────────────────────────────────────────────────────────────────┐
│                       FLUTTER MOBILE APP                            │
│                                                                     │
│   screens/          viewmodels/        services/       models/      │
│  ┌──────────┐      ┌────────────┐    ┌───────────┐   ┌──────────┐  │
│  │  View    │◄────►│ ViewModel  │───►│  Service  │──►│  Model   │  │
│  │ (UI only)│      │(state+logic│    │ (Dio HTTP)│   │  (JSON)  │  │
│  └──────────┘      └────────────┘    └───────────┘   └──────────┘  │
└────────────────────────────────┬────────────────────────────────────┘
                                 │  HTTPS + JWT
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   ASP.NET CORE WEB API — 3 LAYER                    │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  PRM393.API  — Controllers + Middleware                        │  │
│  │  Nhận HTTP request → gọi BLL → trả JSON response             │  │
│  └──────────────────────────┬────────────────────────────────────┘  │
│                             │                                       │
│  ┌──────────────────────────▼────────────────────────────────────┐  │
│  │  PRM393.BLL  — Services + DTOs + Interfaces                   │  │
│  │  Xử lý nghiệp vụ, validate dữ liệu, tạo JWT                  │  │
│  └──────────────────────────┬────────────────────────────────────┘  │
│                             │                                       │
│  ┌──────────────────────────▼────────────────────────────────────┐  │
│  │  PRM393.DAL  — Repositories + EF Core + Models + DbContext    │  │
│  │  Truy vấn database, không biết gì về business logic           │  │
│  └──────────────────────────┬────────────────────────────────────┘  │
└─────────────────────────────┼───────────────────────────────────────┘
                              │  Entity Framework Core
                              ▼
                    ┌──────────────────────┐
                    │      SQL SERVER       │
                    │  (Local / Azure SQL)  │
                    └──────────────────────┘
```

---

## 2. Backend — Cấu Trúc 3 Projects

```
backend/
├── PRM393.sln
│
├── PRM393.API/                           ← Layer 1: Presentation
│   ├── Controllers/
│   │   ├── AuthController.cs             # /api/auth
│   │   ├── CoursesController.cs          # /api/courses
│   │   ├── ClassesController.cs          # /api/classes
│   │   ├── LearningPathsController.cs    # /api/learning-paths
│   │   ├── MaterialsController.cs        # /api/materials
│   │   ├── ActivitiesController.cs       # /api/activities
│   │   ├── EvidencesController.cs        # /api/evidences
│   │   ├── ProjectsController.cs         # /api/projects
│   │   ├── MilestonesController.cs       # /api/milestones
│   │   ├── ReviewsController.cs          # /api/review-sessions
│   │   ├── NotificationsController.cs    # /api/notifications
│   │   └── AnalyticsController.cs        # /api/analytics
│   ├── Middleware/
│   │   └── ExceptionMiddleware.cs        # Bắt lỗi toàn cục → JSON
│   ├── Program.cs                        # DI, Swagger, JWT config
│   └── appsettings.json                  # Connection string, JWT key
│
├── PRM393.BLL/                           ← Layer 2: Business Logic
│   ├── DTOs/
│   │   ├── Auth/
│   │   │   ├── LoginRequestDto.cs
│   │   │   ├── LoginResponseDto.cs
│   │   │   └── RegisterRequestDto.cs
│   │   ├── Course/
│   │   │   ├── CourseDto.cs
│   │   │   └── CreateCourseDto.cs
│   │   ├── Class/
│   │   │   ├── ClassDto.cs
│   │   │   └── ClassMemberDto.cs
│   │   ├── LearningPath/
│   │   ├── Activity/
│   │   │   ├── ActivityDto.cs
│   │   │   └── SubmitEvidenceDto.cs
│   │   ├── Evidence/
│   │   ├── Project/
│   │   │   ├── ProjectDto.cs
│   │   │   └── MilestoneDto.cs
│   │   ├── Review/
│   │   │   ├── ReviewSessionDto.cs
│   │   │   └── FeedbackDto.cs
│   │   └── Notification/
│   ├── Services/
│   │   ├── AuthService.cs                # Login, Register, JWT
│   │   ├── CourseService.cs
│   │   ├── ClassService.cs
│   │   ├── LearningPathService.cs
│   │   ├── MaterialService.cs
│   │   ├── ActivityService.cs
│   │   ├── EvidenceService.cs
│   │   ├── ProjectService.cs
│   │   ├── ReviewService.cs
│   │   ├── NotificationService.cs
│   │   └── AnalyticsService.cs
│   ├── Interfaces/
│   │   ├── IAuthService.cs
│   │   ├── ICourseService.cs
│   │   ├── IClassService.cs
│   │   ├── IActivityService.cs
│   │   ├── IEvidenceService.cs
│   │   ├── IProjectService.cs
│   │   ├── IReviewService.cs
│   │   └── IAnalyticsService.cs
│   └── Helpers/
│       ├── JwtHelper.cs                  # Tạo & verify JWT token
│       └── PasswordHelper.cs             # BCrypt hash password
│
└── PRM393.DAL/                           ← Layer 3: Data Access
    ├── Models/                           # EF Core entities (ánh xạ DB)
    │   ├── User.cs
    │   ├── Course.cs
    │   ├── Class.cs
    │   ├── ClassMember.cs
    │   ├── LearningPath.cs
    │   ├── LearningMaterial.cs
    │   ├── Activity.cs
    │   ├── ActivitySubmission.cs
    │   ├── EvidenceComment.cs
    │   ├── Project.cs
    │   ├── Milestone.cs
    │   ├── MilestoneSubmission.cs
    │   ├── ReviewSession.cs
    │   ├── ReviewAssignment.cs
    │   ├── Feedback.cs
    │   └── Notification.cs
    ├── Enums/
    │   ├── UserRole.cs                   # Learner = 0, Instructor = 1
    │   ├── ActivityType.cs               # PreClass, InClass, PostClass
    │   ├── EvidenceStatus.cs             # Pending, Approved, Rejected
    │   └── MaterialType.cs               # Video, Document, Link
    ├── Repositories/
    │   ├── GenericRepository.cs          # CRUD dùng chung
    │   ├── UserRepository.cs
    │   ├── CourseRepository.cs
    │   ├── ClassRepository.cs
    │   ├── ActivityRepository.cs
    │   ├── EvidenceRepository.cs
    │   ├── ProjectRepository.cs
    │   └── ReviewRepository.cs
    ├── Interfaces/
    │   ├── IGenericRepository.cs
    │   └── IUnitOfWork.cs
    ├── UnitOfWork.cs                     # Quản lý transaction
    └── AppDbContext.cs                   # EF Core DbContext
```

### Quy tắc phụ thuộc

```
PRM393.API  ──►  PRM393.BLL  ──►  PRM393.DAL
   (không được gọi DAL trực tiếp)
```

---

## 3. Frontend — Cấu Trúc Flutter (MVVM + Provider)

```
lib/
│
├── main.dart                             # Entry + MultiProvider setup
├── app.dart                              # MaterialApp + named routes
│
├── config/
│   ├── app_colors.dart                   # Bảng màu toàn app
│   ├── app_theme.dart                    # ThemeData (light/dark)
│   └── api_config.dart                   # Base URL + endpoint constants
│
├── models/                               # JSON ↔ Dart (fromJson / toJson)
│   ├── user_model.dart
│   ├── course_model.dart
│   ├── class_model.dart
│   ├── learning_path_model.dart
│   ├── material_model.dart
│   ├── activity_model.dart
│   ├── evidence_model.dart
│   ├── project_model.dart
│   ├── milestone_model.dart
│   ├── review_model.dart
│   └── notification_model.dart
│
├── services/                             # Gọi API bằng Dio
│   ├── api_service.dart                  # Dio base + JWT interceptor
│   ├── auth_service.dart
│   ├── course_service.dart
│   ├── class_service.dart
│   ├── learning_path_service.dart
│   ├── material_service.dart
│   ├── activity_service.dart
│   ├── evidence_service.dart
│   ├── project_service.dart
│   ├── review_service.dart
│   └── notification_service.dart
│
├── viewmodels/                           # State (ChangeNotifier)
│   ├── auth_viewmodel.dart
│   ├── course_viewmodel.dart
│   ├── class_viewmodel.dart
│   ├── learning_path_viewmodel.dart
│   ├── activity_viewmodel.dart
│   ├── evidence_viewmodel.dart
│   ├── project_viewmodel.dart
│   ├── review_viewmodel.dart
│   └── notification_viewmodel.dart
│
├── screens/
│   ├── auth/
│   │   ├── splash_screen.dart            # SCR-L01
│   │   ├── login_screen.dart             # SCR-L02
│   │   ├── register_screen.dart          # SCR-L03
│   │   └── forgot_password_screen.dart   # SCR-L04
│   │
│   ├── learner/
│   │   ├── home_screen.dart              # SCR-L05
│   │   ├── notifications_screen.dart     # SCR-L06
│   │   ├── course/
│   │   │   ├── my_courses_screen.dart    # SCR-L07
│   │   │   ├── course_detail_screen.dart # SCR-L08
│   │   │   ├── class_detail_screen.dart  # SCR-L09
│   │   │   └── members_list_screen.dart  # SCR-L10
│   │   ├── learning_path/
│   │   │   ├── path_overview_screen.dart # SCR-L11
│   │   │   └── path_detail_screen.dart   # SCR-L12
│   │   ├── materials/
│   │   │   ├── materials_list_screen.dart  # SCR-L13
│   │   │   ├── material_detail_screen.dart # SCR-L14
│   │   │   ├── video_player_screen.dart    # SCR-L15
│   │   │   └── document_viewer_screen.dart # SCR-L16
│   │   ├── activities/
│   │   │   ├── pre_class/
│   │   │   │   ├── pre_class_list_screen.dart       # SCR-L17
│   │   │   │   ├── pre_class_detail_screen.dart     # SCR-L18
│   │   │   │   └── submit_pre_evidence_screen.dart  # SCR-L19
│   │   │   ├── in_class/
│   │   │   │   ├── in_class_list_screen.dart        # SCR-L20
│   │   │   │   ├── in_class_detail_screen.dart      # SCR-L21
│   │   │   │   └── submit_in_evidence_screen.dart   # SCR-L22
│   │   │   └── post_class/
│   │   │       ├── post_class_list_screen.dart      # SCR-L23
│   │   │       ├── post_class_detail_screen.dart    # SCR-L24
│   │   │       └── submit_reflection_screen.dart    # SCR-L25
│   │   ├── projects/
│   │   │   ├── project_list_screen.dart     # SCR-L26
│   │   │   ├── project_detail_screen.dart   # SCR-L27
│   │   │   ├── milestone_list_screen.dart   # SCR-L28
│   │   │   ├── milestone_detail_screen.dart # SCR-L29
│   │   │   └── submit_milestone_screen.dart # SCR-L30
│   │   ├── review/
│   │   │   ├── review_sessions_screen.dart   # SCR-L31
│   │   │   ├── review_detail_screen.dart     # SCR-L32
│   │   │   ├── submit_feedback_screen.dart   # SCR-L33
│   │   │   └── received_feedback_screen.dart # SCR-L34
│   │   ├── evidence/
│   │   │   ├── evidence_detail_screen.dart   # SCR-L35
│   │   │   └── evidence_comments_screen.dart # SCR-L36
│   │   ├── progress/
│   │   │   ├── learning_progress_screen.dart   # SCR-L37
│   │   │   ├── activity_completion_screen.dart # SCR-L38
│   │   │   └── project_progress_screen.dart    # SCR-L39
│   │   └── profile/
│   │       ├── profile_screen.dart             # SCR-L40
│   │       └── edit_profile_screen.dart        # SCR-L41
│   │
│   └── instructor/
│       ├── dashboard_screen.dart               # SCR-I01
│       ├── courses/
│       │   ├── manage_courses_screen.dart      # SCR-I02
│       │   └── create_edit_course_screen.dart  # SCR-I03
│       ├── classes/
│       │   ├── manage_classes_screen.dart      # SCR-I04
│       │   └── class_members_screen.dart       # SCR-I05
│       ├── learning_path/
│       │   ├── path_list_screen.dart           # SCR-I06
│       │   └── create_edit_path_screen.dart    # SCR-I07
│       ├── materials/
│       │   ├── manage_materials_screen.dart    # SCR-I08
│       │   └── upload_material_screen.dart     # SCR-I09
│       ├── activities/
│       │   ├── manage_activities_screen.dart     # SCR-I10
│       │   └── create_edit_activity_screen.dart  # SCR-I11
│       ├── projects/
│       │   ├── manage_projects_screen.dart       # SCR-I12
│       │   ├── create_edit_project_screen.dart   # SCR-I13
│       │   └── manage_milestones_screen.dart     # SCR-I14
│       ├── review/
│       │   ├── review_sessions_screen.dart       # SCR-I15
│       │   └── review_monitoring_screen.dart     # SCR-I16
│       ├── evidence_review/
│       │   ├── evidence_list_screen.dart         # SCR-I17
│       │   ├── evidence_detail_screen.dart       # SCR-I18
│       │   └── comment_feedback_screen.dart      # SCR-I19
│       └── analytics/
│           ├── learning_analytics_screen.dart    # SCR-I20
│           └── student_progress_screen.dart      # SCR-I21
│
└── widgets/                              # UI components dùng chung
    ├── app_button.dart
    ├── app_text_field.dart
    ├── loading_widget.dart
    ├── error_widget.dart
    ├── empty_state_widget.dart
    ├── course_card.dart
    ├── activity_card.dart
    └── notification_card.dart
```

---

## 4. Luồng Dữ Liệu End-to-End

```
[Learner bấm "Xem khóa học"]
          │
          ▼
  MyCoursesScreen
  └─ Consumer<CourseViewModel>
          │ gọi vm.fetchCourses()
          ▼
  CourseViewModel (ChangeNotifier)
  ├─ isLoading = true → notifyListeners()
  └─ gọi CourseService.getMyCourses()
          │
          ▼
  CourseService (Dio)
  └─ GET /api/courses/my  +  Header: Bearer {JWT}
          │
          ▼
  [ASP.NET Core]
  CoursesController.GetMyCourses()
  └─ gọi ICourseService
          │
          ▼
  CourseService (BLL)
  └─ validate + gọi IRepository
          │
          ▼
  CourseRepository (DAL)
  └─ EF Core → SELECT * FROM Courses WHERE ...
          │
          ▼
       SQL SERVER
          │  trả về dữ liệu
          ▼
  [Flutter nhận JSON]
  CourseModel.fromJson(json)
          │
  CourseViewModel
  ├─ courses = [...]
  ├─ isLoading = false
  └─ notifyListeners() → UI rebuild
          │
          ▼
  MyCoursesScreen hiển thị danh sách ✅
```

---

## 5. Authentication Flow

```
App khởi động
     │
     ▼
SplashScreen — đọc token từ SharedPreferences
     │
     ├── Có token ──► POST /api/auth/verify-token
     │                       │
     │               ├── Hợp lệ → decode role
     │               │               │
     │               │     ┌─────────┴──────────┐
     │               │   Learner           Instructor
     │               │     │                    │
     │               │  /learner/home    /instructor/dashboard
     │               │
     │               └── Hết hạn ──► LoginScreen
     │
     └── Không có token ──► LoginScreen
                                 │
                            POST /api/auth/login
                                 │
                            Lưu JWT vào SharedPreferences
                                 │
                            Route theo role (Learner / Instructor)
```

---

## 6. Database Schema (SQL Server)

```
Users
 ├── Id, Email, PasswordHash, FullName, AvatarUrl
 ├── Role (0=Learner, 1=Instructor)
 └── CreatedAt

Courses ──(InstructorId → Users)
 ├── Id, Title, Description, CoverImageUrl
 └── InstructorId

Classes ──(CourseId → Courses)
 ├── Id, Name, StartDate, EndDate
 └── CourseId

ClassMembers ──(ClassId × UserId)
 └── Id, ClassId, UserId, JoinedAt

LearningPaths ──(ClassId → Classes)
 └── Id, ClassId, Title, WeekNumber

LearningMaterials ──(LearningPathId → LearningPaths)
 ├── Id, Title, Type (Video / Document / Link)
 └── FileUrl / LinkUrl

Activities ──(LearningPathId → LearningPaths)
 ├── Id, Title, Description
 ├── Type (PreClass / InClass / PostClass)
 └── Deadline

ActivitySubmissions ──(ActivityId × UserId)
 ├── Id, ActivityId, UserId
 ├── FileUrl, Note
 └── Status (Pending / Approved / Rejected)

EvidenceComments ──(SubmissionId → ActivitySubmissions)
 └── Id, SubmissionId, UserId, Content, CreatedAt

Projects ──(ClassId → Classes)
 └── Id, ClassId, Title, Description

Milestones ──(ProjectId → Projects)
 └── Id, ProjectId, Title, DueDate

MilestoneSubmissions ──(MilestoneId × UserId)
 └── Id, MilestoneId, UserId, FileUrl, SubmittedAt

ReviewSessions ──(ClassId → Classes)
 └── Id, ClassId, Title, StartDate, EndDate

ReviewAssignments ──(SessionId × ReviewerId × RevieweeId)
 └── Id, SessionId, ReviewerId, RevieweeId

Feedbacks ──(AssignmentId → ReviewAssignments)
 └── Id, AssignmentId, Content, Rating, CreatedAt

Notifications ──(UserId → Users)
 └── Id, UserId, Title, Body, IsRead, CreatedAt
```

---

## 7. API Endpoints

| Module | Method | Endpoint | Mô tả |
|--------|--------|----------|-------|
| **Auth** | POST | `/api/auth/register` | Đăng ký |
| | POST | `/api/auth/login` | Đăng nhập → JWT |
| | POST | `/api/auth/refresh` | Làm mới token |
| **Courses** | GET | `/api/courses/my` | Khóa học của tôi |
| | GET | `/api/courses/{id}` | Chi tiết khóa học |
| | POST | `/api/courses` | Tạo khóa học (Instructor) |
| | PUT | `/api/courses/{id}` | Sửa khóa học |
| **Classes** | GET | `/api/classes/{id}` | Chi tiết lớp |
| | GET | `/api/classes/{id}/members` | Danh sách thành viên |
| | POST | `/api/classes` | Tạo lớp (Instructor) |
| **Learning Paths** | GET | `/api/learning-paths/{classId}` | Lộ trình theo lớp |
| | POST | `/api/learning-paths` | Tạo lộ trình |
| **Materials** | GET | `/api/materials/{pathId}` | Tài liệu theo lộ trình |
| | POST | `/api/materials/upload` | Upload file |
| **Activities** | GET | `/api/activities/{pathId}` | Danh sách hoạt động |
| | GET | `/api/activities/{id}` | Chi tiết hoạt động |
| **Evidences** | POST | `/api/evidences` | Nộp bằng chứng |
| | GET | `/api/evidences/{id}/comments` | Bình luận |
| | POST | `/api/evidences/{id}/comments` | Thêm bình luận |
| **Projects** | GET | `/api/projects/{classId}` | Dự án theo lớp |
| | GET | `/api/milestones/{projectId}` | Milestone của dự án |
| | POST | `/api/milestones/{id}/submit` | Nộp milestone |
| **Reviews** | GET | `/api/review-sessions/{classId}` | Phiên review |
| | POST | `/api/feedbacks` | Gửi feedback |
| **Progress** | GET | `/api/analytics/my-progress` | Tiến độ cá nhân |
| | GET | `/api/analytics/class/{id}` | Tiến độ lớp (Instructor) |
| **Notifications** | GET | `/api/notifications` | Danh sách thông báo |
| | PUT | `/api/notifications/{id}/read` | Đánh dấu đã đọc |

---

## 8. Packages Flutter (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  provider: ^6.1.2

  # HTTP client
  dio: ^5.4.3

  # Local storage
  shared_preferences: ^2.2.3

  # Navigation
  go_router: ^13.2.0

  # Media
  video_player: ^2.8.3
  cached_network_image: ^3.3.1
  image_picker: ^1.1.2

  # PDF viewer
  syncfusion_flutter_pdfviewer: ^25.1.41

  # Utils
  intl: ^0.19.0
  connectivity_plus: ^6.0.3
```

---

## 9. Phân Công Theo Module (Gợi Ý)

> Mỗi người làm **cả dọc** (BE + FE) của 1 feature → tránh block nhau khi phát triển song song.

| Thành viên | Backend (BLL + DAL) | Frontend (screens + viewmodel) |
|------------|---------------------|-------------------------------|
| Dev 1 | Auth + User | Auth screens + Profile |
| Dev 2 | Course + Class | Course & Class screens |
| Dev 3 | Activity + Evidence | Activity & Evidence screens |
| Dev 4 | Project + Milestone | Project & Milestone screens |
| Dev 5 | Review + Analytics | Review screens + Analytics |

---

## 10. Thứ Tự Phát Triển

```
Phase 1 — Nền tảng
  [ ] Setup solution (3 projects BE + Flutter project)
  [ ] Cấu hình EF Core + tạo DB + migration
  [ ] Auth API (Register, Login, JWT)
  [ ] Auth screens Flutter (Splash, Login, Register)

Phase 2 — Core
  [ ] Course + Class APIs
  [ ] LearningPath + Material APIs
  [ ] Course / Class / Learning Path screens Flutter

Phase 3 — Learning Activities
  [ ] Activity APIs (Pre / In / Post-class)
  [ ] Evidence submit + comments APIs
  [ ] Activity screens + evidence upload Flutter

Phase 4 — Projects & Review
  [ ] Project + Milestone APIs
  [ ] Review Session + Feedback APIs
  [ ] Project screens + Review screens Flutter

Phase 5 — Hoàn thiện
  [ ] Notifications
  [ ] Analytics / Progress tracking
  [ ] UI/UX polish + Testing
```
