using backend.BLL.DTOs.LearningPath;

namespace backend.BLL.Interfaces;

public interface ILearningPathService
{
    Task<List<LearningPathDto>> GetByClassAsync(int classId, int userId);
    Task<LearningPathDetailDto> GetByIdAsync(int pathId, int userId);
    Task<IEnumerable<LearningPathDto>> GetLearningPathsByClassAsync(int classId, int instructorId);
    Task<LearningPathDto> CreateLearningPathAsync(CreateLearningPathDto dto, int instructorId);
    Task<bool> DeleteLearningPathAsync(int id, int instructorId);
}
