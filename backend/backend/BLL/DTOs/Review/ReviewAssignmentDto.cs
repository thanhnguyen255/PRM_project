namespace backend.BLL.DTOs.Review;

public class ReviewAssignmentDto
{
    public int Id { get; set; }
    public int SessionId { get; set; }
    public int ReviewerId { get; set; }
    public string ReviewerName { get; set; } = string.Empty;
    public int RevieweeId { get; set; }
    public string RevieweeName { get; set; } = string.Empty;
    public bool IsCompleted { get; set; }

    public string ClassName { get; set; } = string.Empty;
    public string CourseName { get; set; } = string.Empty;
    public string ActivityTitle { get; set; } = string.Empty;
    public string? ActivityDescription { get; set; }

    public string? SubmissionFileUrl { get; set; }
    public string? SubmissionNote { get; set; }
    public DateTime? SubmissionDate { get; set; }

    public string? FeedbackContent { get; set; }
    public int? FeedbackRating { get; set; }
}
