# AGENT CONTEXT — FLIPPED CLASSROOM PROJECT

> **Mục đích**: File này cung cấp toàn bộ context cần thiết cho AI agent (hoặc thành viên mới)
> để tiếp tục phát triển project mà không cần hỏi lại từ đầu.
> **Cập nhật lần cuối**: 2026-06-07

---

## 1. Tổng quan dự án

**Tên**: Flipped Classroom Mobile App  
**Mục tiêu**: Ứng dụng mobile hỗ trợ mô hình lớp học đảo ngược — học viên xem tài liệu trước ở nhà, lên lớp làm bài tập và review lẫn nhau.

**Tài liệu tham khảo**:
- `spec.md` — Functional/Non-functional requirements, Data Model, Acceptance Criteria
- `architecture.md` — Kiến trúc tổng thể Backend + Frontend
- `UI.md` — UI Design System, wireframes, component library
- `screen.md` — Danh sách 62 màn hình (41 Learner, 21 Instructor)

---

## 2. Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter (Dart), MVVM + Provider pattern |
| **Backend** | ASP.NET Core (.NET 8), 3-layer architecture |
| **Database** | SQL Server (`DESKTOP-KN8VR1N`) |
| **ORM** | Entity Framework Core 8.0 |
| **Auth** | JWT Bearer Token + BCrypt password hashing |
| **HTTP Client** (Flutter) | Dio 5.x |
| **State Management** | Provider 6.x |
| **Navigation** (Flutter) | go_router 17.x |

---

## 3. Cấu trúc thư mục

### Backend — `d:\Ky8\PRM393\Code\project\backend\backend\`

```
backend\
├── Controllers\              ← API endpoints (chưa implement)
├── Middleware\
│   └── ExceptionMiddleware.cs ✅
├── BLL\
│   ├── DTOs\
│   │   ├── Auth\            ← LoginRequestDto, LoginResponseDto, RegisterRequestDto ✅
│   │   ├── Course\          ← CourseDto, CreateCourseDto ✅
│   │   ├── Class\           (trống, cần tạo)
│   │   ├── Activity\        (trống, cần tạo)
│   │   ├── Evidence\        (trống, cần tạo)
│   │   └── ...
│   ├── Interfaces\
│   │   ├── IAuthService.cs  ✅ (stub)
│   │   └── ICourseService.cs ✅ (stub)
│   ├── Services\
│   │   ├── AuthService.cs   ✅ (stub, chưa implement)
│   │   └── CourseService.cs ✅ (stub, chưa implement)
│   └── Helpers\
│       ├── JwtHelper.cs     ✅ (stub, chưa implement)
│       └── PasswordHelper.cs ✅ (stub, chưa implement)
├── DAL\
│   ├── AppDbContext.cs       ✅ HOÀN CHỈNH
│   ├── DataSeeder.cs         ✅ HOÀN CHỈNH (seed data đã có trong DB)
│   ├── Models\               ✅ TẤT CẢ 14 ENTITIES
│   │   ├── User.cs
│   │   ├── Course.cs
│   │   ├── Class.cs
│   │   ├── ClassMember.cs
│   │   ├── LearningPath.cs
│   │   ├── LearningMaterial.cs
│   │   ├── Activity.cs
│   │   ├── ActivitySubmission.cs
│   │   ├── EvidenceComment.cs
│   │   ├── Project.cs
│   │   ├── Milestone.cs
│   │   ├── MilestoneSubmission.cs
│   │   ├── ReviewSession.cs
│   │   ├── ReviewAssignment.cs
│   │   ├── Feedback.cs
│   │   └── Notification.cs
│   ├── Enums\
│   │   ├── UserRole.cs        ✅ (Learner=0, Instructor=1)
│   │   ├── ActivityType.cs    ✅ (PreClass=0, InClass=1, PostClass=2)
│   │   ├── EvidenceStatus.cs  ✅ (Pending=0, Approved=1, Rejected=2)
│   │   └── MaterialType.cs    ✅ (Video=0, Document=1, Link=2)
│   ├── Interfaces\
│   │   ├── IGenericRepository.cs ✅
│   │   └── IUnitOfWork.cs        ✅
│   └── Repositories\
│       └── GenericRepository.cs  ✅
├── Migrations\               ✅ InitialCreate đã chạy
├── Program.cs                ✅ (DB + CORS + Seeder + Swagger)
├── appsettings.json          ✅ (connection string SQL Server)
└── backend.csproj            ✅
```

### Frontend — `d:\Ky8\PRM393\Code\project\frontend\lib\`

