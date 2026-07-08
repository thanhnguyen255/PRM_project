using backend.BLL.DTOs.LearningPath;

namespace backend.BLL.Interfaces;

public interface ILearningPathService
{
    Task<List<LearningPathDto>> GetByClassAsync(int classId, int userId);
    Task<LearningPathDetailDto> GetByIdAsync(int pathId, int userId);
}
