using backend.BLL.DTOs.Class;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class ClassService : IClassService
{
    private readonly AppDbContext _db;

    public ClassService(AppDbContext db)
    {
        _db = db;
    }

    public async Task<List<ClassDto>> GetMyClassesAsync(int userId)
    {
        // Lấy danh sách approved submissions của user để tính progress
        var approvedActivityIds = await _db.ActivitySubmissions
            .Where(s => s.UserId == userId && s.Status == EvidenceStatus.Approved)
            .Select(s => s.ActivityId)
            .ToListAsync();

        var classMembers = await _db.ClassMembers
            .Where(cm => cm.UserId == userId)
            .Include(cm => cm.Class)
                .ThenInclude(c => c.Course)
                    .ThenInclude(co => co.Instructor)
            .Include(cm => cm.Class.Members)
            .Include(cm => cm.Class.LearningPaths)
                .ThenInclude(lp => lp.Activities)
            .ToListAsync();

        return classMembers.Select(cm =>
        {
            var cls = cm.Class;
            var totalActivities = cls.LearningPaths.SelectMany(lp => lp.Activities).Count();
            var completedActivities = cls.LearningPaths
                .SelectMany(lp => lp.Activities)
                .Count(a => approvedActivityIds.Contains(a.Id));

            var progressPercent = totalActivities > 0
                ? (double)completedActivities / totalActivities
                : 0.0;

            var instructorName = cls.Course.Instructor?.FullName;

            return new ClassDto
            {
                Id = cls.Id,
                CourseId = cls.CourseId,
                CourseTitle = cls.Course.Title,
                Name = cls.Name,
                StartDate = cls.StartDate,
                EndDate = cls.EndDate,
                MemberCount = cls.Members.Count,
                WeekCount = cls.LearningPaths.Count,
                ProgressPercent = Math.Round(progressPercent, 2),
                InstructorName = instructorName
            };
        }).ToList();
    }

    public async Task<ClassDto> GetClassByIdAsync(int classId, int userId)
    {
        // Kiểm tra user có trong class không
        var isMember = await _db.ClassMembers
            .AnyAsync(cm => cm.ClassId == classId && cm.UserId == userId);
        if (!isMember)
            throw new UnauthorizedAccessException("Bạn không có quyền truy cập lớp học này.");

        var approvedActivityIds = await _db.ActivitySubmissions
            .Where(s => s.UserId == userId && s.Status == EvidenceStatus.Approved)
            .Select(s => s.ActivityId)
            .ToListAsync();

        var cls = await _db.Classes
            .Include(c => c.Course)
                .ThenInclude(co => co.Instructor)
            .Include(c => c.Members)
            .Include(c => c.LearningPaths)
                .ThenInclude(lp => lp.Activities)
            .FirstOrDefaultAsync(c => c.Id == classId)
            ?? throw new KeyNotFoundException("Không tìm thấy lớp học.");

        var totalActivities = cls.LearningPaths.SelectMany(lp => lp.Activities).Count();
        var completedActivities = cls.LearningPaths
            .SelectMany(lp => lp.Activities)
            .Count(a => approvedActivityIds.Contains(a.Id));

        var progressPercent = totalActivities > 0
            ? (double)completedActivities / totalActivities
            : 0.0;

        return new ClassDto
        {
            Id = cls.Id,
            CourseId = cls.CourseId,
            CourseTitle = cls.Course.Title,
            Name = cls.Name,
            StartDate = cls.StartDate,
            EndDate = cls.EndDate,
            MemberCount = cls.Members.Count,
            WeekCount = cls.LearningPaths.Count,
            ProgressPercent = Math.Round(progressPercent, 2),
            InstructorName = cls.Course.Instructor?.FullName
        };
    }

    public async Task<List<ClassMemberDto>> GetMembersAsync(int classId)
    {
        return await _db.ClassMembers
            .Where(cm => cm.ClassId == classId)
            .Include(cm => cm.User)
            .Select(cm => new ClassMemberDto
            {
                UserId = cm.UserId,
                FullName = cm.User.FullName,
                Email = cm.User.Email,
                AvatarUrl = cm.User.AvatarUrl,
                JoinedAt = cm.JoinedAt
            })
            .ToListAsync();
    }
}
