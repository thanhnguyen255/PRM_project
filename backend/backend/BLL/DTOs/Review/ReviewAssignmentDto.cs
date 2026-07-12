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
}
