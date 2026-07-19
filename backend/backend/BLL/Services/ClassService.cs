using backend.BLL.DTOs.Class;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class ClassService : IClassService
{
    private readonly AppDbContext _db;
    private readonly IUnitOfWork _unitOfWork;

    public ClassService(AppDbContext db, IUnitOfWork unitOfWork)
    {
        _db = db;
        _unitOfWork = unitOfWork;
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
        var cls = await _db.Classes
            .Include(c => c.Course)
                .ThenInclude(co => co.Instructor)
            .Include(c => c.Members)
            .Include(c => c.LearningPaths)
                .ThenInclude(lp => lp.Activities)
            .FirstOrDefaultAsync(c => c.Id == classId)
            ?? throw new KeyNotFoundException("Không tìm thấy lớp học.");

        // Kiểm tra xem user có phải học viên trong lớp hoặc giảng viên sở hữu khóa học không
        var isMember = await _db.ClassMembers
            .AnyAsync(cm => cm.ClassId == classId && cm.UserId == userId);
        var isInstructor = cls.Course.InstructorId == userId;

        if (!isMember && !isInstructor)
            throw new UnauthorizedAccessException("Bạn không có quyền truy cập lớp học này.");

        double progressPercent = 0.0;
        var activityIds = cls.LearningPaths.SelectMany(lp => lp.Activities).Select(a => a.Id).ToList();
        var totalActivities = activityIds.Count;
        if (totalActivities > 0)
        {
            if (isInstructor)
            {
                var memberIds = cls.Members.Select(m => m.UserId).ToList();
                if (memberIds.Count > 0)
                {
                    var approvedSubmissions = await _db.ActivitySubmissions
                        .Where(s => memberIds.Contains(s.UserId) && s.Status == EvidenceStatus.Approved)
                        .Where(s => activityIds.Contains(s.ActivityId))
                        .GroupBy(s => s.UserId)
                        .Select(g => g.Select(s => s.ActivityId).Distinct().Count())
                        .ToListAsync();
                    
                    double totalProgressSum = 0;
                    foreach (var count in approvedSubmissions)
                    {
                        totalProgressSum += (double)count / totalActivities;
                    }
                    progressPercent = totalProgressSum / memberIds.Count;
                }
            }
            else
            {
                var approvedActivityIds = await _db.ActivitySubmissions
                    .Where(s => s.UserId == userId && s.Status == EvidenceStatus.Approved)
                    .Select(s => s.ActivityId)
                    .ToListAsync();

                var completedActivities = activityIds.Count(aid => approvedActivityIds.Contains(aid));

                progressPercent = (double)completedActivities / totalActivities;
            }
        }

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

    public async Task<IEnumerable<ClassDto>> GetClassesByCourseAsync(int courseId, int instructorId)
    {
        // Verify course belongs to instructor
        var course = await _unitOfWork.Repository<Course>().GetQueryable()
            .FirstOrDefaultAsync(c => c.Id == courseId && c.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu khóa học này.");

        var classes = await _unitOfWork.Repository<Class>().GetQueryable()
            .Where(c => c.CourseId == courseId)
            .Include(c => c.Members)
            .Include(c => c.LearningPaths)
                .ThenInclude(lp => lp.Activities)
            .ToListAsync();

        var result = new List<ClassDto>();
        foreach (var c in classes)
        {
            double progressPercent = 0.0;
            var activityIds = c.LearningPaths.SelectMany(lp => lp.Activities).Select(a => a.Id).ToList();
            var totalActivities = activityIds.Count;
            if (totalActivities > 0)
            {
                var memberIds = c.Members.Select(m => m.UserId).ToList();
                if (memberIds.Count > 0)
                {
                    var approvedSubmissions = await _db.ActivitySubmissions
                        .Where(s => memberIds.Contains(s.UserId) && s.Status == EvidenceStatus.Approved)
                        .Where(s => activityIds.Contains(s.ActivityId))
                        .GroupBy(s => s.UserId)
                        .Select(g => g.Select(s => s.ActivityId).Distinct().Count())
                        .ToListAsync();
                    
                    double totalProgressSum = 0;
                    foreach (var count in approvedSubmissions)
                    {
                        totalProgressSum += (double)count / totalActivities;
                    }
                    progressPercent = totalProgressSum / memberIds.Count;
                }
            }

            result.Add(new ClassDto
            {
                Id = c.Id,
                Name = c.Name,
                CourseId = c.CourseId,
                CourseTitle = course.Title,
                StartDate = c.StartDate,
                EndDate = c.EndDate,
                MemberCount = c.Members.Count,
                WeekCount = c.LearningPaths.Count,
                ProgressPercent = Math.Round(progressPercent, 2)
            });
        }
        return result;
    }

    public async Task<ClassDto> CreateClassAsync(CreateClassDto dto, int instructorId)
    {
        // Verify course belongs to instructor
        var course = await _unitOfWork.Repository<Course>().GetQueryable()
            .FirstOrDefaultAsync(c => c.Id == dto.CourseId && c.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu khóa học này.");

        // Validate ngày tạo lớp học (StartDate >= ngày hôm nay theo UTC)
        var today = DateTime.UtcNow.Date;
        if (dto.StartDate.Date < today)
        {
            throw new ArgumentException("Ngày bắt đầu không được trước hôm nay.");
        }
        if (dto.EndDate < dto.StartDate)
        {
            throw new ArgumentException("Ngày kết thúc không được trước ngày bắt đầu.");
        }

        var newClass = new Class
        {
            Name = dto.Name,
            CourseId = dto.CourseId,
            StartDate = dto.StartDate,
            EndDate = dto.EndDate
        };

        await _unitOfWork.Repository<Class>().AddAsync(newClass);
        await _unitOfWork.SaveChangesAsync();

        return new ClassDto
        {
            Id = newClass.Id,
            Name = newClass.Name,
            CourseId = newClass.CourseId,
            CourseTitle = course.Title,
            StartDate = newClass.StartDate,
            EndDate = newClass.EndDate
        };
    }

    public async Task<bool> AddMemberToClassAsync(int classId, AddClassMemberDto dto, int instructorId)
    {
        // Verify class belongs to course owned by instructor
        var classObj = await _unitOfWork.Repository<Class>().GetQueryable()
            .Include(c => c.Course)
            .FirstOrDefaultAsync(c => c.Id == classId && c.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu lớp học này.");

        // Check if user exists by email
        var user = await _unitOfWork.Repository<User>().GetQueryable()
            .FirstOrDefaultAsync(u => u.Email == dto.Email);
        if (user == null) return false;

        // Check if member already in class
        var existingMember = await _unitOfWork.Repository<ClassMember>().GetQueryable()
            .FirstOrDefaultAsync(cm => cm.ClassId == classId && cm.UserId == user.Id);

        if (existingMember != null) return true; // Already added

        var classMember = new ClassMember
        {
            ClassId = classId,
            UserId = user.Id,
            JoinedAt = DateTime.UtcNow
        };

        await _unitOfWork.Repository<ClassMember>().AddAsync(classMember);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }

    public async Task<bool> RemoveMemberFromClassAsync(int classId, int userId, int instructorId)
    {
        // Verify class belongs to course owned by instructor
        var classObj = await _unitOfWork.Repository<Class>().GetQueryable()
            .Include(c => c.Course)
            .FirstOrDefaultAsync(c => c.Id == classId && c.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu lớp học này.");

        // Find member
        var classMember = await _unitOfWork.Repository<ClassMember>().GetQueryable()
            .FirstOrDefaultAsync(cm => cm.ClassId == classId && cm.UserId == userId);

        if (classMember == null) return false;

        _unitOfWork.Repository<ClassMember>().Delete(classMember);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }
}
