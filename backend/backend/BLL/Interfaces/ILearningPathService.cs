using backend.BLL.DTOs.LearningPath;

namespace backend.BLL.Interfaces;

public interface ILearningPathService
{
    Task<IEnumerable<LearningPathDto>> GetLearningPathsByClassAsync(int classId, int instructorId);
    Task<LearningPathDto> CreateLearningPathAsync(CreateLearningPathDto dto, int instructorId);
    Task<bool> DeleteLearningPathAsync(int id, int instructorId);
}
