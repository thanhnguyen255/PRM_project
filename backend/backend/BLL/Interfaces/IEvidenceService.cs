using backend.BLL.DTOs.Evidence;

namespace backend.BLL.Interfaces;

public interface IEvidenceService
{
    Task<IEnumerable<EvidenceDto>> GetEvidencesAsync(int? classId, int instructorId);
    Task<EvidenceDto?> GetEvidenceByIdAsync(int id, int userId);
    Task<EvidenceDto?> UpdateEvidenceStatusAsync(int id, UpdateEvidenceStatusDto dto, int instructorId);
    Task<IEnumerable<EvidenceCommentDto>> GetCommentsByEvidenceIdAsync(int evidenceId, int userId);
    Task<EvidenceCommentDto?> AddCommentToEvidenceAsync(int evidenceId, CreateEvidenceCommentDto dto, int userId);
    Task<EvidenceDto?> SubmitEvidenceAsync(CreateEvidenceDto dto, int learnerId);
}