```
lib\
├── main.dart                 ✅ (entry point)
├── app.dart                  ✅ (MaterialApp + routes cơ bản)
├── config\
│   ├── app_colors.dart       ✅ HOÀN CHỈNH
│   ├── app_theme.dart        ✅ HOÀN CHỈNH
│   └── api_config.dart       ✅ HOÀN CHỈNH (tất cả API endpoints)
├── models\
│   ├── user_model.dart       ✅
│   ├── course_model.dart     ✅
│   ├── class_model.dart      ✅
│   ├── activity_model.dart   ✅
│   └── notification_model.dart ✅
├── services\
│   ├── api_service.dart      ✅ (Dio + JWT interceptor)
│   ├── auth_service.dart     ✅ (login, register, logout, getRole)
│   ├── course_service.dart   ✅
│   └── notification_service.dart ✅
├── viewmodels\
│   ├── auth_viewmodel.dart   ✅ (ChangeNotifier)
│   ├── course_viewmodel.dart ✅
│   └── notification_viewmodel.dart ✅
├── widgets\
│   ├── app_button.dart       ✅ (Primary/Secondary/Danger variants)
│   ├── app_text_field.dart   ✅
│   └── loading_widget.dart   ✅
├── screens\
│   ├── auth\
│   │   ├── splash_screen.dart ✅ (navigate based on role)
│   │   └── login_screen.dart  ✅ (form + validation)
│   ├── learner\              (thư mục đã tạo, screens chưa implement)
│   │   ├── course\
│   │   ├── learning_path\
│   │   ├── materials\
│   │   ├── activities\
│   │   ├── projects\
│   │   ├── review\
│   │   ├── evidence\
│   │   ├── progress\
│   │   └── profile\
│   └── instructor\           (thư mục đã tạo, screens chưa implement)
│       ├── courses\
│       ├── classes\
│       ├── learning_path\
│       ├── materials\
│       ├── activities\
│       ├── projects\
│       ├── review\
│       ├── evidence_review\
│       └── analytics\
```

---

## 4. Database

### Connection String (SQL Server)
```
Server=DESKTOP-KN8VR1N;Database=FlippedClassroomDB;User Id=sa;Password=123;TrustServerCertificate=True;
```

### Migration Status
- ✅ `InitialCreate` — đã apply, 16 bảng đã tạo
- ✅ Seed data đã insert (chạy `dotnet run` trong môi trường Development)

### Tài khoản test (đã có trong DB)

| Role | Email | Password |
|------|-------|----------|
| Instructor | `instructor1@prm.edu.vn` | `Password@123` |
| Instructor | `instructor2@prm.edu.vn` | `Password@123` |
| Learner | `learner1@student.edu.vn` | `Password@123` |
| Learner | `learner2@student.edu.vn` | `Password@123` |
| Learner | `learner3@student.edu.vn` | `Password@123` |
| Learner | `learner4@student.edu.vn` | `Password@123` |

---

## 5. NuGet Packages đã cài

```xml
<!-- backend.csproj -->
<PackageReference Include="BCrypt.Net-Next" Version="4.0.3" />
<PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="8.0.0" />
<PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="8.0.0" />
```

## 6. Flutter Packages đã cài

```yaml
# pubspec.yaml
dependencies:
  provider: ^6.1.5
  dio: ^5.9.2
  shared_preferences: ^2.5.5
  go_router: ^17.3.0
  cached_network_image: ^3.4.1
  image_picker: ^1.2.2
  intl: ^0.20.2
```

---

## 7. Trạng thái hiện tại (Progress)

### ✅ HOÀN THÀNH

| Hạng mục | Mô tả |
|----------|-------|
| **Tài liệu** | spec.md, architecture.md, UI.md đầy đủ |
| **DB Schema** | 16 bảng, migration đã apply |
| **Seed Data** | 6 users, 2 courses, 3 classes, 5 activities, 5 submissions, ... |
| **EF Core Models** | 14 entities đầy đủ field + FK + navigation |
| **AppDbContext** | Fluent API config, unique indexes, cascade rules |
| **Program.cs** | DB, CORS, Seeder, Swagger, ExceptionMiddleware |
| **Flutter Foundation** | Config, Models, Services, ViewModels cơ bản |
| **Flutter Auth UI** | SplashScreen, LoginScreen |
| **Flutter Widgets** | AppButton, AppTextField, LoadingWidget |

### ❌ CHƯA LÀM — Backend

