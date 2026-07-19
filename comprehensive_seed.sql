USE FlippedClassroomDB;

-- =================================================================================
-- 1. XÓA DỮ LIỆU CŨ ĐỂ TRANH TRÙNG LẶP (Dọn dẹp theo thứ tự khóa ngoại ngược)
-- =================================================================================
PRINT N'--- 1. Bắt đầu dọn dẹp dữ liệu cũ ---';

DELETE FROM Notifications;
DELETE FROM Feedbacks;
DELETE FROM ReviewAssignments;
DELETE FROM ReviewSessions;
DELETE FROM MilestoneSubmissions;
DELETE FROM Milestones;
DELETE FROM Projects;
DELETE FROM EvidenceComments;
DELETE FROM ActivitySubmissions;
DELETE FROM Activities;
DELETE FROM LearningMaterials;
DELETE FROM LearningPaths;
DELETE FROM ClassMembers;
DELETE FROM Classes;
DELETE FROM Courses;
DELETE FROM Users;

PRINT N'--- Hoàn tất dọn dẹp dữ liệu cũ ---';

-- =================================================================================
-- 2. SEED BẢNG USERS (Người dùng)
-- Gồm: 3 Giảng viên (Instructors) và 10 Học viên (Learners) để test diện rộng
-- Roles: Learner = 0, Instructor = 1
-- =================================================================================
PRINT N'--- 2. Seeding bảng Users ---';
SET IDENTITY_INSERT Users ON;
INSERT INTO Users (Id, Email, PasswordHash, FullName, AvatarUrl, Role, CreatedAt)
VALUES 
-- Giảng viên (Role = 1)
(1, 'instructor@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Nguyễn Thị Giảng Viên (Chính)', 'https://i.pravatar.cc/150?u=instructor1', 1, GETDATE()),
(5, 'instructor2@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Lê Văn Giảng Viên (Phụ)', 'https://i.pravatar.cc/150?u=instructor2', 1, GETDATE()),
(11, 'instructor3@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Phạm Minh Giảng Viên (Khách)', 'https://i.pravatar.cc/150?u=instructor3', 1, GETDATE()),

