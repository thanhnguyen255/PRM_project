using backend.DAL.Enums;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.DAL;

public static class DataSeeder
{
    public static async Task SeedAsync(AppDbContext context)
    {
        // Chỉ seed khi database trống
        if (await context.Users.AnyAsync()) return;

        // ─────────────────────────────────────────────────────────────────────
        // 1. USERS
        // ─────────────────────────────────────────────────────────────────────
        var instructor1 = new User
        {
            Email        = "instructor1@prm.edu.vn",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Password@123"),
            FullName     = "Nguyễn Văn Bình",
            Role         = UserRole.Instructor,
            AvatarUrl    = null,
            CreatedAt    = DateTime.UtcNow
        };
        var instructor2 = new User
        {
            Email        = "instructor2@prm.edu.vn",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Password@123"),
            FullName     = "Trần Thị Hương",
            Role         = UserRole.Instructor,
            CreatedAt    = DateTime.UtcNow
        };

        var learner1 = new User
        {
            Email        = "learner1@student.edu.vn",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Password@123"),
            FullName     = "Lê Văn Minh",
            Role         = UserRole.Learner,
            CreatedAt    = DateTime.UtcNow
        };
        var learner2 = new User
        {
            Email        = "learner2@student.edu.vn",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Password@123"),
            FullName     = "Phạm Thị Lan",
            Role         = UserRole.Learner,
            CreatedAt    = DateTime.UtcNow
        };
        var learner3 = new User
        {
            Email        = "learner3@student.edu.vn",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Password@123"),
            FullName     = "Hoàng Văn Hùng",
            Role         = UserRole.Learner,
            CreatedAt    = DateTime.UtcNow
        };
        var learner4 = new User
        {
            Email        = "learner4@student.edu.vn",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("Password@123"),
            FullName     = "Vũ Thị Thu",
            Role         = UserRole.Learner,
            CreatedAt    = DateTime.UtcNow
        };

        await context.Users.AddRangeAsync(
            instructor1, instructor2,
            learner1, learner2, learner3, learner4
        );
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 2. COURSES
        // ─────────────────────────────────────────────────────────────────────
        var course1 = new Course
        {
            Title        = "PRM392 - Mobile Application Development",
            Description  = "Khóa học phát triển ứng dụng di động sử dụng Flutter và .NET Core backend.",
            InstructorId = instructor1.Id,
            CreatedAt    = DateTime.UtcNow
        };
        var course2 = new Course
        {
            Title        = "SWP391 - Software Project",
            Description  = "Dự án phần mềm theo nhóm áp dụng mô hình Agile/Scrum.",
            InstructorId = instructor2.Id,
            CreatedAt    = DateTime.UtcNow
        };

        await context.Courses.AddRangeAsync(course1, course2);
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 3. CLASSES
        // ─────────────────────────────────────────────────────────────────────
        var class1 = new Class
        {
            CourseId  = course1.Id,
            Name      = "PRM392 - SE1801",
            StartDate = new DateTime(2026, 6, 1),
            EndDate   = new DateTime(2026, 8, 31)
        };
        var class2 = new Class
        {
            CourseId  = course1.Id,
            Name      = "PRM392 - SE1802",
            StartDate = new DateTime(2026, 6, 1),
            EndDate   = new DateTime(2026, 8, 31)
        };
        var class3 = new Class
        {
            CourseId  = course2.Id,
            Name      = "SWP391 - SE1801",
            StartDate = new DateTime(2026, 6, 10),
            EndDate   = new DateTime(2026, 9, 10)
        };

        await context.Classes.AddRangeAsync(class1, class2, class3);
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 4. CLASS MEMBERS
        // ─────────────────────────────────────────────────────────────────────
        await context.ClassMembers.AddRangeAsync(
            new ClassMember { ClassId = class1.Id, UserId = learner1.Id, JoinedAt = DateTime.UtcNow },
            new ClassMember { ClassId = class1.Id, UserId = learner2.Id, JoinedAt = DateTime.UtcNow },
            new ClassMember { ClassId = class1.Id, UserId = learner3.Id, JoinedAt = DateTime.UtcNow },
            new ClassMember { ClassId = class2.Id, UserId = learner4.Id, JoinedAt = DateTime.UtcNow },
            new ClassMember { ClassId = class3.Id, UserId = learner1.Id, JoinedAt = DateTime.UtcNow },
            new ClassMember { ClassId = class3.Id, UserId = learner2.Id, JoinedAt = DateTime.UtcNow }
        );
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 5. LEARNING PATHS
        // ─────────────────────────────────────────────────────────────────────
        var path1W1 = new LearningPath
        {
            ClassId    = class1.Id,
            Title      = "Tuần 1: Giới thiệu Flutter & Dart",
            WeekNumber = 1
        };
        var path1W2 = new LearningPath
        {
            ClassId    = class1.Id,
            Title      = "Tuần 2: Widgets & Layouts",
            WeekNumber = 2
        };
        var path1W3 = new LearningPath
        {
            ClassId    = class1.Id,
            Title      = "Tuần 3: State Management với Provider",
            WeekNumber = 3
        };

        await context.LearningPaths.AddRangeAsync(path1W1, path1W2, path1W3);
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 6. LEARNING MATERIALS
        // ─────────────────────────────────────────────────────────────────────
        await context.LearningMaterials.AddRangeAsync(
            new LearningMaterial
            {
                LearningPathId = path1W1.Id,
                Title          = "Video: Dart cơ bản trong 30 phút",
                Type           = MaterialType.Video,
                LinkUrl        = "https://www.youtube.com/watch?v=veMhOYRib9o"
            },
            new LearningMaterial
            {
                LearningPathId = path1W1.Id,
                Title          = "Slide: Giới thiệu Flutter & Dart",
                Type           = MaterialType.Document,
                FileUrl        = "/materials/week1-intro-flutter.pdf"
            },
            new LearningMaterial
            {
                LearningPathId = path1W1.Id,
                Title          = "Tài liệu chính thức Flutter",
                Type           = MaterialType.Link,
                LinkUrl        = "https://flutter.dev/docs"
            },
            new LearningMaterial
            {
                LearningPathId = path1W2.Id,
                Title          = "Video: Flutter Widgets Deep Dive",
                Type           = MaterialType.Video,
                LinkUrl        = "https://www.youtube.com/watch?v=b_sQ9bMltGU"
            },
            new LearningMaterial
            {
                LearningPathId = path1W2.Id,
                Title          = "Slide: Layouts trong Flutter",
                Type           = MaterialType.Document,
                FileUrl        = "/materials/week2-layouts.pdf"
            },
            new LearningMaterial
            {
                LearningPathId = path1W3.Id,
                Title          = "Video: Provider State Management",
                Type           = MaterialType.Video,
                LinkUrl        = "https://www.youtube.com/watch?v=d9e-n6Dqk4I"
            }
        );
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 7. ACTIVITIES
        // ─────────────────────────────────────────────────────────────────────
        var actPre1 = new Activity
        {
            LearningPathId = path1W1.Id,
            Title          = "[Pre-Class] Xem video Dart cơ bản",
            Description    = "Xem video 'Dart cơ bản trong 30 phút' và ghi chú các điểm chính về: variables, functions, classes, async/await.",
            Type           = ActivityType.PreClass,
            Deadline       = new DateTime(2026, 6, 8, 23, 59, 0)
        };
        var actIn1 = new Activity
        {
            LearningPathId = path1W1.Id,
            Title          = "[In-Class] Thực hành Hello Flutter",
            Description    = "Tạo project Flutter đầu tiên, chạy thử trên emulator và sửa đổi giao diện mặc định.",
            Type           = ActivityType.InClass,
            Deadline       = new DateTime(2026, 6, 9, 17, 0, 0)
        };
        var actPost1 = new Activity
        {
            LearningPathId = path1W1.Id,
            Title          = "[Post-Class] Viết reflection tuần 1",
            Description    = "Viết reflection về những gì đã học trong tuần 1. Bao gồm: điều đã hiểu, điều còn thắc mắc, và kế hoạch áp dụng.",
            Type           = ActivityType.PostClass,
            Deadline       = new DateTime(2026, 6, 10, 23, 59, 0)
        };
        var actPre2 = new Activity
        {
            LearningPathId = path1W2.Id,
            Title          = "[Pre-Class] Nghiên cứu Flutter Widgets",
            Description    = "Đọc tài liệu về các Widget cơ bản: Container, Row, Column, Stack, ListView. Ghi chú use-case của từng widget.",
            Type           = ActivityType.PreClass,
            Deadline       = new DateTime(2026, 6, 15, 23, 59, 0)
        };
        var actIn2 = new Activity
        {
            LearningPathId = path1W2.Id,
            Title          = "[In-Class] Xây dựng layout Profile Screen",
            Description    = "Dùng các Widget đã học để xây dựng màn hình Profile Screen theo bản thiết kế được cung cấp.",
            Type           = ActivityType.InClass,
            Deadline       = new DateTime(2026, 6, 16, 17, 0, 0)
        };

        await context.Activities.AddRangeAsync(actPre1, actIn1, actPost1, actPre2, actIn2);
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 8. ACTIVITY SUBMISSIONS (Evidence)
        // ─────────────────────────────────────────────────────────────────────
        var sub1 = new ActivitySubmission
        {
            ActivityId  = actPre1.Id,
            UserId      = learner1.Id,
            Note        = "Em đã xem video và ghi chú đầy đủ. Dart syntax khá giống Java, phần async/await rất thú vị.",
            FileUrl     = "/evidences/learner1-week1-pre-notes.pdf",
            Status      = EvidenceStatus.Approved,
            SubmittedAt = new DateTime(2026, 6, 8, 10, 30, 0),
            ReviewedAt  = new DateTime(2026, 6, 8, 15, 0, 0)
        };
        var sub2 = new ActivitySubmission
        {
            ActivityId  = actPre1.Id,
            UserId      = learner2.Id,
            Note        = "Em đã xem xong video và hiểu cơ bản về Dart. Còn thắc mắc về null safety.",
            FileUrl     = "/evidences/learner2-week1-pre-notes.pdf",
            Status      = EvidenceStatus.Pending,
            SubmittedAt = new DateTime(2026, 6, 8, 22, 45, 0)
        };
        var sub3 = new ActivitySubmission
        {
            ActivityId  = actIn1.Id,
            UserId      = learner1.Id,
            Note        = "Em đã tạo project và chạy được trên emulator. Đã thêm custom AppBar và thay đổi màu theme.",
            FileUrl     = "/evidences/learner1-week1-inclass-screenshot.png",
            Status      = EvidenceStatus.Approved,
            SubmittedAt = new DateTime(2026, 6, 9, 16, 30, 0),
            ReviewedAt  = new DateTime(2026, 6, 9, 17, 30, 0)
        };
        var sub4 = new ActivitySubmission
        {
            ActivityId  = actPost1.Id,
            UserId      = learner1.Id,
            Note        = "Reflection: Tuần này em đã học được cơ bản về Flutter và Dart. Điểm thú vị nhất là cách Flutter render UI bằng widget tree. Kế hoạch tuần sau sẽ thực hành thêm về layouts.",
            Status      = EvidenceStatus.Pending,
            SubmittedAt = new DateTime(2026, 6, 10, 20, 0, 0)
        };
        var sub5 = new ActivitySubmission
        {
            ActivityId  = actPre1.Id,
            UserId      = learner3.Id,
            Note        = "Em chưa hiểu rõ phần async/await.",
            Status      = EvidenceStatus.Rejected,
            SubmittedAt = new DateTime(2026, 6, 8, 8, 0, 0),
            ReviewedAt  = new DateTime(2026, 6, 8, 16, 0, 0)
        };

        await context.ActivitySubmissions.AddRangeAsync(sub1, sub2, sub3, sub4, sub5);
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 9. EVIDENCE COMMENTS
        // ─────────────────────────────────────────────────────────────────────
        await context.EvidenceComments.AddRangeAsync(
            new EvidenceComment
            {
                SubmissionId = sub1.Id,
                UserId       = instructor1.Id,
                Content      = "Bài nộp tốt! Ghi chú đầy đủ và có ví dụ minh họa rõ ràng.",
                CreatedAt    = new DateTime(2026, 6, 8, 15, 0, 0)
            },
            new EvidenceComment
            {
                SubmissionId = sub5.Id,
                UserId       = instructor1.Id,
                Content      = "Em cần xem lại video phần async/await và thực hành thêm ví dụ trước khi nộp lại.",
                CreatedAt    = new DateTime(2026, 6, 8, 16, 0, 0)
            },
            new EvidenceComment
            {
                SubmissionId = sub5.Id,
                UserId       = learner3.Id,
                Content      = "Vâng em cảm ơn thầy. Em sẽ xem lại và nộp lại ạ.",
                CreatedAt    = new DateTime(2026, 6, 8, 17, 30, 0)
            }
        );
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 10. PROJECTS & MILESTONES
        // ─────────────────────────────────────────────────────────────────────
        var project1 = new Project
        {
            ClassId     = class1.Id,
            Title       = "Dự án: Xây dựng ứng dụng Flipped Classroom",
            Description = "Nhóm sẽ xây dựng ứng dụng mobile hỗ trợ mô hình lớp học đảo ngược sử dụng Flutter và ASP.NET Core."
        };

        await context.Projects.AddAsync(project1);
        await context.SaveChangesAsync();

        var ms1 = new Milestone
        {
            ProjectId   = project1.Id,
            Title       = "Milestone 1: Setup & Architecture",
            Description = "Thiết lập project, định nghĩa kiến trúc hệ thống, tạo database schema và cấu trúc thư mục.",
            DueDate     = new DateTime(2026, 6, 20)
        };
        var ms2 = new Milestone
        {
            ProjectId   = project1.Id,
            Title       = "Milestone 2: Authentication & Core Features",
            Description = "Implement Authentication (Login/Register), Course management, và Learning Path screens.",
            DueDate     = new DateTime(2026, 7, 5)
        };
        var ms3 = new Milestone
        {
            ProjectId   = project1.Id,
            Title       = "Milestone 3: Activities & Evidence",
            Description = "Implement Pre/In/Post-class activities, evidence submission và review.",
            DueDate     = new DateTime(2026, 7, 20)
        };
        var ms4 = new Milestone
        {
            ProjectId   = project1.Id,
            Title       = "Milestone 4: Review & Analytics",
            Description = "Implement Peer Review system, Feedback, và Learning Analytics dashboard.",
            DueDate     = new DateTime(2026, 8, 5)
        };

        await context.Milestones.AddRangeAsync(ms1, ms2, ms3, ms4);
        await context.SaveChangesAsync();

        // Milestone submission mẫu
        await context.MilestoneSubmissions.AddAsync(new MilestoneSubmission
        {
            MilestoneId = ms1.Id,
            UserId      = learner1.Id,
            Description = "Nhóm đã hoàn thành setup project Flutter và ASP.NET Core. Database đã được migrate. Kiến trúc 3-layer và MVVM đã được áp dụng.",
            FileUrl     = "/milestones/group1-ms1-report.pdf",
            SubmittedAt = new DateTime(2026, 6, 19, 22, 0, 0)
        });
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 11. REVIEW SESSIONS & ASSIGNMENTS
        // ─────────────────────────────────────────────────────────────────────
        var reviewSession1 = new ReviewSession
        {
            ClassId   = class1.Id,
            Title     = "Peer Review - Milestone 1",
            StartDate = new DateTime(2026, 6, 21),
            EndDate   = new DateTime(2026, 6, 23)
        };

        await context.ReviewSessions.AddAsync(reviewSession1);
        await context.SaveChangesAsync();

        var ra1 = new ReviewAssignment
        {
            SessionId  = reviewSession1.Id,
            ReviewerId = learner1.Id,
            RevieweeId = learner2.Id
        };
        var ra2 = new ReviewAssignment
        {
            SessionId  = reviewSession1.Id,
            ReviewerId = learner2.Id,
            RevieweeId = learner3.Id
        };
        var ra3 = new ReviewAssignment
        {
            SessionId  = reviewSession1.Id,
            ReviewerId = learner3.Id,
            RevieweeId = learner1.Id
        };

        await context.ReviewAssignments.AddRangeAsync(ra1, ra2, ra3);
        await context.SaveChangesAsync();

        // Feedback mẫu
        await context.Feedbacks.AddRangeAsync(
            new Feedback
            {
                AssignmentId = ra1.Id,
                Content      = "Nhóm bạn đã làm rất tốt phần setup. Kiến trúc rõ ràng và có document đầy đủ. Một điểm có thể cải thiện là thêm diagram ERD vào báo cáo.",
                Rating       = 4,
                CreatedAt    = new DateTime(2026, 6, 22, 10, 0, 0)
            },
            new Feedback
            {
                AssignmentId = ra3.Id,
                Content      = "Bài nộp đúng hạn, có đầy đủ nội dung yêu cầu. Database schema khá tốt nhưng cần thêm index cho một số bảng.",
                Rating       = 3,
                CreatedAt    = new DateTime(2026, 6, 22, 14, 0, 0)
            }
        );
        await context.SaveChangesAsync();

        // ─────────────────────────────────────────────────────────────────────
        // 12. NOTIFICATIONS
        // ─────────────────────────────────────────────────────────────────────
        await context.Notifications.AddRangeAsync(
            new Notification
            {
                UserId    = learner1.Id,
                Title     = "Evidence được duyệt ✅",
                Body      = "Bài nộp '[Pre-Class] Xem video Dart cơ bản' của bạn đã được Approved.",
                IsRead    = true,
                CreatedAt = new DateTime(2026, 6, 8, 15, 0, 0)
            },
            new Notification
            {
                UserId    = learner1.Id,
                Title     = "Hoạt động mới tuần 2 📚",
                Body      = "Tuần 2 đã có hoạt động mới: '[Pre-Class] Nghiên cứu Flutter Widgets'. Hạn nộp: 15/06.",
                IsRead    = false,
                CreatedAt = new DateTime(2026, 6, 11, 8, 0, 0)
            },
            new Notification
            {
                UserId    = learner2.Id,
                Title     = "Nhắc nhở deadline ⏰",
                Body      = "Hoạt động '[Pre-Class] Xem video Dart cơ bản' sẽ hết hạn trong 2 giờ!",
                IsRead    = false,
                CreatedAt = new DateTime(2026, 6, 8, 21, 59, 0)
            },
            new Notification
            {
                UserId    = learner3.Id,
                Title     = "Evidence bị từ chối ❌",
                Body      = "Bài nộp '[Pre-Class] Xem video Dart cơ bản' đã bị Rejected. Xem bình luận của giảng viên để biết thêm.",
                IsRead    = false,
                CreatedAt = new DateTime(2026, 6, 8, 16, 0, 0)
            },
            new Notification
            {
                UserId    = learner1.Id,
                Title     = "Peer Review mới 🔍",
                Body      = "Phiên review 'Peer Review - Milestone 1' đã bắt đầu. Bạn cần review bài của 1 bạn khác.",
                IsRead    = false,
                CreatedAt = new DateTime(2026, 6, 21, 8, 0, 0)
            }
        );
        await context.SaveChangesAsync();

        Console.WriteLine("✅ Seed data completed successfully!");
    }
}
