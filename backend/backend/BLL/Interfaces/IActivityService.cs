using backend.BLL.DTOs.Activity;

namespace backend.BLL.Interfaces;

public interface IActivityService
{
    Task<IEnumerable<ActivityDto>> GetActivitiesByPathAsync(int pathId, string? type, int instructorId);
    Task<ActivityDto> CreateActivityAsync(CreateActivityDto dto, int instructorId);
    Task<ActivityDto?> UpdateActivityAsync(int id, UpdateActivityDto dto, int instructorId);
    Task<bool> DeleteActivityAsync(int id, int instructorId);
}
