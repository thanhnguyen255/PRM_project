using backend.BLL.DTOs.Activity;

namespace backend.BLL.Interfaces;

public interface IActivityService
{
    Task<List<ActivityDto>> GetByPathAsync(int pathId, string? type, int userId);
    Task<ActivityDetailDto> GetByIdAsync(int activityId, int userId);
}
