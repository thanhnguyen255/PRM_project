using backend.BLL.DTOs.Activity;
using backend.BLL.Interfaces;
using backend.DAL.Enums;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class ActivityService : IActivityService
{
    private readonly IUnitOfWork _unitOfWork;

    public ActivityService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
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

        return activities.Select(a => new ActivityDto
        {
            Id = a.Id,
            Title = a.Title,
            Description = a.Description,
            Type = a.Type,
            Deadline = a.Deadline,
            LearningPathId = a.LearningPathId
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
            Type = activity.Type,
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
            Type = activity.Type,
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
}
