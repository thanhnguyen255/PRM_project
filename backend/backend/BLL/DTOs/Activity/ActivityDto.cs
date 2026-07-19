using backend.DAL.Enums;
namespace backend.BLL.DTOs.Activity;

public class ActivityDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string Type { get; set; } = string.Empty; // Changed to string to unify
    public DateTime? Deadline { get; set; }
    public int LearningPathId { get; set; }
    public int? SubmissionId { get; set; }
    public string? SubmissionStatus { get; set; } 
    public DateTime? SubmittedAt { get; set; }
    public int? ReviewSessionId { get; set; }
    public string? ReviewSessionTitle { get; set; }
    public bool? IsReviewSessionOpen { get; set; }
}

public class ActivityDetailDto
{
    public int Id { get; set; }
    public int LearningPathId { get; set; }
    public string LearningPathTitle { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime? Deadline { get; set; }
    public SubmissionDetailDto? Submission { get; set; }
    public int? ReviewSessionId { get; set; }
    public string? ReviewSessionTitle { get; set; }
    public bool? IsReviewSessionOpen { get; set; }
}

public class SubmissionDetailDto
{
    public int Id { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? Note { get; set; }
    public string? FileUrl { get; set; }
    public DateTime SubmittedAt { get; set; }
    public DateTime? ReviewedAt { get; set; }
    public int CommentCount { get; set; }
}

public class CreateActivityDto
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public ActivityType Type { get; set; }
    public DateTime? Deadline { get; set; }
    public int LearningPathId { get; set; }
}

public class UpdateActivityDto
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public ActivityType Type { get; set; }
    public DateTime? Deadline { get; set; }
}
