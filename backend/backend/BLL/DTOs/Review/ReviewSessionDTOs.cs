namespace backend.BLL.DTOs.Review;

public class ReviewSessionDto
{
    public int Id { get; set; }
    public int ClassId { get; set; }
    public string Title { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public int TotalPairs { get; set; }
    public int CompletedPairs { get; set; }
    public List<ReviewMonitorDto> Pairs { get; set; } = [];
}

public class CreateReviewSessionDto
{
    public int ClassId { get; set; }
    public string Title { get; set; } = string.Empty;
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public bool AutoAssign { get; set; }
}

public class ReviewMonitorDto
{
    public int AssignmentId { get; set; }
    public int ReviewerId { get; set; }
    public string ReviewerName { get; set; } = string.Empty;
    public int RevieweeId { get; set; }
    public string RevieweeName { get; set; } = string.Empty;
    public bool IsCompleted { get; set; }
    public string? Content { get; set; }
    public int? Rating { get; set; }
    public DateTime? SubmittedAt { get; set; }
}
