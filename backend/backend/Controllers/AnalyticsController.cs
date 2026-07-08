using backend.DAL.Enums;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/analytics")]
public class AnalyticsController : ControllerBase
{
    private readonly IUnitOfWork _unitOfWork;

    public AnalyticsController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public class ClassAnalyticsDto
    {
        public int TotalStudents { get; set; }
        public int TotalActivities { get; set; }
        public int TotalSubmissions { get; set; }
        public int ApprovedSubmissions { get; set; }
        public double SubmissionRate { get; set; }
        public int TotalMilestones { get; set; }
        public int TotalMilestoneSubmissions { get; set; }
        public int TotalPeerReviews { get; set; }
        public int CompletedPeerReviews { get; set; }
        public double AveragePeerReviewRating { get; set; }
        public List<WeeklyProgressDto> WeeklyProgress { get; set; } = [];
    }

    public class WeeklyProgressDto
    {
        public int WeekNumber { get; set; }
        public string Title { get; set; } = string.Empty;
        public int ActivitiesCount { get; set; }
        public int SubmissionsCount { get; set; }
    }

    public class StudentAnalyticsDto
    {
        public int UserId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public int TotalActivities { get; set; }
        public int SubmittedActivitiesCount { get; set; }
        public int ApprovedActivitiesCount { get; set; }
        public double SubmissionRate { get; set; }
        public double ApprovalRate { get; set; }
        public int TotalMilestones { get; set; }
        public int SubmittedMilestonesCount { get; set; }
        public int PeerReviewAssignmentsCount { get; set; }
        public int CompletedPeerReviewsCount { get; set; }
        public int ReceivedReviewsCount { get; set; }
        public double AverageReceivedRating { get; set; }
        public List<StudentFeedbackDto> ReceivedFeedbacks { get; set; } = [];
    }

    public class StudentFeedbackDto
    {
        public string ReviewerName { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public int Rating { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    [HttpGet("class/{classId}")]
    public async Task<ActionResult<ClassAnalyticsDto>> GetClassAnalytics(int classId)
    {
        var classObj = await _unitOfWork.Repository<Class>().GetByIdAsync(classId);
        if (classObj == null) return NotFound("Không tìm thấy lớp học.");

        var totalStudents = await _unitOfWork.Repository<ClassMember>().GetQueryable()
            .Include(cm => cm.User)
            .CountAsync(cm => cm.ClassId == classId && cm.User.Role == UserRole.Learner);

        var totalActivities = await _unitOfWork.Repository<Activity>().GetQueryable()
            .CountAsync(a => a.LearningPath.ClassId == classId);

        var totalSubmissions = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == classId);

        var approvedSubmissions = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.Status == EvidenceStatus.Approved);

        var totalMilestones = await _unitOfWork.Repository<Milestone>().GetQueryable()
            .CountAsync(m => m.Project.ClassId == classId);

        var totalMilestoneSubmissions = await _unitOfWork.Repository<MilestoneSubmission>().GetQueryable()
            .CountAsync(ms => ms.Milestone.Project.ClassId == classId);

        var totalPeerReviews = await _unitOfWork.Repository<ReviewAssignment>().GetQueryable()
            .CountAsync(ra => ra.Session.ClassId == classId);

        var completedPeerReviews = await _unitOfWork.Repository<Feedback>().GetQueryable()
            .CountAsync(f => f.Assignment.Session.ClassId == classId);

        var averagePeerReviewRating = 0.0;
        if (completedPeerReviews > 0)
        {
            averagePeerReviewRating = await _unitOfWork.Repository<Feedback>().GetQueryable()
                .Where(f => f.Assignment.Session.ClassId == classId)
                .AverageAsync(f => f.Rating);
        }

        var weeklyProgress = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Where(lp => lp.ClassId == classId)
            .OrderBy(lp => lp.WeekNumber)
            .Select(lp => new WeeklyProgressDto
            {
                WeekNumber = lp.WeekNumber,
                Title = lp.Title,
                ActivitiesCount = lp.Activities.Count,
                SubmissionsCount = _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
                    .Count(s => s.Activity.LearningPathId == lp.Id)
            })
            .ToListAsync();

        double submissionRate = 0.0;
        if (totalStudents > 0 && totalActivities > 0)
        {
            submissionRate = Math.Round(((double)totalSubmissions / (totalStudents * totalActivities)) * 100, 2);
        }

        return Ok(new ClassAnalyticsDto
        {
            TotalStudents = totalStudents,
            TotalActivities = totalActivities,
            TotalSubmissions = totalSubmissions,
            ApprovedSubmissions = approvedSubmissions,
            SubmissionRate = submissionRate,
            TotalMilestones = totalMilestones,
            TotalMilestoneSubmissions = totalMilestoneSubmissions,
            TotalPeerReviews = totalPeerReviews,
            CompletedPeerReviews = completedPeerReviews,
            AveragePeerReviewRating = Math.Round(averagePeerReviewRating, 2),
            WeeklyProgress = weeklyProgress
        });
    }

