using backend.BLL.DTOs.LearningPath;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class LearningPathService : ILearningPathService
{
    private readonly AppDbContext _db;
    private readonly IUnitOfWork _unitOfWork;

    public LearningPathService(AppDbContext db, IUnitOfWork unitOfWork)
    {
        _db = db;
        _unitOfWork = unitOfWork;
    }

    public async Task<List<LearningPathDto>> GetByClassAsync(int classId, int userId)
    {
        // Lấy submission đã approved của user
        var approvedActivityIds = await _db.ActivitySubmissions
            .Where(s => s.UserId == userId && s.Status == EvidenceStatus.Approved)
            .Select(s => s.ActivityId)
            .ToListAsync();

        var paths = await _db.LearningPaths
            .Where(lp => lp.ClassId == classId)
            .Include(lp => lp.Activities)
            .OrderBy(lp => lp.WeekNumber)
            .ToListAsync();

        var result = new List<LearningPathDto>();

        foreach (var path in paths)
        {
            var total = path.Activities.Count;
            var completed = path.Activities.Count(a => approvedActivityIds.Contains(a.Id));

            string state;
            if (!path.IsUnlocked)
                state = "locked";
            else if (total > 0 && completed == total)
                state = "completed";
            else if (completed > 0)
                state = "inProgress";
            else
                state = "notStarted";

            result.Add(new LearningPathDto
            {
                Id = path.Id,
                Title = path.Title,
                WeekNumber = path.WeekNumber,
                TotalActivities = total,
                CompletedActivities = completed,
                State = state,
                ClassId = path.ClassId,
                IsUnlocked = path.IsUnlocked
            });
        }

        return result;
    }

    public async Task<LearningPathDetailDto> GetByIdAsync(int pathId, int userId)
    {
        var path = await _db.LearningPaths
            .Include(lp => lp.Materials)
            .Include(lp => lp.Activities)
            .FirstOrDefaultAsync(lp => lp.Id == pathId)
            ?? throw new KeyNotFoundException("Không tìm thấy học phần.");

        // Lấy submission của user cho các activities trong path này
        var activityIds = path.Activities.Select(a => a.Id).ToList();
        
        var submissionsList = await _db.ActivitySubmissions
            .Where(s => s.UserId == userId && activityIds.Contains(s.ActivityId))
            .ToListAsync();
            
        var submissions = submissionsList
            .GroupBy(s => s.ActivityId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(s => s.Id).First());
        ActivitySummaryDto MapActivity(DAL.Models.Activity a) => new()
        {
            Id = a.Id,
            Title = a.Title,
            Type = a.Type.ToString(),
            Deadline = a.Deadline,
            SubmissionStatus = submissions.ContainsKey(a.Id) ? submissions[a.Id].Status.ToString() : null
        };

        return new LearningPathDetailDto
        {
            Id = path.Id,
            ClassId = path.ClassId,
            Title = path.Title,
            WeekNumber = path.WeekNumber,
            Materials = path.Materials.Select(m => new MaterialDto
            {
                Id = m.Id,
                Title = m.Title,
                Type = m.Type.ToString(),
                FileUrl = m.FileUrl,
                LinkUrl = m.LinkUrl
            }).ToList(),
            PreClassActivities = path.Activities
                .Where(a => a.Type == ActivityType.PreClass)
                .Select(MapActivity).ToList(),
            InClassActivities = path.Activities
                .Where(a => a.Type == ActivityType.InClass)
                .Select(MapActivity).ToList(),
            PostClassActivities = path.Activities
                .Where(a => a.Type == ActivityType.PostClass)
                .Select(MapActivity).ToList()
        };
    }

    public async Task<IEnumerable<LearningPathDto>> GetLearningPathsByClassAsync(int classId, int instructorId)
    {
        // Verify class belongs to course owned by instructor
        var classObj = await _unitOfWork.Repository<Class>().GetQueryable()
            .Include(c => c.Course)
            .FirstOrDefaultAsync(c => c.Id == classId && c.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu lớp học này.");

        var paths = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Where(lp => lp.ClassId == classId)
            .OrderBy(lp => lp.WeekNumber)
            .ToListAsync();

        return paths.Select(lp => new LearningPathDto
        {
            Id = lp.Id,
            Title = lp.Title,
            ClassId = lp.ClassId,
            WeekNumber = lp.WeekNumber,
            IsUnlocked = lp.IsUnlocked
        });
    }

    public async Task<LearningPathDto> CreateLearningPathAsync(CreateLearningPathDto dto, int instructorId)
    {
        // Verify class belongs to course owned by instructor
        var classObj = await _unitOfWork.Repository<Class>().GetQueryable()
            .Include(c => c.Course)
            .FirstOrDefaultAsync(c => c.Id == dto.ClassId && c.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu lớp học này.");

        var learningPath = new LearningPath
        {
            Title = dto.Title,
            ClassId = dto.ClassId,
            WeekNumber = dto.WeekNumber
        };

        await _unitOfWork.Repository<LearningPath>().AddAsync(learningPath);
        await _unitOfWork.SaveChangesAsync();

        return new LearningPathDto
        {
            Id = learningPath.Id,
            Title = learningPath.Title,
            ClassId = learningPath.ClassId,
            WeekNumber = learningPath.WeekNumber,
            IsUnlocked = learningPath.IsUnlocked
        };
    }

    public async Task<bool> DeleteLearningPathAsync(int id, int instructorId)
    {
        // Verify learning path belongs to class of course owned by instructor
        var learningPath = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Include(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(lp => lp.Id == id && lp.Class.Course.InstructorId == instructorId);

        if (learningPath == null) return false;

        _unitOfWork.Repository<LearningPath>().Delete(learningPath);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }

    public async Task<bool> ToggleLockAsync(int pathId, int instructorId)
    {
        var learningPath = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Include(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(lp => lp.Id == pathId && lp.Class.Course.InstructorId == instructorId);

        if (learningPath == null) return false;

        learningPath.IsUnlocked = !learningPath.IsUnlocked;
        _unitOfWork.Repository<LearningPath>().Update(learningPath);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }
}
