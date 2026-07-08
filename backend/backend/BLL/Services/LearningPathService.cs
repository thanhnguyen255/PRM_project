using backend.BLL.DTOs.LearningPath;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class LearningPathService : ILearningPathService
{
    private readonly AppDbContext _db;

    public LearningPathService(AppDbContext db)
    {
        _db = db;
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
        bool previousCompleted = true; // tuần đầu không locked

        foreach (var path in paths)
        {
            var total = path.Activities.Count;
            var completed = path.Activities.Count(a => approvedActivityIds.Contains(a.Id));

            string state;
            if (!previousCompleted)
                state = "locked";
            else if (total > 0 && completed == total)
                state = "completed";
            else if (completed > 0)
                state = "inProgress";
            else
                state = "notStarted";

            previousCompleted = state == "completed";

            result.Add(new LearningPathDto
            {
                Id = path.Id,
                Title = path.Title,
                WeekNumber = path.WeekNumber,
                TotalActivities = total,
                CompletedActivities = completed,
                State = state
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
        var submissions = await _db.ActivitySubmissions
            .Where(s => s.UserId == userId && activityIds.Contains(s.ActivityId))
            .ToDictionaryAsync(s => s.ActivityId);

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
}
