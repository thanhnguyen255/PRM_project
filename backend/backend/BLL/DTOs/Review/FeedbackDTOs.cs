namespace backend.BLL.DTOs.Review;

public class FeedbackDto
{
    public int Id { get; set; }
    public int AssignmentId { get; set; }
    public string ReviewerName { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public int Rating { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateFeedbackDto
{
    public int AssignmentId { get; set; }
    public string Content { get; set; } = string.Empty;
    public int Rating { get; set; }
}