    [HttpGet("student/{userId}")]
    public async Task<ActionResult<StudentAnalyticsDto>> GetStudentAnalytics(int userId, [FromQuery] int classId)
    {
        var user = await _unitOfWork.Repository<User>().GetByIdAsync(userId);
        if (user == null) return NotFound("Không tìm thấy người dùng.");

        var isMember = await _unitOfWork.Repository<ClassMember>().GetQueryable()
            .AnyAsync(cm => cm.ClassId == classId && cm.UserId == userId);
        if (!isMember) return BadRequest("Học sinh không thuộc lớp học này.");

        var totalActivities = await _unitOfWork.Repository<Activity>().GetQueryable()
            .CountAsync(a => a.LearningPath.ClassId == classId);

        var submittedActivitiesCount = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.UserId == userId);

        var approvedActivitiesCount = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.UserId == userId && s.Status == EvidenceStatus.Approved);

        var totalMilestones = await _unitOfWork.Repository<Milestone>().GetQueryable()
            .CountAsync(m => m.Project.ClassId == classId);

        var submittedMilestonesCount = await _unitOfWork.Repository<MilestoneSubmission>().GetQueryable()
            .CountAsync(ms => ms.Milestone.Project.ClassId == classId && ms.UserId == userId);

        var peerReviewAssignmentsCount = await _unitOfWork.Repository<ReviewAssignment>().GetQueryable()
            .CountAsync(ra => ra.Session.ClassId == classId && ra.ReviewerId == userId);

        var completedPeerReviewsCount = await _unitOfWork.Repository<Feedback>().GetQueryable()
            .CountAsync(f => f.Assignment.Session.ClassId == classId && f.Assignment.ReviewerId == userId);

        var receivedReviewsCount = await _unitOfWork.Repository<Feedback>().GetQueryable()
            .CountAsync(f => f.Assignment.Session.ClassId == classId && f.Assignment.RevieweeId == userId);

        var averageReceivedRating = 0.0;
        if (receivedReviewsCount > 0)
        {
            averageReceivedRating = await _unitOfWork.Repository<Feedback>().GetQueryable()
                .Where(f => f.Assignment.Session.ClassId == classId && f.Assignment.RevieweeId == userId)
                .AverageAsync(f => f.Rating);
        }

        var feedbacks = await _unitOfWork.Repository<Feedback>().GetQueryable()
            .Include(f => f.Assignment)
            .Include(f => f.Assignment.Reviewer)
            .Where(f => f.Assignment.Session.ClassId == classId && f.Assignment.RevieweeId == userId)
            .Select(f => new StudentFeedbackDto
            {
                ReviewerName = f.Assignment.Reviewer.FullName,
                Content = f.Content,
                Rating = f.Rating,
                CreatedAt = f.CreatedAt
            })
            .ToListAsync();

        double submissionRate = 0.0;
        double approvalRate = 0.0;
        if (totalActivities > 0)
        {
            submissionRate = Math.Round(((double)submittedActivitiesCount / totalActivities) * 100, 2);
            approvalRate = Math.Round(((double)approvedActivitiesCount / totalActivities) * 100, 2);
        }

        return Ok(new StudentAnalyticsDto
        {
            UserId = userId,
            FullName = user.FullName,
            TotalActivities = totalActivities,
            SubmittedActivitiesCount = submittedActivitiesCount,
            ApprovedActivitiesCount = approvedActivitiesCount,
            SubmissionRate = submissionRate,
            ApprovalRate = approvalRate,
            TotalMilestones = totalMilestones,
            SubmittedMilestonesCount = submittedMilestonesCount,
            PeerReviewAssignmentsCount = peerReviewAssignmentsCount,
            CompletedPeerReviewsCount = completedPeerReviewsCount,
            ReceivedReviewsCount = receivedReviewsCount,
            AverageReceivedRating = Math.Round(averageReceivedRating, 2),
            ReceivedFeedbacks = feedbacks
        });
    }
}
