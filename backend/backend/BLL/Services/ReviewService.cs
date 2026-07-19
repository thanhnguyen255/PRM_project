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
            .Include(s => s.Activity)
            .Include(s => s.Assignments)
                .ThenInclude(a => a.Feedbacks)
            .Where(s => s.ClassId == classId)
            .ToListAsync();

        return sessions.Select(s => new ReviewSessionDto
        {
            Id = s.Id,
            ClassId = s.ClassId,
            ActivityId = s.ActivityId,
            ActivityTitle = s.Activity?.Title ?? string.Empty,
            Title = s.Title,
            StartDate = s.StartDate,
            EndDate = s.EndDate,
            IsOpen = now >= s.StartDate && now <= s.EndDate,
            MyAssignmentCount = 0,
            MyCompletedCount = 0,
            TotalPairs = s.Assignments.Count,
            CompletedPairs = s.Assignments.Count(a => a.Feedbacks.Any())
        });
    }

    public async Task<ReviewSessionDto?> GetSessionByIdAsync(int id)
    {
        var now = DateTime.UtcNow;
        var session = await _unitOfWork.Repository<ReviewSession>().GetQueryable()
            .Include(s => s.Activity)
            .Include(s => s.Assignments)
                .ThenInclude(a => a.Feedbacks)
            .Include(s => s.Assignments)
                .ThenInclude(a => a.Reviewer)
            .Include(s => s.Assignments)
                .ThenInclude(a => a.Reviewee)
            .FirstOrDefaultAsync(s => s.Id == id);
        if (session == null) return null;

        return new ReviewSessionDto
        {
            Id = session.Id,
            ClassId = session.ClassId,
            ActivityId = session.ActivityId,
            ActivityTitle = session.Activity?.Title ?? string.Empty,
            Title = session.Title,
            StartDate = session.StartDate,
            EndDate = session.EndDate,
            IsOpen = now >= session.StartDate && now <= session.EndDate,
            TotalPairs = session.Assignments.Count,
            CompletedPairs = session.Assignments.Count(a => a.Feedbacks.Any()),
            Pairs = session.Assignments.Select(a => new ReviewMonitorDto
            {
                AssignmentId = a.Id,
                ReviewerName = a.Reviewer?.FullName ?? string.Empty,
                RevieweeName = a.Reviewee?.FullName ?? string.Empty,
                IsCompleted = a.Feedbacks.Any(),
                Rating = a.Feedbacks.FirstOrDefault()?.Rating
            }).ToList()
        };
    }

    public async Task<ReviewSessionDto> CreateSessionAsync(CreateReviewSessionDto dto)
    {
        var session = new ReviewSession
        {
            ClassId = dto.ClassId,
            ActivityId = dto.ActivityId,
            Title = dto.Title,
            StartDate = dto.StartDate ?? DateTime.UtcNow,
            EndDate = dto.EndDate ?? DateTime.UtcNow.AddDays(14)
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
            ActivityId = session.ActivityId,
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
        var session = await _unitOfWork.Repository<ReviewSession>().GetQueryable()
            .Include(s => s.Activity)
                .ThenInclude(a => a.LearningPath)
                    .ThenInclude(lp => lp.Class)
                        .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(s => s.Id == sessionId);

        if (session == null) return [];

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

        var submissions = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .Where(s => s.ActivityId == session.ActivityId)
            .ToListAsync();

        return assignments.Select(ra => new ReviewAssignmentDto
        {
            Id = ra.Id,
            SessionId = ra.SessionId,
            ReviewerId = ra.ReviewerId,
            ReviewerName = ra.Reviewer?.FullName ?? "Unknown Reviewer",
            RevieweeId = ra.RevieweeId,
            RevieweeName = ra.Reviewee?.FullName ?? "Unknown Reviewee",
            IsCompleted = ra.Feedbacks != null && ra.Feedbacks.Any(),

            ClassName = session.Activity?.LearningPath?.Class?.Name ?? string.Empty,
            CourseName = session.Activity?.LearningPath?.Class?.Course?.Title ?? string.Empty,
            ActivityTitle = session.Activity?.Title ?? string.Empty,
            ActivityDescription = session.Activity?.Description,

            SubmissionFileUrl = submissions.FirstOrDefault(s => s.UserId == ra.RevieweeId)?.FileUrl,
            SubmissionNote = submissions.FirstOrDefault(s => s.UserId == ra.RevieweeId)?.Note,
            SubmissionDate = submissions.FirstOrDefault(s => s.UserId == ra.RevieweeId)?.SubmittedAt,

            FeedbackContent = ra.Feedbacks?.FirstOrDefault()?.Content,
            FeedbackRating = ra.Feedbacks?.FirstOrDefault()?.Rating
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

        var existingFeedback = await _unitOfWork.Repository<Feedback>().GetQueryable()
            .FirstOrDefaultAsync(f => f.AssignmentId == dto.AssignmentId);
        if (existingFeedback != null)
        {
            existingFeedback.Content = dto.Content;
            existingFeedback.Rating = dto.Rating;
            existingFeedback.CreatedAt = DateTime.UtcNow;

            _unitOfWork.Repository<Feedback>().Update(existingFeedback);
            await _unitOfWork.SaveChangesAsync();

            return new FeedbackDto
            {
                Id = existingFeedback.Id,
                AssignmentId = existingFeedback.AssignmentId,
                Content = existingFeedback.Content,
                Rating = existingFeedback.Rating,
                CreatedAt = existingFeedback.CreatedAt
            };
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
