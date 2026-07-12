-- Thay thế @PathId bằng ID của Lộ trình học (Learning Path) thực tế đang có trong database của bạn
DECLARE @PathId INT = 1;

-- Thêm một số tài liệu mẫu gồm Video (0), Document (1), Link (2)
INSERT INTO LearningMaterials (LearningPathId, Title, Type, FileUrl, LinkUrl)
VALUES 
(@PathId, N'Video: Dart cơ bản trong 30 phút', 0, NULL, N'https://youtube.com/watch?v=veMhOYRib9o'),
(@PathId, N'Slide Tuần 1: Giới thiệu Flutter', 1, N'https://example.com/slides/tuan1.pdf', NULL),
(@PathId, N'Tài liệu tham khảo Flutter Docs', 2, NULL, N'https://flutter.dev/docs'),
(@PathId, N'Video: Quản lý State với Provider', 0, NULL, N'https://youtube.com/watch?v=d_m5csmrf7I'),
(@PathId, N'Bài tập thực hành Tuần 1', 1, N'https://example.com/exercises/bai_tap_1.docx', NULL);

PRINT 'Thêm dữ liệu thành công!';
