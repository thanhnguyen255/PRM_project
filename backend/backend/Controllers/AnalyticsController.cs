using backend.DAL.Enums;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/analytics")]
[Authorize]
public class AnalyticsController : BaseController
{
    private readonly IUnitOfWork _unitOfWork;

    public AnalyticsController(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public class ClassAnalyticsDto
    {
        public int TotalStudents { get; set; }
        public int ActiveStudents { get; set; }
        public int AvgCompletion { get; set; }
        public int PendingEvidence { get; set; }
        public int ApprovedEvidence { get; set; }
        public int RejectedEvidence { get; set; }
        public List<double> Distribution { get; set; } = [];
        public double PreClassRate { get; set; }
        public double InClassRate { get; set; }
        public double PostClassRate { get; set; }
        public List<StudentCompletionDto> Students { get; set; } = [];
        public List<WeeklyProgressDto> WeeklyProgress { get; set; } = [];
    }

    public class StudentCompletionDto
    {
        public int UserId { get; set; }
        public string Name { get; set; } = string.Empty;
        public double CompletionRate { get; set; }
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

    public class MyProgressDto
    {
        public int CompletionRate { get; set; }
        public int CompletedActivities { get; set; }
        public int TotalActivities { get; set; }
        public int ApprovedEvidence { get; set; }
        public int PendingEvidence { get; set; }
        public int PreClassRate { get; set; }
        public int InClassRate { get; set; }
        public int PostClassRate { get; set; }
        public List<WeeklyProgressRateDto> WeeklyProgress { get; set; } = [];
    }

    public class WeeklyProgressRateDto
    {
        public int WeekNumber { get; set; }
        public string Title { get; set; } = string.Empty;
        public int Rate { get; set; }
    }

    [HttpGet("my-progress")]
    public async Task<IActionResult> GetMyProgress([FromQuery] int? classId)
    {
        int userId = GetCurrentUserId();

        int activeClassId = 0;
        if (classId.HasValue && classId.Value > 0)
        {
            activeClassId = classId.Value;
        }
        else
        {
            var firstClass = await _unitOfWork.Repository<ClassMember>().GetQueryable()
                .FirstOrDefaultAsync(cm => cm.UserId == userId);
            if (firstClass != null)
            {
                activeClassId = firstClass.ClassId;
            }
        }

        if (activeClassId == 0)
        {
            return Ok(ApiResponse.Success(new MyProgressDto()));
        }

        var totalActivities = await _unitOfWork.Repository<Activity>().GetQueryable()
            .CountAsync(a => a.LearningPath.ClassId == activeClassId);

        var approvedEvidence = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == activeClassId && s.UserId == userId && s.Status == EvidenceStatus.Approved);

        var pendingEvidence = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == activeClassId && s.UserId == userId && s.Status == EvidenceStatus.Pending);

        int completionRate = totalActivities > 0 ? (int)Math.Round((double)approvedEvidence / totalActivities * 100) : 0;

        var totalPre = await _unitOfWork.Repository<Activity>().GetQueryable()
            .CountAsync(a => a.LearningPath.ClassId == activeClassId && a.Type == ActivityType.PreClass);
        var approvedPre = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == activeClassId && s.UserId == userId && s.Activity.Type == ActivityType.PreClass && s.Status == EvidenceStatus.Approved);
        int preClassRate = totalPre > 0 ? (int)Math.Round((double)approvedPre / totalPre * 100) : 0;

