using backend.BLL.DTOs.Activity;

namespace backend.BLL.Interfaces;

public interface IActivityService
{
    Task<List<ActivityDto>> GetByPathAsync(int pathId, string? type, int userId);
    Task<ActivityDetailDto> GetByIdAsync(int activityId, int userId);
    Task<IEnumerable<ActivityDto>> GetActivitiesByPathAsync(int pathId, string? type, int instructorId);
    Task<ActivityDto> CreateActivityAsync(CreateActivityDto dto, int instructorId);
    Task<ActivityDto?> UpdateActivityAsync(int id, UpdateActivityDto dto, int instructorId);
    Task<bool> DeleteActivityAsync(int id, int instructorId);
    Task<IEnumerable<UpcomingActivityDto>> GetUpcomingActivitiesAsync(int learnerId, int? classId, int limit = 5);
    Task<IEnumerable<ActivityDto>> GetByClassAsync(int classId);
}
