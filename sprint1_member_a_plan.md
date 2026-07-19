# 🗓️ Kế Hoạch Thực Thi Sprint 1 — Member A

> **Vai trò**: Auth + Learner Flow (Fullstack)  
> **Tech Stack**: ASP.NET Core · Flutter · SQL Server  
> **Thời gian**: 2 tuần (10 ngày làm việc) · **Tổng**: ~12 ngày công

---

## 📌 Nguyên tắc thực thi

> [!IMPORTANT]
> Luôn làm **Backend trước → Frontend sau** cho từng nhóm tính năng.  
> Khi Backend chưa xong, dùng **mock data** để Frontend không bị block.  
> Commit mỗi khi xong 1 task, push lên branch `feature/member-a`.

---

## 📅 Kế hoạch theo ngày

### 🗓️ Ngày 1 — Khởi động & Setup (0.5 + 0.5 = 1 ngày)

| Task | Mô tả | Ước lượng |
|------|--------|-----------|
| **A1.1** | Setup project ASP.NET Core: cài EF Core, kết nối SQL Server, cấu hình Swagger, JWT middleware | 0.5 ngày |
| **A1.2** | Tạo Entity `User`, viết Migration, chạy `dotnet ef database update` | 0.5 ngày |

**✅ Done when**: Project chạy được, Swagger mở được, bảng `User` có trong DB.

---

### 🗓️ Ngày 2 — Authentication (1.5 ngày)

| Task | Mô tả | Ước lượng |
|------|--------|-----------|
| **A1.3** | `AuthController` với 3 endpoints: | 1.5 ngày |
| | → `POST /auth/register` — hash password, lưu User | |
| | → `POST /auth/login` — kiểm tra password, trả JWT token | |
| | → `POST /auth/forgot-password` — gửi email reset hoặc trả token | |

**✅ Done when**: Postman test được register → login → nhận JWT token.

---

### 🗓️ Ngày 3 — Class & Member APIs (0.5 + 1 = 1.5 ngày)

| Task | Mô tả | Ước lượng |
|------|--------|-----------|
| **A1.4** | Migration bảng `Class`, `ClassMember` — thêm quan hệ FK với `User` | 0.5 ngày |
| **A1.5** | `ClassController` (Learner role): | 1 ngày |
| | → `GET /classes` — danh sách lớp của learner hiện tại | |
| | → `GET /classes/:id` — chi tiết 1 lớp | |
| | → `GET /classes/:id/members` — danh sách thành viên | |

**✅ Done when**: Gọi API có JWT → trả về danh sách lớp đúng user.

---

### 🗓️ Ngày 4 — Learning Path, Material, Activity APIs (0.5 + 0.5 + 0.5 = 1.5 ngày)

| Task | Mô tả | Ước lượng |
|------|--------|-----------|
| **A1.6** | `LearningPathController` (Learner): `GET /classes/:id/paths`, `GET /paths/:id` | 0.5 ngày |
| **A1.7** | `MaterialController` (Learner): `GET /paths/:id/materials` | 0.5 ngày |
| **A1.8** | `ActivityController` (Learner): `GET /paths/:id/activities`, `GET /activities/:id` | 0.5 ngày |

**✅ Done when**: Lấy được lộ trình học → tài liệu → hoạt động của 1 lớp.

---

### 🗓️ Ngày 5 — Notification & Profile APIs (0.5 + 0.5 = 1 ngày)

| Task | Mô tả | Ước lượng |
|------|--------|-----------|
| **A1.9** | `NotificationController`: | 0.5 ngày |
| | → `GET /notifications` | |
| | → `PUT /notifications/read-all` | |
| | → `PUT /notifications/:id/read` | |
| **A1.10** | `ProfileController`: `GET /profile`, `PUT /profile` | 0.5 ngày |

**✅ Done when**: Backend API hoàn thiện. Bắt đầu chuyển sang Flutter.

---

### 🗓️ Ngày 6 — Flutter Setup & Auth UI (0.5 + 1.5 = 2 ngày)

| Task | Mô tả | Ước lượng |
|------|--------|-----------|
| **A1.11** | Setup Flutter: xóa `app.dart` mặc định, cấu hình `ApiService` base URL, lưu JWT token bằng `SharedPreferences` | 0.5 ngày |
| **A1.12** | Xây dựng 4 màn hình Auth: | 1.5 ngày |
| | → `SplashScreen`: kiểm tra token → auto-login nếu còn hạn | |
| | → `LoginScreen`: form email/password, gọi API, lưu token | |
| | → `RegisterScreen`: form đăng ký, validation | |
| | → `ForgotPasswordScreen`: nhập email, gọi API | |

