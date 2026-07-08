namespace backend.BLL.DTOs.Activity;

public class UpcomingActivityDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public DateTime Deadline { get; set; }
    public string? SubmissionStatus { get; set; }
    public string LearningPathTitle { get; set; } = string.Empty;
}