-- Học viên (Role = 0)
(2, 'learner@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Trần Văn Học Viên', 'https://i.pravatar.cc/150?u=learner', 0, GETDATE()),
(3, 'learner2@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Alice Nguyễn (Nhóm Trưởng 1)', 'https://i.pravatar.cc/150?u=alice', 0, GETDATE()),
(4, 'learner3@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Bob Trần (Nhóm Trưởng 2)', 'https://i.pravatar.cc/150?u=bob', 0, GETDATE()),
(6, 'learner4@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Charlie Lê (Thành Viên)', 'https://i.pravatar.cc/150?u=charlie', 0, GETDATE()),
(7, 'learner5@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'David Phạm (Thành Viên)', 'https://i.pravatar.cc/150?u=david', 0, GETDATE()),
(8, 'learner6@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Eva Hoàng (Thành Viên)', 'https://i.pravatar.cc/150?u=eva', 0, GETDATE()),
(9, 'learner7@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Frank Phan (Học viên mới)', 'https://i.pravatar.cc/150?u=frank', 0, GETDATE()),
(10, 'learner8@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Grace Vũ (Lớp Phó)', 'https://i.pravatar.cc/150?u=grace', 0, GETDATE()),
(12, 'learner9@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Henry Bùi (Thành Viên)', 'https://i.pravatar.cc/150?u=henry', 0, GETDATE()),
(13, 'learner10@test.com', '$2a$10$H4OvPoriAEzTKC42k0AffeV9JaZRZb/XN2omEcaylLc.64IrvnoEi', N'Irene Đặng (Thành Viên)', 'https://i.pravatar.cc/150?u=irene', 0, GETDATE());
SET IDENTITY_INSERT Users OFF;

-- =================================================================================
-- 3. SEED BẢNG COURSES (Khóa học)
-- =================================================================================
PRINT N'--- 3. Seeding bảng Courses ---';
SET IDENTITY_INSERT Courses ON;
INSERT INTO Courses (Id, InstructorId, Title, Description, CoverImageUrl, CreatedAt)
VALUES 
(1, 1, 'PRM393 - Mobile App Development', N'Phát triển ứng dụng di động nâng cao với Flutter và ngôn ngữ Dart.', 'https://picsum.photos/seed/prm/400/200', GETDATE()),
(2, 1, 'SWD392 - Software Architecture', N'Tìm hiểu kiến trúc hệ thống phần mềm, design patterns và microservices.', 'https://picsum.photos/seed/swd/400/200', GETDATE()),
(3, 5, 'PRM394 - Advanced iOS Development', N'Phát triển ứng dụng iOS chuyên nghiệp sử dụng Swift, SwiftUI và Xcode.', 'https://picsum.photos/seed/ios/400/200', GETDATE()),
(4, 11, 'EXE201 - Entrepreneurship Project', N'Dự án thực tế hướng nghiệp giúp học viên định hướng khởi nghiệp công nghệ.', 'https://picsum.photos/seed/exe/400/200', GETDATE());
SET IDENTITY_INSERT Courses OFF;

-- =================================================================================
-- 4. SEED BẢNG CLASSES (Lớp học)
-- =================================================================================
PRINT N'--- 4. Seeding bảng Classes ---';
SET IDENTITY_INSERT Classes ON;
INSERT INTO Classes (Id, CourseId, Name, StartDate, EndDate)
VALUES 
(1, 1, 'SE1601', DATEADD(month, -1, GETDATE()), DATEADD(month, 2, GETDATE())),
(2, 1, 'SE1602', DATEADD(month, -1, GETDATE()), DATEADD(month, 2, GETDATE())),
(3, 2, 'SE1603', DATEADD(month, -2, GETDATE()), DATEADD(month, 1, GETDATE())),
(4, 3, 'SE1604 - iOS Master', DATEADD(day, -15, GETDATE()), DATEADD(month, 2, GETDATE())),
(5, 4, 'SE1605 - Startup Group', GETDATE(), DATEADD(month, 3, GETDATE()));
SET IDENTITY_INSERT Classes OFF;

-- =================================================================================
-- 5. SEED BẢNG CLASSMEMBERS (Thành viên lớp)
-- =================================================================================
PRINT N'--- 5. Seeding bảng ClassMembers ---';
SET IDENTITY_INSERT ClassMembers ON;
INSERT INTO ClassMembers (Id, ClassId, UserId, JoinedAt)
VALUES 
-- Lớp SE1601 (Đông học viên để test peer review chéo diện rộng)
(1, 1, 2, DATEADD(month, -1, GETDATE())), -- Trần Văn Học Viên
(2, 1, 3, DATEADD(month, -1, GETDATE())), -- Alice Nguyễn
(3, 1, 4, DATEADD(month, -1, GETDATE())), -- Bob Trần
(4, 1, 6, DATEADD(month, -1, GETDATE())), -- Charlie Lê
(5, 1, 7, DATEADD(month, -1, GETDATE())), -- David Phạm
(6, 1, 8, DATEADD(month, -1, GETDATE())), -- Eva Hoàng

-- Lớp SE1602 (Lớp song song PRM393)
(7, 2, 6, DATEADD(month, -1, GETDATE())), 
(8, 2, 7, DATEADD(month, -1, GETDATE())),
(9, 2, 9, DATEADD(month, -1, GETDATE())),
(10, 2, 10, DATEADD(month, -1, GETDATE())),

-- Lớp SE1603 (Kiến trúc phần mềm)
(11, 3, 2, DATEADD(month, -2, GETDATE())),
(12, 3, 8, DATEADD(month, -2, GETDATE())),
(13, 3, 12, DATEADD(month, -2, GETDATE())),
(14, 3, 13, DATEADD(month, -2, GETDATE())),

-- Lớp SE1604 (iOS Master)
(15, 4, 2, DATEADD(day, -15, GETDATE())),
(16, 4, 3, DATEADD(day, -15, GETDATE())),
(17, 4, 10, DATEADD(day, -15, GETDATE())),

-- Lớp SE1605 (Startup EXE201)
(18, 5, 4, GETDATE()),
(19, 5, 9, GETDATE()),
(20, 5, 12, GETDATE()),
(21, 5, 13, GETDATE());
SET IDENTITY_INSERT ClassMembers OFF;

-- =================================================================================
-- 6. SEED BẢNG LEARNINGPATHS (Lộ trình học)
-- Trực quan hóa tiến trình với 6 tuần học của SE1601 và trạng thái mở khóa (IsUnlocked)
-- =================================================================================
PRINT N'--- 6. Seeding bảng LearningPaths ---';
SET IDENTITY_INSERT LearningPaths ON;
INSERT INTO LearningPaths (Id, ClassId, Title, WeekNumber, IsUnlocked)
VALUES 
-- Lộ trình cho lớp SE1601 (PRM393)
(1, 1, N'Tuần 1: Giới thiệu Dart & Setup Flutter', 1, 1), -- Đã mở khóa
(2, 1, N'Tuần 2: Xây dựng Layout & Stateful Widgets', 2, 1), -- Đã mở khóa
(3, 1, N'Tuần 3: Quản lý State nâng cao với Provider', 3, 1), -- Đã mở khóa
(4, 1, N'Tuần 4: Làm việc với REST API & HTTP Client', 4, 1), -- Đã mở khóa
(5, 1, N'Tuần 5: Lưu trữ dữ liệu SQLite & Cài đặt nâng cao', 5, 0), -- Chưa mở khóa
(6, 1, N'Tuần 6: Deploy ứng dụng lên Apple Store & Google Play', 6, 0), -- Chưa mở khóa

-- Lộ trình cho lớp SE1604 (iOS Master)
(7, 4, N'Tuần 1: Khái niệm Ngôn ngữ Swift cơ bản', 1, 1),
(8, 4, N'Tuần 2: SwiftUI Layout, View & State Management', 2, 0),

-- Lộ trình cho lớp SE1603
(9, 3, N'Tuần 1: Khởi động Đề án Kiến trúc', 1, 1);
SET IDENTITY_INSERT LearningPaths OFF;

-- =================================================================================
-- 7. SEED BẢNG LEARNINGMATERIALS (Tài liệu học tập)
-- Đa dạng hóa tài liệu gồm: Video (0), Document (1), Link (2)
-- Đảm bảo không bị lỗi phông chữ tiếng Việt cho tiêu đề tài liệu
-- =================================================================================
PRINT N'--- 7. Seeding bảng LearningMaterials ---';
SET IDENTITY_INSERT LearningMaterials ON;
INSERT INTO LearningMaterials (Id, LearningPathId, Title, Type, FileUrl, LinkUrl)
VALUES 
-- Tuần 1 (LearningPath 1 - SE1601)
(1, 1, N'Video: Giới thiệu kiến thức Flutter của Google', 0, 'https://www.w3schools.com/html/mov_bbb.mp4', NULL),
(2, 1, N'Tài liệu: Hướng dẫn cài đặt Flutter trên Windows & macOS', 1, 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', NULL),
(4, 1, N'Video: Ngôn ngữ Dart cơ bản trong 30 phút cho người mới', 0, NULL, 'https://youtube.com/watch?v=veMhOYRib9o'),
(5, 1, N'Slide bài giảng Tuần 1: Tổng quan về Widgets', 1, 'https://example.com/slides/tuan1.pdf', NULL),
(6, 1, N'Trang web tham khảo: Tài liệu Flutter Docs chính thức', 2, NULL, 'https://flutter.dev/docs'),
(7, 1, N'Bài tập: Thực hành thiết kế giao diện đơn giản Tuần 1', 1, 'https://example.com/exercises/bai_tap_1.docx', NULL),

-- Tuần 2 (LearningPath 2 - SE1601)
(3, 2, N'Video: Tìm hiểu Stateless vs Stateful Widgets', 0, 'https://www.w3schools.com/html/mov_bbb.mp4', NULL),
(8, 2, N'Video: Xây dựng Layout phức tạp sử dụng Row và Column', 0, NULL, 'https://youtube.com/watch?v=d_m5csmrf7I'),

-- Tuần 3 (LearningPath 3 - SE1601)
(9, 3, N'Slide: Tổng quan cơ chế Quản lý State trong Flutter', 1, 'https://example.com/slides/tuan3_state.pdf', NULL),
(10, 3, N'Liên kết: Package Provider trên pub.dev', 2, NULL, 'https://pub.dev/packages/provider'),

-- Tuần 4 (LearningPath 4 - SE1601)
(11, 4, N'Tài liệu: REST API Integration & JSON Serialization', 1, 'https://example.com/api_guide.pdf', NULL),
(12, 4, N'Video: Thao tác gửi Request GET/POST bằng HTTP client', 0, 'https://www.w3schools.com/html/mov_bbb.mp4', NULL),

-- Lớp iOS Tuần 1 (LearningPath 7)
(13, 7, N'Video: Swift cơ bản - Biến, Mảng và Cấu trúc điều khiển', 0, 'https://www.w3schools.com/html/mov_bbb.mp4', NULL);
SET IDENTITY_INSERT LearningMaterials OFF;

-- =================================================================================
-- 8. SEED BẢNG ACTIVITIES (Hoạt động học tập)
-- Đầy đủ các thể loại hoạt động cho các tuần học khác nhau của SE1601
-- Deadline được điều chỉnh linh động thông qua hàm DATEADD
-- Types: PreClass = 0, InClass = 1, PostClass = 2
-- =================================================================================
PRINT N'--- 8. Seeding bảng Activities ---';
SET IDENTITY_INSERT Activities ON;
INSERT INTO Activities (Id, LearningPathId, Title, Type, Description, Deadline)
VALUES 
-- Các hoạt động trong Tuần 1 (Đã quá hạn để test trạng thái trễ hạn / nộp muộn)
(1, 1, N'Pre-Class: Xem video hướng dẫn cài đặt môi trường Flutter', 0, N'Xem video setup và chuẩn bị sẵn Android Studio hoặc VS Code trên laptop cá nhân trước khi lên lớp học.', DATEADD(day, -5, GETDATE())),
(2, 1, N'In-Class: Thực hành ứng dụng Hello World đầu tiên', 1, N'Tạo project mẫu chạy thử ứng dụng Counter mặc định của Flutter trên thiết bị ảo hoặc thật.', DATEADD(day, -3, GETDATE())),
(3, 1, N'Post-Class: Viết báo cáo ngắn phản hồi cảm nhận tuần đầu tiên', 2, N'Trình bày các lỗi gặp phải trong quá trình cài đặt môi trường và các giải pháp đã tìm thấy.', DATEADD(day, -1, GETDATE())),

-- Các hoạt động trong Tuần 2 (Sắp hết hạn hôm nay và trong tuần)
(4, 2, N'Pre-Class: Nghiên cứu lý thuyết bố cục giao diện Widget Layout', 0, N'Đọc chương 2 của cuốn sách Flutter Cookbook về các Widgets: Container, Row, Column, Stack.', GETDATE()),
(5, 2, N'In-Class: Thiết kế giao diện Profile Cá nhân nâng cao', 1, N'Hoàn thiện giao diện màn hình thông tin người dùng với ListView, Card, ListTile, Avatar.', DATEADD(day, 2, GETDATE())),

-- Các hoạt động trong Tuần 3 (Mới mở khóa, tuần tới)
(6, 3, N'Pre-Class: Đọc tài liệu giới thiệu cơ chế quản lý trạng thái Provider', 0, N'Tìm hiểu kiến trúc ChangeNotifier, Consumer và Provider.', DATEADD(day, 8, GETDATE())),
(7, 3, N'In-Class: Viết ứng dụng Giỏ hàng đơn giản sử dụng Provider', 1, N'Tạo tính năng thêm/xóa sản phẩm trong giỏ hàng và cập nhật số lượng trực tiếp.', DATEADD(day, 10, GETDATE())),

-- Các hoạt động trong Tuần 4 (Hạn xa)
(8, 4, N'In-Class: Gọi API lấy danh sách bài viết từ JSONPlaceholder', 1, N'Sử dụng thư viện http, fetch dữ liệu bất đồng bộ và vẽ giao diện với FutureBuilder.', DATEADD(day, 16, GETDATE())),

-- Hoạt động lớp SE1603
(9, 9, N'Nộp đề xuất đề án Kiến trúc hệ thống', 1, N'Học viên nộp file PDF mô tả kiến trúc đề xuất.', DATEADD(day, 5, GETDATE()));
SET IDENTITY_INSERT Activities OFF;

-- =================================================================================
-- 9. SEED BẢNG ACTIVITYSUBMISSIONS (Bài nộp hoạt động)
-- Bổ sung đầy đủ các trạng thái để kiểm thử chức năng chấm bài:
-- Status: Pending = 0, Approved = 1, Rejected = 2
-- =================================================================================
PRINT N'--- 9. Seeding bảng ActivitySubmissions ---';
SET IDENTITY_INSERT ActivitySubmissions ON;
INSERT INTO ActivitySubmissions (Id, ActivityId, UserId, FileUrl, Note, Status, SubmittedAt, ReviewedAt)
VALUES 
-- Bài nộp đã Duyệt (Approved = 1)
(1, 1, 2, 'https://example.com/learner1_setup.pdf', N'Báo cáo cài đặt môi trường của Trần Văn Học Viên.', 1, DATEADD(day, -6, GETDATE()), DATEADD(day, -5, GETDATE())),
(3, 1, 3, 'https://example.com/alice_setup.pdf', N'Alice nộp báo cáo setup Flutter đầy đủ.', 1, DATEADD(day, -5, GETDATE()), DATEADD(day, -4, GETDATE())),
(4, 1, 4, 'https://example.com/bob_setup.pdf', N'Bob đã hoàn thành cài đặt trên hệ điều hành macOS.', 1, DATEADD(day, -5, GETDATE()), DATEADD(day, -4, GETDATE())),
(5, 1, 7, 'https://example.com/david_setup.pdf', N'David đã setup thành công Xcode và Flutter.', 1, DATEADD(day, -5, GETDATE()), DATEADD(day, -4, GETDATE())),
(6, 1, 8, 'https://example.com/eva_setup.pdf', N'Bài nộp setup môi trường của Eva.', 1, DATEADD(day, -5, GETDATE()), DATEADD(day, -4, GETDATE())),
(7, 2, 2, 'https://example.com/learner1_hello.zip', N'Đã chạy thành công ứng dụng Hello World trên máy ảo Pixel 4.', 1, DATEADD(day, -3, GETDATE()), DATEADD(day, -2, GETDATE())),

-- Bài nộp đang Chờ duyệt (Pending = 0)
(2, 3, 2, 'https://example.com/learner1_reflection.docx', N'Bài viết phản hồi cá nhân của học viên.', 0, DATEADD(day, -1, GETDATE()), NULL),
(9, 4, 3, 'https://example.com/alice_layout_reading.pdf', N'Alice tóm tắt các điểm cần lưu ý về Layout.', 0, GETDATE(), NULL),
(10, 4, 2, 'https://example.com/learner1_layout_reading.pdf', N'Bài tự học phần Layout của Học Viên.', 0, GETDATE(), NULL),
(11, 2, 4, 'https://example.com/bob_hello.zip', N'Bob nộp bài thực hành Hello World.', 0, DATEADD(day, -1, GETDATE()), NULL),

-- Bài nộp bị Từ chối (Rejected = 2) để test tính năng làm lại / sửa bài nộp
(8, 1, 6, 'https://example.com/charlie_setup_broken.pdf', N'File nộp bị lỗi định dạng hoặc trống.', 2, DATEADD(day, -5, GETDATE()), DATEADD(day, -4, GETDATE())),
(12, 2, 3, 'https://example.com/alice_hello_broken.zip', N'Mã nguồn bị crash khi biên dịch build gradle.', 2, DATEADD(day, -3, GETDATE()), DATEADD(day, -2, GETDATE()));
SET IDENTITY_INSERT ActivitySubmissions OFF;

-- =================================================================================
-- 10. SEED BẢNG EVIDENCECOMMENTS (Bình luận bằng chứng)
-- =================================================================================
PRINT N'--- 10. Seeding bảng EvidenceComments ---';
SET IDENTITY_INSERT EvidenceComments ON;
INSERT INTO EvidenceComments (Id, SubmissionId, UserId, Content, CreatedAt)
VALUES 
-- Bình luận trên bài nộp của Trần Văn Học Viên (Submission 1)
(1, 1, 1, N'Báo cáo rất chi tiết, mô tả rõ ràng các bước và chụp ảnh minh chứng tốt. Tiếp tục phát huy nhé!', DATEADD(day, -5, GETDATE())),
(2, 1, 2, N'Em cám ơn cô đã đánh giá cao bài nộp của em ạ!', DATEADD(day, -5, GETDATE())),

-- Bình luận trên bài nộp bị từ chối của Charlie (Submission 8)
(3, 8, 1, N'Em nộp nhầm file trống rồi. Vui lòng cập nhật và nộp lại file pdf báo cáo cài đặt trước ngày mai.', DATEADD(day, -4, GETDATE())),
(4, 8, 6, N'Dạ thưa cô, do mạng chập chờn nên file tải lên bị lỗi. Em vừa cập nhật lại file báo cáo rồi ạ.', DATEADD(day, -3, GETDATE())),

-- Bình luận trên bài nộp Hello World bị crash của Alice (Submission 12)
(5, 12, 1, N'Lỗi này là do phiên bản Kotlin trong build.gradle chưa khớp. Em mở file đó lên sửa ext.kotlin_version = 1.8.0 xem sao.', DATEADD(day, -2, GETDATE())),
(6, 12, 3, N'Dạ để em sửa lại theo hướng dẫn của cô rồi chạy thử lại ạ.', DATEADD(day, -1, GETDATE()));
SET IDENTITY_INSERT EvidenceComments OFF;

-- =================================================================================
-- 11. SEED BẢNG PROJECTS (Dự án lớp học)
-- =================================================================================
PRINT N'--- 11. Seeding bảng Projects ---';
SET IDENTITY_INSERT Projects ON;
INSERT INTO Projects (Id, ClassId, Title, Description)
VALUES 
(1, 1, N'Dự án cuối kỳ: Ứng dụng E-Commerce Shop bán hàng', N'Xây dựng ứng dụng mua sắm trực tuyến đa kênh hoàn chỉnh bằng Flutter, kết nối Web API, hỗ trợ giỏ hàng, thông báo đẩy và thanh toán.'),
(2, 3, N'Dự án cuối kỳ: Hệ thống quản lý thư viện Microservices', N'Thiết kế và triển khai kiến trúc microservices phân tán cho nghiệp vụ mượn trả sách, sử dụng ASP.NET Core Web API, API Gateway và Message Broker.'),
(3, 4, N'Dự án cuối kỳ: Ứng dụng theo dõi sức khỏe HealthTracker iOS', N'Thiết kế app iOS sử dụng SwiftUI tích hợp SDK đo bước chân, nhịp tim và lượng calo tiêu thụ hàng ngày.');
SET IDENTITY_INSERT Projects OFF;

-- =================================================================================
-- 12. SEED BẢNG MILESTONES (Mốc thời gian dự án)
-- =================================================================================
PRINT N'--- 12. Seeding bảng Milestones ---';
SET IDENTITY_INSERT Milestones ON;
INSERT INTO Milestones (Id, ProjectId, Title, Description, DueDate)
VALUES 
-- Project 1 (E-Commerce Flutter)
(1, 1, N'Mốc 1: Phân tích yêu cầu & Thiết kế UI Figma Mockup', N'Yêu cầu nộp liên kết Figma thiết kế chi tiết giao diện UX/UI và tài liệu mô tả yêu cầu chức năng (SRS) của nhóm.', DATEADD(day, 10, GETDATE())),
(2, 1, N'Mốc 2: Hoàn thành khung giao diện Frontend & Mock dữ liệu', N'Xây dựng các màn hình chính bằng Flutter, viết logic chuyển trang và liên kết mock dữ liệu tại local.', DATEADD(day, 25, GETDATE())),
(3, 1, N'Mốc 3: Tích hợp API Backend, Hoàn thiện & Nộp báo cáo', N'Tích hợp Web API thực tế, viết Unit test cơ bản, kiểm thử tích hợp và viết báo cáo kết quả dự án cuối kỳ.', DATEADD(day, 45, GETDATE())),

-- Project 2 (Microservices SWD392)
(4, 2, N'Mốc 1: Phác thảo thiết kế Kiến trúc hệ thống tổng quan', N'Vẽ các sơ đồ Component Diagram, Sequence Diagram biểu diễn tương tác giữa các service và cơ sở dữ liệu.', DATEADD(day, 15, GETDATE())),
(5, 2, N'Mốc 2: Demo tính năng Core Service & API Gateway', N'Triển khai thành công API Gateway định tuyến và tối thiểu 2 service nghiệp vụ trao đổi dữ liệu qua RabbitMQ.', DATEADD(day, 35, GETDATE())),

-- Project 3 (iOS App)
(6, 3, N'Mốc 1: Wireframe và bản phác thảo màn hình iOS', N'Nộp bản vẽ giao diện nháp mô tả luồng điều hướng giữa các màn hình ứng dụng.', DATEADD(day, 12, GETDATE()));
SET IDENTITY_INSERT Milestones OFF;

-- =================================================================================
-- 13. SEED BẢNG MILESTONESUBMISSIONS (Bài nộp mốc thời gian)
-- =================================================================================
PRINT N'--- 13. Seeding bảng MilestoneSubmissions ---';
SET IDENTITY_INSERT MilestoneSubmissions ON;
INSERT INTO MilestoneSubmissions (Id, MilestoneId, UserId, FileUrl, Description, SubmittedAt)
VALUES 
(1, 1, 2, 'https://figma.com/file/learner1_project_figma', N'Nhóm 1 nộp thiết kế Figma cho app bán hàng.', GETDATE()),
(2, 1, 3, 'https://figma.com/file/alice_project_figma', N'Nhóm 2 nộp Figma link và tệp tài liệu SRS đính kèm.', GETDATE()),
(3, 1, 4, 'https://figma.com/file/bob_project_figma', N'Nhóm 3 gửi link phác thảo UI Figma.', GETDATE()),
(4, 4, 8, 'https://github.com/eva/swd392_architecture', N'Eva đại diện nhóm 4 nộp bản phác thảo sơ đồ System Architecture.', GETDATE()),
(5, 6, 2, 'https://github.com/learner1/ios_wireframe', N'Nhóm 5 nộp wireframe ứng dụng iOS HealthTracker.', GETDATE());
SET IDENTITY_INSERT MilestoneSubmissions OFF;

-- =================================================================================
-- 14. SEED BẢNG REVIEWSESSIONS (Phiên đánh giá chéo)
-- =================================================================================
PRINT N'--- 14. Seeding bảng ReviewSessions ---';
SET IDENTITY_INSERT ReviewSessions ON;
INSERT INTO ReviewSessions (Id, ClassId, ActivityId, Title, StartDate, EndDate)
VALUES 
(1, 1, 2, N'Phiên đánh giá chéo giữa kỳ môn Flutter (SE1601)', DATEADD(day, -3, GETDATE()), DATEADD(day, 7, GETDATE())),
(2, 1, 5, N'Phiên đánh giá chéo cuối kỳ môn Flutter (SE1601)', DATEADD(day, 40, GETDATE()), DATEADD(day, 50, GETDATE())),
(3, 3, 9, N'Đánh giá chéo Đề án Kiến trúc hệ thống (SE1603)', DATEADD(day, 5, GETDATE()), DATEADD(day, 12, GETDATE()));
SET IDENTITY_INSERT ReviewSessions OFF;

-- =================================================================================
-- 15. SEED BẢNG REVIEWASSIGNMENTS (Phân công đánh giá chéo)
-- Thiết lập 2 vòng đánh giá chéo chéo nhau giữa 6 học viên lớp SE1601 (2, 3, 4, 6, 7, 8)
-- Tạo nên danh sách 12 phân công chi tiết để test bộ lọc và phân trang phân quyền
-- =================================================================================
PRINT N'--- 15. Seeding bảng ReviewAssignments ---';
SET IDENTITY_INSERT ReviewAssignments ON;
INSERT INTO ReviewAssignments (Id, SessionId, ReviewerId, RevieweeId)
VALUES 
-- Vòng 1 (Vòng tròn 1: 2 -> 3 -> 4 -> 6 -> 7 -> 8 -> 2)
(1, 1, 2, 3), -- Trần Văn Học Viên đánh giá Alice (3)
(2, 1, 3, 4), -- Alice (3) đánh giá Bob (4)
(3, 1, 4, 6), -- Bob (4) đánh giá Charlie (6)
(4, 1, 6, 7), -- Charlie (6) đánh giá David (7)
(5, 1, 7, 8), -- David (7) đánh giá Eva (8)
(6, 1, 8, 2), -- Eva (8) đánh giá Trần Văn Học Viên (2)

-- Vòng 2 (Vòng tròn 2 đan chéo để test bộ lọc người đánh giá)
(7, 1, 2, 4), -- Trần Văn Học Viên đánh giá Bob (4)
(8, 1, 4, 7), -- Bob (4) đánh giá David (7)
(9, 1, 7, 2), -- David (7) đánh giá Trần Văn Học Viên (2)
(10, 1, 3, 6), -- Alice (3) đánh giá Charlie (6)
(11, 1, 6, 8), -- Charlie (6) đánh giá Eva (8)
(12, 1, 8, 3); -- Eva (8) đánh giá Alice (3)
SET IDENTITY_INSERT ReviewAssignments OFF;

-- =================================================================================
-- 16. SEED BẢNG FEEDBACKS (Phản hồi đánh giá chéo)
-- Ratings: 1 sao -> 5 sao
-- =================================================================================
PRINT N'--- 16. Seeding bảng Feedbacks ---';
SET IDENTITY_INSERT Feedbacks ON;
INSERT INTO Feedbacks (Id, AssignmentId, Content, Rating, CreatedAt)
VALUES 
-- Phản hồi cho các Assignment trong Phiên 1
(1, 1, N'Thiết kế giao diện của Alice rất đẹp mắt, phối màu hài hòa và hiện đại. Tuy nhiên, nên thiết kế thêm màn hình Dark Mode để tăng trải nghiệm người dùng.', 4, DATEADD(day, -2, GETDATE())),
(2, 2, N'Bản vẽ SRS đầy đủ các chức năng thiết yếu. Bob chuẩn bị bài rất nghiêm túc, cấu trúc rõ ràng.', 5, DATEADD(day, -1, GETDATE())),
(3, 6, N'Mã nguồn chạy mượt nhưng thiếu các comment giải thích cho các hàm xử lý logic phức tạp ở widget giỏ hàng.', 3, DATEADD(day, -1, GETDATE())),
(4, 7, N'Phác thảo wireframe sơ sài, thiếu nhiều luồng xử lý lỗi như mất kết nối internet hoặc sai mật khẩu.', 3, GETDATE()),
(5, 10, N'Rất thích phần layout của nhóm Charlie, tổ chức component rất khoa học và dễ tái sử dụng.', 5, GETDATE()),
(6, 12, N'Giao diện Figma của nhóm Alice tương đối hoàn thiện nhưng kích thước chữ ở một số nút bấm hơi nhỏ, khó đọc trên màn hình điện thoại thực tế.', 4, GETDATE());
SET IDENTITY_INSERT Feedbacks OFF;

-- =================================================================================
-- 17. SEED BẢNG NOTIFICATIONS (Thông báo)
-- Gửi thông báo đến các người dùng khác nhau để kiểm tra giao diện chuông thông báo
-- =================================================================================
PRINT N'--- 17. Seeding bảng Notifications ---';
SET IDENTITY_INSERT Notifications ON;
INSERT INTO Notifications (Id, UserId, Title, Body, IsRead, CreatedAt)
VALUES 
-- Thông báo cho Trần Văn Học Viên (UserId = 2)
(1, 2, N'Chào mừng bạn đến với lớp SE1601!', N'Chúc bạn có kỳ học vui vẻ và đạt kết quả tốt trong môn học PRM393 - Lập trình di động.', 1, DATEADD(day, -7, GETDATE())),
(2, 2, N'Có hoạt động mới cần thực hiện', N'Giảng viên vừa thêm hoạt động "Pre-class: Xem video hướng dẫn cài đặt". Vui lòng kiểm tra.', 1, DATEADD(day, -5, GETDATE())),
(3, 2, N'Chấm điểm bài nộp của bạn', N'Giảng viên đã duyệt bài nộp của bạn cho hoạt động "Ứng dụng Hello World". Xem nhận xét chi tiết.', 0, DATEADD(day, -2, GETDATE())),
(4, 2, N'Bạn có lịch phân công đánh giá chéo', N'Hệ thống đã phân công bạn đánh giá bài của Alice Nguyễn trong phiên đánh giá chéo giữa kỳ.', 0, DATEADD(day, -3, GETDATE())),
(5, 2, N'Thông báo nhắc nhở nộp báo cáo tuần 2', N'Hạn nộp hoạt động tự học phần Layout sắp đến gần. Hãy hoàn thành sớm!', 0, GETDATE()),

-- Thông báo cho Alice Nguyễn (UserId = 3)
(6, 3, N'Bài nộp của bạn bị từ chối duyệt', N'Bài thực hành Hello World của bạn bị từ chối do bị crash. Hãy đọc nhận xét của giảng viên để sửa lỗi.', 0, DATEADD(day, -2, GETDATE())),
(7, 3, N'Nhắc nhở làm bài đánh giá chéo', N'Phiên đánh giá chéo sắp đóng trong 3 ngày tới. Vui lòng chấm bài cho Bob Trần theo phân công.', 0, DATEADD(day, -1, GETDATE())),

-- Thông báo cho Bob Trần (UserId = 4)
(8, 4, N'Bài thực hành đã được nộp thành công', N'Hệ thống ghi nhận bạn đã nộp bài Hello World thành công vào lúc 23:30 hôm qua.', 1, DATEADD(day, -1, GETDATE())),

-- Thông báo cho Giảng viên chính (UserId = 1)
(9, 1, N'Học viên nộp bài hoạt động mới', N'Trần Văn Học Viên vừa gửi bài nộp cho báo cáo tuần 1. Vui lòng vào đánh giá.', 0, GETDATE()),
(10, 1, N'Có bình luận mới trong bài nộp', N'Học viên Charlie Lê đã phản hồi bình luận của bạn trong bài nộp cài đặt môi trường bị từ chối.', 0, DATEADD(day, -3, GETDATE())),

-- Thông báo cho Charlie Lê (UserId = 6)
(11, 6, N'Bạn được mời vào lớp học mới', N'Giảng viên đã thêm bạn vào lớp SE1602 - Lập trình di động Flutter.', 0, GETDATE()),

-- Thông báo cho Eva Hoàng (UserId = 8)
(12, 8, N'Bài nộp dự án thành công', N'Bạn đã đại diện nhóm nộp thành công sơ đồ System Architecture cho dự án SWD392.', 1, GETDATE());
SET IDENTITY_INSERT Notifications OFF;

PRINT N'================================================================================';
PRINT N'===      SEEDING DỮ LIỆU THỬ NGHIỆM CHI TIẾT VÀ TOÀN DIỆN THÀNH CÔNG         ===';
PRINT N'================================================================================';