**✅ Done when**: Mở app → tự động đăng nhập nếu có token, hoặc chuyển tới Login.

---

### 🗓️ Ngày 7 — Home, Class Detail, Members (1 + 0.5 + 0.5 = 2 ngày)

| Task | Mô tả | Ước lượng |
|------|--------|-----------|
| **A1.13** | `HomeScreen`: gọi `GET /classes`, hiển thị danh sách lớp dạng card → tap vào → `CourseDetailScreen` | 1 ngày |
| **A1.14** | `ClassDetailScreen`: thông tin lớp, % tiến độ, quick actions (đến Learning Path, Members…) | 0.5 ngày |
| **A1.15** | `MembersScreen`: gọi `GET /classes/:id/members`, hiển thị avatar + tên | 0.5 ngày |

**✅ Done when**: Từ HomeScreen điều hướng được vào chi tiết lớp và xem thành viên.

---

### 🗓️ Ngày 8 — Learning Path UI (1 ngày)

| Task | Mô tả | Ước lượng |
|------|--------|-----------|
| **A1.16** | `LearningPathScreen`: danh sách tuần học | 1 ngày |
| | `LearningPathDetailScreen`: chi tiết 1 tuần với tab **Pre / In / Post** class | |

**✅ Done when**: Learner xem được lộ trình học theo từng tuần, phân tab rõ ràng.

---

### 🗓️ Ngày 9 — Materials & Activities UI (1 + 1 = 2 ngày)

| Task | Mô tả | Ước lượng |
|------|--------|-----------|
| **A1.17** | `MaterialsScreen`: danh sách tài liệu → | 1 ngày |
| | → `VideoPlayerScreen`: phát video | |
| | → `DocumentViewerScreen`: xem PDF | |
| **A1.18** | 3 màn hình Activity: | 1 ngày |
| | → `PreClassActivityScreen` | |
| | → `InClassActivityScreen` | |
| | → `PostClassActivityScreen` | |

**✅ Done when**: Learner xem được video/PDF và xem chi tiết từng loại hoạt động.

---

### 🗓️ Ngày 10 — Notification & Profile UI + Buffer (0.5 + 0.5 + 0.5 = 1.5 ngày)

| Task | Mô tả | Ước lượng |
|------|--------|-----------|
| **A1.19** | `NotificationsScreen`: danh sách thông báo, tap → mark as read, nút "Mark all read" | 0.5 ngày |
| **A1.20** | `ProfileScreen`: xem thông tin · `EditProfileScreen`: sửa và lưu qua `PUT /profile` | 0.5 ngày |
| **Buffer** | Fix bug, polish UI, test end-to-end flow, viết seed data | 0.5 ngày |

**✅ Done when**: Toàn bộ Learner flow hoạt động end-to-end với data thật từ DB.

---

## 🎯 Definition of Done — Sprint 1 Member A

- [ ] Learner đăng ký / đăng nhập thành công, nhận JWT token
- [ ] Auto-login hoạt động khi có token hợp lệ
- [ ] Learner thấy danh sách lớp học từ DB thật
- [ ] Learner xem được tài liệu video và PDF
- [ ] Learner xem được hoạt động Pre / In / Post-class
- [ ] Thông báo hiển thị và mark-read được
- [ ] Hồ sơ cá nhân xem và chỉnh sửa được
- [ ] Không crash khi không có data hoặc lỗi mạng

---

## 🗂️ Git Workflow

```
Branch: feature/member-a

Commit convention:
  feat(auth): add register/login API          ← backend
  feat(flutter): add LoginScreen UI           ← frontend
  fix(class): fix N+1 query in GET /classes   ← bugfix
```

---

## ⚠️ Rủi ro cần chú ý

| Rủi ro | Cách xử lý |
|--------|-----------|
| Member B chưa có API mà cần dùng chung schema | Define response schema trước, dùng mock JSON tạm |
| JWT token hết hạn trên Flutter | Implement refresh token hoặc redirect về Login |
| PDF/Video không load được | Dùng thư viện `flutter_pdfview` + `video_player`, kiểm tra CORS |
| DB migration conflict với Member B | A làm `User`, `Class` trước — B làm `Course` sau, merge theo thứ tự |
