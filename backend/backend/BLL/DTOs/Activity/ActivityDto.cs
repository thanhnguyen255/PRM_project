namespace backend.BLL.DTOs.Activity;

public class ActivityDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty; // PreClass | InClass | PostClass
    public string? Description { get; set; }
    public DateTime? Deadline { get; set; }
    public int? SubmissionId { get; set; }
    public string? SubmissionStatus { get; set; } // Pending | Approved | Rejected | null
    public DateTime? SubmittedAt { get; set; }
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