| Hạng mục | Ưu tiên | Ghi chú |
|----------|---------|---------|
| **JwtHelper** | 🔴 Cao | Tạo/validate JWT token |
| **PasswordHelper** | 🔴 Cao | BCrypt hash/verify |
| **AuthController** | 🔴 Cao | POST /api/auth/login, /register |
| **IAuthService + AuthService** | 🔴 Cao | Login, Register logic |
| **CourseController** | 🟡 Trung bình | GET /courses/my, GET /courses/{id} |
| **ICourseService + CourseService** | 🟡 Trung bình | |
| **ClassController** | 🟡 Trung bình | |
| **LearningPathController** | 🟡 Trung bình | |
| **ActivityController** | 🟡 Trung bình | |
| **EvidenceController** | 🟡 Trung bình | CRUD + approve/reject |
| **NotificationController** | 🟡 Trung bình | |
| **AnalyticsController** | 🟢 Thấp | Instructor only |
| **ProjectController** | 🟢 Thấp | |
| **ReviewController** | 🟢 Thấp | |
| **JWT Authentication Middleware** | 🔴 Cao | Cần thêm `AddAuthentication` vào Program.cs |
| **Unit of Work** | 🟡 Trung bình | Implement IUnitOfWork |

### ❌ CHƯA LÀM — Frontend

| Hạng mục | Ưu tiên | Ghi chú |
|----------|---------|---------|
| **RegisterScreen** | 🔴 Cao | screens/auth/register_screen.dart |
| **HomeScreen (Learner)** | 🔴 Cao | SCR-L05 |
| **CourseListScreen** | 🔴 Cao | SCR-L07 |
| **CourseDetailScreen** | 🔴 Cao | SCR-L08 |
| **LearningPathScreen** | 🟡 Trung bình | SCR-L11 |
| **ActivityListScreen** | 🟡 Trung bình | Pre/In/Post |
| **SubmitEvidenceScreen** | 🟡 Trung bình | SCR-L19/22/25 |
| **ProgressScreen** | 🟡 Trung bình | SCR-L37 |
| **ProfileScreen** | 🟡 Trung bình | SCR-L40 |
| **Instructor Dashboard** | 🟡 Trung bình | SCR-I01 |
| **Evidence Review Screen** | 🟡 Trung bình | SCR-I18 |
| **Analytics Screen** | 🟢 Thấp | SCR-I20 |
| **go_router setup** | 🔴 Cao | Route guard theo role |
| **Provider setup (MultiProvider)** | 🔴 Cao | Đăng ký tất cả ViewModels |
| **AppDbContext registration** | 🔴 Cao | Inject vào main.dart |

---

## 8. Lệnh hay dùng

### Backend
```powershell
# Chạy backend
cd d:\Ky8\PRM393\Code\project\backend\backend
dotnet run

# Thêm migration mới (sau khi thay đổi Model)
dotnet ef migrations add <TenMigration>
dotnet ef database update

# Xóa migration cuối
dotnet ef migrations remove
```

### Frontend
```powershell
# Chạy Flutter trên Chrome (không cần setup phức tạp)
cd d:\Ky8\PRM393\Code\project\frontend
flutter run -d chrome

# Chạy trên Android Emulator (cần Android license)
flutter run -d emulator-5554

# Lấy packages
flutter pub get
```

---

## 9. Lưu ý quan trọng

### Backend
1. **ReviewAssignment** có 2 FK đến `User` (ReviewerId, RevieweeId) → dùng `DeleteBehavior.NoAction` để tránh lỗi SQL Server "multiple cascade paths"
2. **DataSeeder** có guard `if (await context.Users.AnyAsync()) return;` → seed data chỉ chạy 1 lần duy nhất
3. **BCrypt** package: `BCrypt.Net-Next` version `4.0.3` (dùng namespace `BCrypt.Net.BCrypt`)
4. **JWT** chưa được cài package — cần thêm `Microsoft.AspNetCore.Authentication.JwtBearer`
5. Backend đang chạy trên port **5111** (HTTP)

### Flutter
1. **Android Emulator** — cần bật Android license: `flutter doctor --android-licenses` (cần cài Android Command-line Tools trước)
2. **Windows Desktop** — cần Visual Studio C++ Workload (chưa cài)
3. `api_config.dart` dùng `http://10.0.2.2:5000/api` cho Android Emulator — cần đổi sang `http://DESKTOP-KN8VR1N:5111/api` hoặc IP thực của máy
4. `app.dart` có `// TODO: Add more routes` — cần implement go_router thay vì routes map đơn giản

---

## 10. Bước tiếp theo được đề xuất

### Priority 1 — Cần làm ngay (Backend Auth)
1. Cài `Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.0`
2. Implement `JwtHelper` — GenerateToken(User) + ValidateToken()
3. Implement `PasswordHelper` — HashPassword() + VerifyPassword()
4. Implement `IAuthService` + `AuthService` — Register + Login
5. Tạo `AuthController` — POST `/api/auth/register`, POST `/api/auth/login`
6. Thêm JWT Auth vào `Program.cs`

### Priority 2 — Flutter kết nối Backend
1. Setup `MultiProvider` trong `main.dart`
2. Setup `go_router` với role-based routing
3. Test Login flow end-to-end (Flutter → API → DB)

### Priority 3 — Màn hình chính
1. HomeScreen Learner
2. CourseList + CourseDetail
3. Instructor Dashboard
