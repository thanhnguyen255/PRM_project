using backend.BLL.DTOs.Project;

namespace backend.BLL.Interfaces;

public interface IProjectService
{
    Task<IEnumerable<ProjectDto>> GetProjectsByClassAsync(int classId);
    Task<ProjectDto?> GetProjectByIdAsync(int id);
    Task<ProjectDto> CreateProjectAsync(CreateProjectDto dto);
    Task<bool> DeleteProjectAsync(int id);
    Task<IEnumerable<MilestoneDto>> GetMilestonesByProjectAsync(int projectId);
    Task<MilestoneDto?> GetMilestoneByIdAsync(int id);
    Task<MilestoneDto> CreateMilestoneAsync(CreateMilestoneDto dto);
    Task<bool> DeleteMilestoneAsync(int id);
    Task<MilestoneSubmissionDto> SubmitMilestoneAsync(CreateMilestoneSubmissionDto dto, int userId);
    Task<IEnumerable<MilestoneSubmissionDto>> GetSubmissionsByMilestoneAsync(int milestoneId);
}