        var totalIn = await _unitOfWork.Repository<Activity>().GetQueryable()
            .CountAsync(a => a.LearningPath.ClassId == activeClassId && a.Type == ActivityType.InClass);
        var approvedIn = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == activeClassId && s.UserId == userId && s.Activity.Type == ActivityType.InClass && s.Status == EvidenceStatus.Approved);
        int inClassRate = totalIn > 0 ? (int)Math.Round((double)approvedIn / totalIn * 100) : 0;

        var totalPost = await _unitOfWork.Repository<Activity>().GetQueryable()
            .CountAsync(a => a.LearningPath.ClassId == activeClassId && a.Type == ActivityType.PostClass);
        var approvedPost = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == activeClassId && s.UserId == userId && s.Activity.Type == ActivityType.PostClass && s.Status == EvidenceStatus.Approved);
        int postClassRate = totalPost > 0 ? (int)Math.Round((double)approvedPost / totalPost * 100) : 0;

        var weeklyPaths = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Where(lp => lp.ClassId == activeClassId)
            .OrderBy(lp => lp.WeekNumber)
            .ToListAsync();

        var weeklyProgress = new List<WeeklyProgressRateDto>();
        foreach (var lp in weeklyPaths)
        {
            var totalAct = await _unitOfWork.Repository<Activity>().GetQueryable()
                .CountAsync(a => a.LearningPathId == lp.Id);
            var appAct = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
                .CountAsync(s => s.Activity.LearningPathId == lp.Id && s.UserId == userId && s.Status == EvidenceStatus.Approved);
            int rate = totalAct > 0 ? (int)Math.Round((double)appAct / totalAct * 100) : 0;

            weeklyProgress.Add(new WeeklyProgressRateDto
            {
                WeekNumber = lp.WeekNumber,
                Title = lp.Title,
                Rate = rate
            });
        }

        var result = new MyProgressDto
        {
            CompletionRate = completionRate,
            CompletedActivities = approvedEvidence,
            TotalActivities = totalActivities,
            ApprovedEvidence = approvedEvidence,
            PendingEvidence = pendingEvidence,
            PreClassRate = preClassRate,
            InClassRate = inClassRate,
            PostClassRate = postClassRate,
            WeeklyProgress = weeklyProgress
        };

        return Ok(ApiResponse.Success(result));
    }

    [HttpGet("class/{classId}")]
    public async Task<IActionResult> GetClassAnalytics(int classId)
    {
        var classObj = await _unitOfWork.Repository<Class>().GetByIdAsync(classId);
        if (classObj == null) return NotFound(ApiResponse.Fail("Không tìm thấy lớp học."));

        var learners = await _unitOfWork.Repository<ClassMember>().GetQueryable()
            .Include(cm => cm.User)
            .Where(cm => cm.ClassId == classId && cm.User.Role == UserRole.Learner)
            .Select(cm => cm.User)
            .ToListAsync();

        int totalStudents = learners.Count;

        var totalActivities = await _unitOfWork.Repository<Activity>().GetQueryable()
            .CountAsync(a => a.LearningPath.ClassId == classId);

        var pendingEvidence = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.Status == EvidenceStatus.Pending);

        var approvedEvidence = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.Status == EvidenceStatus.Approved);

        var rejectedEvidence = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.Status == EvidenceStatus.Rejected);

        var totalPre = await _unitOfWork.Repository<Activity>().GetQueryable()
            .CountAsync(a => a.LearningPath.ClassId == classId && a.Type == ActivityType.PreClass);
        var approvedPre = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.Activity.Type == ActivityType.PreClass && s.Status == EvidenceStatus.Approved);
        double preClassRate = totalPre > 0 ? Math.Round((double)approvedPre / (totalPre * (totalStudents > 0 ? totalStudents : 1)) * 100, 2) : 0.0;

        var totalIn = await _unitOfWork.Repository<Activity>().GetQueryable()
            .CountAsync(a => a.LearningPath.ClassId == classId && a.Type == ActivityType.InClass);
        var approvedIn = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.Activity.Type == ActivityType.InClass && s.Status == EvidenceStatus.Approved);
        double inClassRate = totalIn > 0 ? Math.Round((double)approvedIn / (totalIn * (totalStudents > 0 ? totalStudents : 1)) * 100, 2) : 0.0;

        var totalPost = await _unitOfWork.Repository<Activity>().GetQueryable()
            .CountAsync(a => a.LearningPath.ClassId == classId && a.Type == ActivityType.PostClass);
        var approvedPost = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.Activity.Type == ActivityType.PostClass && s.Status == EvidenceStatus.Approved);
        double postClassRate = totalPost > 0 ? Math.Round((double)approvedPost / (totalPost * (totalStudents > 0 ? totalStudents : 1)) * 100, 2) : 0.0;

        var students = new List<StudentCompletionDto>();
        int activeStudents = 0;
        double sumCompletion = 0.0;

        int dist0to25 = 0;
        int dist25to50 = 0;
        int dist50to75 = 0;
        int dist75to100 = 0;

        foreach (var student in learners)
        {
            var studentSubmissions = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
                .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.UserId == student.Id);
            
            if (studentSubmissions > 0)
            {
                activeStudents++;
            }

            var studentApproved = await _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
                .CountAsync(s => s.Activity.LearningPath.ClassId == classId && s.UserId == student.Id && s.Status == EvidenceStatus.Approved);

            double completionRate = totalActivities > 0 ? Math.Round((double)studentApproved / totalActivities * 100, 2) : 0.0;
            sumCompletion += completionRate;

            if (completionRate < 25) dist0to25++;
            else if (completionRate < 50) dist25to50++;
            else if (completionRate < 75) dist50to75++;
            else dist75to100++;

            students.Add(new StudentCompletionDto
            {
                UserId = student.Id,
                Name = student.FullName,
                CompletionRate = completionRate
            });
        }

        int avgCompletion = totalStudents > 0 ? (int)Math.Round(sumCompletion / totalStudents) : 0;

        var distribution = new List<double> { 0.0, 0.0, 0.0, 0.0 };
        if (totalStudents > 0)
        {
            distribution[0] = Math.Round((double)dist0to25 / totalStudents * 100, 2);
            distribution[1] = Math.Round((double)dist25to50 / totalStudents * 100, 2);
            distribution[2] = Math.Round((double)dist50to75 / totalStudents * 100, 2);
            distribution[3] = Math.Round((double)dist75to100 / totalStudents * 100, 2);
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

        var result = new ClassAnalyticsDto
        {
            TotalStudents = totalStudents,
            ActiveStudents = activeStudents,
            AvgCompletion = avgCompletion,
            PendingEvidence = pendingEvidence,
            ApprovedEvidence = approvedEvidence,
            RejectedEvidence = rejectedEvidence,
            Distribution = distribution,
            PreClassRate = preClassRate,
            InClassRate = inClassRate,
            PostClassRate = postClassRate,
            Students = students,
            WeeklyProgress = weeklyProgress
        };

        return Ok(ApiResponse.Success(result));
    }

    [HttpGet("student/{userId}")]
    public async Task<IActionResult> GetStudentAnalytics(int userId, [FromQuery] int classId)
    {
        var user = await _unitOfWork.Repository<User>().GetByIdAsync(userId);
        if (user == null) return NotFound(ApiResponse.Fail("Không tìm thấy người dùng."));

        var isMember = await _unitOfWork.Repository<ClassMember>().GetQueryable()
            .AnyAsync(cm => cm.ClassId == classId && cm.UserId == userId);
        if (!isMember) return BadRequest(ApiResponse.Fail("Học sinh không thuộc lớp học này."));

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

        var result = new StudentAnalyticsDto
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
        };

        return Ok(ApiResponse.Success(result));
    }
}
