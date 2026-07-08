using backend.BLL.DTOs.Activity;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class ActivityService : IActivityService
{
    private readonly AppDbContext _db;

    public ActivityService(AppDbContext db)
    {
        _db = db;
    }

    public async Task<List<ActivityDto>> GetByPathAsync(int pathId, string? type, int userId)
    {
        var query = _db.Activities.Where(a => a.LearningPathId == pathId);

        if (!string.IsNullOrEmpty(type) && Enum.TryParse<ActivityType>(type, true, out var actType))
            query = query.Where(a => a.Type == actType);

        var activities = await query.OrderBy(a => a.Id).ToListAsync();
        var activityIds = activities.Select(a => a.Id).ToList();

        // Lấy submissions của user cho các activities này
        var submissions = await _db.ActivitySubmissions
            .Where(s => s.UserId == userId && activityIds.Contains(s.ActivityId))
            .ToDictionaryAsync(s => s.ActivityId);

        return activities.Select(a =>
        {
            submissions.TryGetValue(a.Id, out var sub);
            return new ActivityDto
            {
                Id = a.Id,
                Title = a.Title,
                Type = a.Type.ToString(),
                Description = a.Description,
                Deadline = a.Deadline,
                SubmissionId = sub?.Id,
                SubmissionStatus = sub?.Status.ToString(),
                SubmittedAt = sub?.SubmittedAt
            };
        }).ToList();
    }

    public async Task<ActivityDetailDto> GetByIdAsync(int activityId, int userId)
    {
        var activity = await _db.Activities
            .Include(a => a.LearningPath)
            .FirstOrDefaultAsync(a => a.Id == activityId)
            ?? throw new KeyNotFoundException("Không tìm thấy hoạt động.");

        var sub = await _db.ActivitySubmissions
            .FirstOrDefaultAsync(s => s.ActivityId == activityId && s.UserId == userId);

        int commentCount = 0;
        if (sub != null)
            commentCount = await _db.EvidenceComments.CountAsync(c => c.SubmissionId == sub.Id);

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
            }
        };
    }
}
