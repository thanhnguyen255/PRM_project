using backend.BLL.DTOs.Activity;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class ActivityService : IActivityService
{
    private readonly AppDbContext _db;
    private readonly IUnitOfWork _unitOfWork;

    public ActivityService(AppDbContext db, IUnitOfWork unitOfWork)
    {
        _db = db;
        _unitOfWork = unitOfWork;
    }

    public async Task<List<ActivityDto>> GetByPathAsync(int pathId, string? type, int userId)
    {
        var query = _db.Activities.Where(a => a.LearningPathId == pathId);

        if (!string.IsNullOrEmpty(type) && Enum.TryParse<ActivityType>(type, true, out var actType))
            query = query.Where(a => a.Type == actType);

        var activities = await query.OrderBy(a => a.Id).ToListAsync();
        var activityIds = activities.Select(a => a.Id).ToList();

        // Lấy submissions của user cho các activities này
        var submissionsList = await _db.ActivitySubmissions
            .Where(s => s.UserId == userId && activityIds.Contains(s.ActivityId))
            .ToListAsync();

        var submissions = submissionsList
            .GroupBy(s => s.ActivityId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(s => s.SubmittedAt).First());

        var reviewSessions = await _db.ReviewSessions
            .Where(rs => activityIds.Contains(rs.ActivityId))
            .ToListAsync();

        return activities.Select(a =>
        {
            submissions.TryGetValue(a.Id, out var sub);
            var rs = reviewSessions.FirstOrDefault(r => r.ActivityId == a.Id);
            return new ActivityDto
            {
                Id = a.Id,
                Title = a.Title,
                Type = a.Type.ToString(),
                Description = a.Description,
                Deadline = a.Deadline,
                SubmissionId = sub?.Id,
                SubmissionStatus = sub?.Status.ToString(),
                SubmittedAt = sub?.SubmittedAt,
                LearningPathId = a.LearningPathId,
                ReviewSessionId = rs?.Id,
                ReviewSessionTitle = rs?.Title,
                IsReviewSessionOpen = rs != null ? (DateTime.UtcNow >= rs.StartDate && DateTime.UtcNow <= rs.EndDate) : null
            };
        }).ToList();
    }

    public async Task<IEnumerable<UpcomingActivityDto>> GetUpcomingActivitiesAsync(int learnerId, int? classId, int limit = 5)
    {
        var query = _db.Activities
            .Include(a => a.LearningPath)
            .Where(a => a.Deadline > DateTime.UtcNow);

        if (classId.HasValue)
        {
            query = query.Where(a => a.LearningPath.ClassId == classId.Value);
        }
        else
        {
            // If no classId is provided, optionally filter by all classes the learner is enrolled in
            var userClassIds = await _db.ClassMembers
                .Where(cm => cm.UserId == learnerId)
                .Select(cm => cm.ClassId)
                .ToListAsync();

            query = query.Where(a => userClassIds.Contains(a.LearningPath.ClassId));
        }

        var activities = await query
            .OrderBy(a => a.Deadline)
            .Take(limit)
            .ToListAsync();

        var activityIds = activities.Select(a => a.Id).ToList();

        var submissionsList = await _db.ActivitySubmissions
            .Where(s => s.UserId == learnerId && activityIds.Contains(s.ActivityId))
            .ToListAsync();
            
        var submissions = submissionsList
            .GroupBy(s => s.ActivityId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(s => s.Id).First());

        return activities.Select(a =>
        {
            submissions.TryGetValue(a.Id, out var sub);
            return new UpcomingActivityDto
            {
                Id = a.Id,
                Title = a.Title,
                Type = a.Type.ToString(),
                Deadline = a.Deadline!.Value,
                SubmissionStatus = sub?.Status.ToString(),
                LearningPathTitle = a.LearningPath.Title
            };
        }).Where(a => a.SubmissionStatus != "Approved").ToList(); // Filter out approved ones
    }

    public async Task<ActivityDetailDto> GetByIdAsync(int activityId, int userId)
    {
        var activity = await _db.Activities
            .Include(a => a.LearningPath)
            .FirstOrDefaultAsync(a => a.Id == activityId)
            ?? throw new KeyNotFoundException("Không tìm thấy hoạt động.");

        var sub = await _db.ActivitySubmissions
            .Where(s => s.ActivityId == activityId && s.UserId == userId)
            .OrderByDescending(s => s.Id)
            .FirstOrDefaultAsync();

        int commentCount = 0;
        if (sub != null)
            commentCount = await _db.EvidenceComments.CountAsync(c => c.SubmissionId == sub.Id);

        var rs = await _db.ReviewSessions.FirstOrDefaultAsync(r => r.ActivityId == activityId);

        return new ActivityDetailDto
        {
            Id = activity.Id,
            LearningPathId = activity.LearningPathId,
            LearningPathTitle = activity.LearningPath.Title,
            Title = activity.Title,
            Type = activity.Type.ToString(),
            Description = activity.Description,
            Deadline = activity.Deadline,
            Submission = sub == null ? null : new SubmissionDetailDto
            {
                Id = sub.Id,
                Status = sub.Status.ToString(),
                Note = sub.Note,
                FileUrl = sub.FileUrl,
                SubmittedAt = sub.SubmittedAt,
                ReviewedAt = sub.ReviewedAt,
                CommentCount = commentCount
            },
            ReviewSessionId = rs?.Id,
            ReviewSessionTitle = rs?.Title,
            IsReviewSessionOpen = rs != null ? (DateTime.UtcNow >= rs.StartDate && DateTime.UtcNow <= rs.EndDate) : null
        };
    }

    public async Task<IEnumerable<ActivityDto>> GetActivitiesByPathAsync(int pathId, string? type, int instructorId)
    {
        // Verify learning path belongs to class of course owned by instructor
        var learningPath = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Include(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(lp => lp.Id == pathId && lp.Class.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu tuần học này.");

        var query = _unitOfWork.Repository<Activity>().GetQueryable()
            .Where(a => a.LearningPathId == pathId);

        if (!string.IsNullOrEmpty(type) && Enum.TryParse<ActivityType>(type, true, out var parsedType))
        {
            query = query.Where(a => a.Type == parsedType);
        }

        var activities = await query.ToListAsync();
        var activityIds = activities.Select(a => a.Id).ToList();

        var reviewSessions = await _db.ReviewSessions
            .Where(rs => activityIds.Contains(rs.ActivityId))
            .ToListAsync();

        return activities.Select(a =>
        {
            var rs = reviewSessions.FirstOrDefault(r => r.ActivityId == a.Id);
            return new ActivityDto
            {
                Id = a.Id,
                Title = a.Title,
                Description = a.Description,
                Type = a.Type.ToString(),
                Deadline = a.Deadline,
                LearningPathId = a.LearningPathId,
                ReviewSessionId = rs?.Id,
                ReviewSessionTitle = rs?.Title,
                IsReviewSessionOpen = rs != null ? (DateTime.UtcNow >= rs.StartDate && DateTime.UtcNow <= rs.EndDate) : null
            };
        });
    }

    public async Task<ActivityDto> CreateActivityAsync(CreateActivityDto dto, int instructorId)
    {
        // Verify learning path belongs to class of course owned by instructor
        var learningPath = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Include(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(lp => lp.Id == dto.LearningPathId && lp.Class.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu tuần học này.");

        var activity = new Activity
        {
            Title = dto.Title,
            Description = dto.Description,
            Type = dto.Type,
            Deadline = dto.Deadline,
            LearningPathId = dto.LearningPathId
        };

        await _unitOfWork.Repository<Activity>().AddAsync(activity);
        await _unitOfWork.SaveChangesAsync();

        return new ActivityDto
        {
            Id = activity.Id,
            Title = activity.Title,
            Description = activity.Description,
            Type = activity.Type.ToString(),
            Deadline = activity.Deadline,
            LearningPathId = activity.LearningPathId
        };
    }

    public async Task<ActivityDto?> UpdateActivityAsync(int id, UpdateActivityDto dto, int instructorId)
    {
        // Verify activity belongs to course owned by instructor
        var activity = await _unitOfWork.Repository<Activity>().GetQueryable()
            .Include(a => a.LearningPath)
            .ThenInclude(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(a => a.Id == id && a.LearningPath.Class.Course.InstructorId == instructorId);

        if (activity == null) return null;

        activity.Title = dto.Title;
        activity.Description = dto.Description;
        activity.Type = dto.Type;
        activity.Deadline = dto.Deadline;

        _unitOfWork.Repository<Activity>().Update(activity);
        await _unitOfWork.SaveChangesAsync();

        return new ActivityDto
        {
            Id = activity.Id,
            Title = activity.Title,
            Description = activity.Description,
            Type = activity.Type.ToString(),
            Deadline = activity.Deadline,
            LearningPathId = activity.LearningPathId
        };
    }

    public async Task<bool> DeleteActivityAsync(int id, int instructorId)
    {
        // Verify activity belongs to course owned by instructor
        var activity = await _unitOfWork.Repository<Activity>().GetQueryable()
            .Include(a => a.LearningPath)
            .ThenInclude(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(a => a.Id == id && a.LearningPath.Class.Course.InstructorId == instructorId);

        if (activity == null) return false;

        _unitOfWork.Repository<Activity>().Delete(activity);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }

    public async Task<IEnumerable<ActivityDto>> GetByClassAsync(int classId)
    {
        var activities = await _db.Activities
            .Include(a => a.LearningPath)
            .Where(a => a.LearningPath.ClassId == classId)
            .OrderBy(a => a.LearningPath.WeekNumber)
            .ThenBy(a => a.Id)
            .ToListAsync();

        var activityIds = activities.Select(a => a.Id).ToList();

        var reviewSessions = await _db.ReviewSessions
            .Where(rs => activityIds.Contains(rs.ActivityId))
            .ToListAsync();

        return activities.Select(a =>
        {
            var rs = reviewSessions.FirstOrDefault(r => r.ActivityId == a.Id);
            return new ActivityDto
            {
                Id = a.Id,
                Title = a.Title,
                Description = a.Description,
                Type = a.Type.ToString(),
                Deadline = a.Deadline,
                LearningPathId = a.LearningPathId,
                ReviewSessionId = rs?.Id,
                ReviewSessionTitle = rs?.Title,
                IsReviewSessionOpen = rs != null ? (DateTime.UtcNow >= rs.StartDate && DateTime.UtcNow <= rs.EndDate) : null
            };
        }).ToList();
    }
}
