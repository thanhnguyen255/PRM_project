using backend.BLL.DTOs.Review;

namespace backend.BLL.Interfaces;

public interface IReviewService
{
    Task<IEnumerable<ReviewSessionDto>> GetSessionsByClassAsync(int classId);
    Task<ReviewSessionDto?> GetSessionByIdAsync(int id);
    Task<ReviewSessionDto> CreateSessionAsync(CreateReviewSessionDto dto);
    Task<bool> DeleteSessionAsync(int id);
    Task<IEnumerable<ReviewAssignmentDto>> GetAssignmentsAsync(int sessionId, int? reviewerId);
    Task<IEnumerable<FeedbackDto>> GetReceivedFeedbackAsync(int sessionId, int userId);
    Task<IEnumerable<FeedbackDto>> GetAllFeedbacksInSessionAsync(int sessionId);
    Task<FeedbackDto> SubmitFeedbackAsync(CreateFeedbackDto dto, int reviewerId);
    Task<IEnumerable<ReviewMonitorDto>> GetReviewMonitorAsync(int sessionId);
}
