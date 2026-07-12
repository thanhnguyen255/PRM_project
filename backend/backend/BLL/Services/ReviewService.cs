using backend.BLL.DTOs.Review;
using backend.BLL.Interfaces;
using backend.DAL.Enums;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class ReviewService : IReviewService
{
    private readonly IUnitOfWork _unitOfWork;

    public ReviewService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<ReviewSessionDto>> GetSessionsByClassAsync(int classId)
    {
        var now = DateTime.UtcNow;
        var sessions = await _unitOfWork.Repository<ReviewSession>().GetQueryable()
            .Where(s => s.ClassId == classId)
            .ToListAsync();

        return sessions.Select(s => new ReviewSessionDto
        {
            Id = s.Id,
            ClassId = s.ClassId,
            Title = s.Title,
            StartDate = s.StartDate,
            EndDate = s.EndDate,
            IsOpen = now >= s.StartDate && now <= s.EndDate,
            MyAssignmentCount = 0,
            MyCompletedCount = 0
        });
    }

    public async Task<ReviewSessionDto?> GetSessionByIdAsync(int id)
    {
        var now = DateTime.UtcNow;
        var session = await _unitOfWork.Repository<ReviewSession>().GetByIdAsync(id);
        if (session == null) return null;

        return new ReviewSessionDto
        {
            Id = session.Id,
            ClassId = session.ClassId,
            Title = session.Title,
            StartDate = session.StartDate,
            EndDate = session.EndDate,
            IsOpen = now >= session.StartDate && now <= session.EndDate
        };
    }

    public async Task<ReviewSessionDto> CreateSessionAsync(CreateReviewSessionDto dto)
    {
        var session = new ReviewSession
        {
            ClassId = dto.ClassId,
            Title = dto.Title,
            StartDate = dto.StartDate,
            EndDate = dto.EndDate
        };

        await _unitOfWork.Repository<ReviewSession>().AddAsync(session);
        await _unitOfWork.SaveChangesAsync(); // Get session.Id first

        if (dto.AutoAssign)
        {
            var learners = await _unitOfWork.Repository<ClassMember>().GetQueryable()
                .Include(cm => cm.User)
                .Where(cm => cm.ClassId == dto.ClassId && cm.User.Role == UserRole.Learner)
                .Select(cm => cm.User)
                .ToListAsync();

            if (learners.Count >= 2)
            {
                for (int i = 0; i < learners.Count; i++)
                {
                    var assignment = new ReviewAssignment
                    {
                        SessionId = session.Id,
                        ReviewerId = learners[i].Id,
                        RevieweeId = learners[(i + 1) % learners.Count].Id
                    };
                    await _unitOfWork.Repository<ReviewAssignment>().AddAsync(assignment);
                }
                await _unitOfWork.SaveChangesAsync();
            }
        }

        return new ReviewSessionDto
        {
            Id = session.Id,
            ClassId = session.ClassId,
            Title = session.Title,
            StartDate = session.StartDate,
            EndDate = session.EndDate
        };
    }

    public async Task<bool> DeleteSessionAsync(int id)
    {
        var session = await _unitOfWork.Repository<ReviewSession>().GetByIdAsync(id);
        if (session == null) return false;

        _unitOfWork.Repository<ReviewSession>().Delete(session);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }

    public async Task<IEnumerable<ReviewAssignmentDto>> GetAssignmentsAsync(int sessionId, int? reviewerId)
    {
        var query = _unitOfWork.Repository<ReviewAssignment>().GetQueryable()
            .Include(ra => ra.Reviewer)
            .Include(ra => ra.Reviewee)
            .Include(ra => ra.Feedbacks)
            .Where(ra => ra.SessionId == sessionId);

        if (reviewerId.HasValue)
        {
            query = query.Where(ra => ra.ReviewerId == reviewerId.Value);
        }

        var assignments = await query.ToListAsync();

        return assignments.Select(ra => new ReviewAssignmentDto
        {
            Id = ra.Id,
            SessionId = ra.SessionId,
            ReviewerId = ra.ReviewerId,
            ReviewerName = ra.Reviewer?.FullName ?? "Unknown Reviewer",
            RevieweeId = ra.RevieweeId,
            RevieweeName = ra.Reviewee?.FullName ?? "Unknown Reviewee",
            IsCompleted = ra.Feedbacks != null && ra.Feedbacks.Any()
        });
    }

    public async Task<IEnumerable<FeedbackDto>> GetReceivedFeedbackAsync(int sessionId, int userId)
    {
        var feedbacks = await _unitOfWork.Repository<Feedback>().GetQueryable()
            .Include(f => f.Assignment)
                .ThenInclude(a => a.Reviewer)
            .Where(f => f.Assignment.SessionId == sessionId && f.Assignment.RevieweeId == userId)
            .ToListAsync();

        return feedbacks.Select(f => new FeedbackDto
        {
            Id = f.Id,
            AssignmentId = f.AssignmentId,
            ReviewerName = f.Assignment?.Reviewer?.FullName ?? "Anonymous",
            Content = f.Content,
            Rating = f.Rating,
            CreatedAt = f.CreatedAt
        });
    }

    public async Task<IEnumerable<FeedbackDto>> GetAllFeedbacksInSessionAsync(int sessionId)
    {
        var feedbacks = await _unitOfWork.Repository<Feedback>().GetQueryable()
            .Include(f => f.Assignment)
            .Where(f => f.Assignment.SessionId == sessionId)
            .ToListAsync();

        return feedbacks.Select(f => new FeedbackDto
        {
            Id = f.Id,
            AssignmentId = f.AssignmentId,
            Content = f.Content,
            Rating = f.Rating,
            CreatedAt = f.CreatedAt
        });
    }

    public async Task<FeedbackDto> SubmitFeedbackAsync(CreateFeedbackDto dto, int reviewerId)
    {
        var assignment = await _unitOfWork.Repository<ReviewAssignment>().GetByIdAsync(dto.AssignmentId)
            ?? throw new KeyNotFoundException("Không tìm thấy phân công đánh giá chéo.");

        if (assignment.ReviewerId != reviewerId)
        {
            throw new UnauthorizedAccessException("Bạn không được phân công thực hiện đánh giá này.");
        }

        // Check if feedback already submitted for this assignment
        var existingFeedback = await _unitOfWork.Repository<Feedback>().GetQueryable()
            .FirstOrDefaultAsync(f => f.AssignmentId == dto.AssignmentId);
        if (existingFeedback != null)
        {
            throw new InvalidOperationException("Bạn đã gửi đánh giá cho phân công này rồi.");
        }

        var feedback = new Feedback
        {
            AssignmentId = dto.AssignmentId,
            Content = dto.Content,
            Rating = dto.Rating,
            CreatedAt = DateTime.UtcNow
        };

        await _unitOfWork.Repository<Feedback>().AddAsync(feedback);
        await _unitOfWork.SaveChangesAsync();

        return new FeedbackDto
        {
            Id = feedback.Id,
            AssignmentId = feedback.AssignmentId,
            Content = feedback.Content,
            Rating = feedback.Rating,
            CreatedAt = feedback.CreatedAt
        };
    }

    public async Task<IEnumerable<ReviewMonitorDto>> GetReviewMonitorAsync(int sessionId)
    {
        var assignments = await _unitOfWork.Repository<ReviewAssignment>().GetQueryable()
            .Include(ra => ra.Reviewer)
            .Include(ra => ra.Reviewee)
            .Include(ra => ra.Feedbacks)
            .Where(ra => ra.SessionId == sessionId)
            .ToListAsync();

        return assignments.Select(ra => {
            var fb = ra.Feedbacks.FirstOrDefault();
            return new ReviewMonitorDto
            {
                AssignmentId = ra.Id,
                ReviewerId = ra.ReviewerId,
                ReviewerName = ra.Reviewer?.FullName ?? "Unknown Reviewer",
                RevieweeId = ra.RevieweeId,
                RevieweeName = ra.Reviewee?.FullName ?? "Unknown Reviewee",
                IsCompleted = fb != null,
                Content = fb?.Content,
                Rating = fb?.Rating,
                SubmittedAt = fb?.CreatedAt
            };
        });
    }
}
