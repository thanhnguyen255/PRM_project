using backend.BLL.Helpers;
using backend.DAL.Enums;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.DAL;

/// <summary>
/// Seed dữ liệu test cơ bản cho Development mode.
/// Chạy khi DB rỗng (không có users).
/// </summary>
public static class DataSeeder
{
    public static async Task SeedAsync(AppDbContext db)
    {
        // Skip nếu đã có dữ liệu
        if (await db.Users.AnyAsync()) return;

        Console.WriteLine("[Seeder] Seeding initial data...");

        // ─── Users ──────────────────────────────────────────────────────────────
        var instructor = new User
        {
            Email = "instructor@test.com",
            PasswordHash = PasswordHelper.Hash("123456"),
            FullName = "Nguyễn Thị Giảng Viên",
            Role = UserRole.Instructor,
            CreatedAt = DateTime.UtcNow
        };

        var learner1 = new User
        {
            Email = "learner@test.com",
            PasswordHash = PasswordHelper.Hash("123456"),
            FullName = "Trần Văn Học Viên",
            Role = UserRole.Learner,
            CreatedAt = DateTime.UtcNow
        };

        var learner2 = new User
        {
            Email = "learner2@test.com",
            PasswordHash = PasswordHelper.Hash("123456"),
            FullName = "Lê Thị Thứ Hai",
            Role = UserRole.Learner,
            CreatedAt = DateTime.UtcNow
        };

        db.Users.AddRange(instructor, learner1, learner2);
        await db.SaveChangesAsync();

        // ─── Course ─────────────────────────────────────────────────────────────
        var course = new Course
        {
            Title = "Lập Trình Di Động PRM392",
            Description = "Học lập trình mobile với Flutter và .NET",
            InstructorId = instructor.Id,
            CreatedAt = DateTime.UtcNow
        };
        db.Courses.Add(course);
        await db.SaveChangesAsync();

        // ─── Class ──────────────────────────────────────────────────────────────
        var cls = new Class
        {
            CourseId = course.Id,
            Name = "Lớp SE1701 — Kỳ 1/2026",
            StartDate = DateTime.UtcNow.AddDays(-7),
            EndDate = DateTime.UtcNow.AddDays(84)
        };
        db.Classes.Add(cls);
        await db.SaveChangesAsync();

        // ─── ClassMembers ───────────────────────────────────────────────────────
        db.ClassMembers.AddRange(
            new ClassMember { ClassId = cls.Id, UserId = learner1.Id, JoinedAt = DateTime.UtcNow.AddDays(-7) },
            new ClassMember { ClassId = cls.Id, UserId = learner2.Id, JoinedAt = DateTime.UtcNow.AddDays(-7) }
        );
        await db.SaveChangesAsync();

        // ─── Learning Paths (3 tuần) ────────────────────────────────────────────
        var paths = new List<LearningPath>();
        for (int w = 1; w <= 3; w++)
        {
            paths.Add(new LearningPath
            {
                ClassId = cls.Id,
                Title = $"Tuần {w}: {(w == 1 ? "Giới thiệu Flutter" : w == 2 ? "State Management" : "API Integration")}",
                WeekNumber = w
            });
        }
        db.LearningPaths.AddRange(paths);
        await db.SaveChangesAsync();

        // ─── Materials (tuần 1) ─────────────────────────────────────────────────
        db.LearningMaterials.AddRange(
            new LearningMaterial
            {
                LearningPathId = paths[0].Id,
                Title = "Video giới thiệu Flutter",
                Type = MaterialType.Video,
                FileUrl = "https://www.youtube.com/watch?v=1gDhl4leEzA"
            },
            new LearningMaterial
            {
                LearningPathId = paths[0].Id,
                Title = "Slide bài giảng PDF",
                Type = MaterialType.Document,
                FileUrl = "https://example.com/slide1.pdf"
            }
        );
        await db.SaveChangesAsync();

        // ─── Activities (mỗi tuần: 1 Pre + 1 In + 1 Post) ──────────────────────
        var activities = new List<Activity>();
        foreach (var path in paths)
        {
            activities.Add(new Activity
            {
                LearningPathId = path.Id,
                Title = $"[Pre] Xem tài liệu {path.WeekNumber}",
                Type = ActivityType.PreClass,
                Description = "Xem video và đọc tài liệu trước buổi học.",
                Deadline = DateTime.UtcNow.AddDays(path.WeekNumber * 7 - 4)
            });
            activities.Add(new Activity
            {
                LearningPathId = path.Id,
                Title = $"[In] Bài tập thực hành {path.WeekNumber}",
                Type = ActivityType.InClass,
                Description = "Hoàn thành bài tập trong buổi học.",
                Deadline = DateTime.UtcNow.AddDays(path.WeekNumber * 7 - 1)
            });
            activities.Add(new Activity
            {
                LearningPathId = path.Id,
                Title = $"[Post] Nộp bằng chứng tuần {path.WeekNumber}",
                Type = ActivityType.PostClass,
                Description = "Nộp screenshot/video hoàn thành bài tập.",
                Deadline = DateTime.UtcNow.AddDays(path.WeekNumber * 7 + 2)
            });
        }
        db.Activities.AddRange(activities);
        await db.SaveChangesAsync();

        // ─── Notifications (cho learner1) ───────────────────────────────────────
        db.Notifications.AddRange(
            new Notification
            {
                UserId = learner1.Id,
                Title = "Chào mừng bạn tham gia lớp học!",
                Body = $"Bạn đã được thêm vào lớp {cls.Name}.",
                IsRead = false,
                CreatedAt = DateTime.UtcNow.AddDays(-7)
            },
            new Notification
            {
                UserId = learner1.Id,
                Title = "Nhắc nhở: Sắp đến hạn nộp bài",
                Body = "Bài Pre-class tuần 1 sắp đến deadline. Hãy hoàn thành sớm!",
                IsRead = false,
                CreatedAt = DateTime.UtcNow.AddHours(-2)
            }
        );
        await db.SaveChangesAsync();

        Console.WriteLine($"[Seeder] Done! Test accounts:\n  Instructor: instructor@test.com / 123456\n  Learner:    learner@test.com / 123456");
    }
}
