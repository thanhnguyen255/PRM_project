using backend.DAL.Enums;

namespace backend.BLL.DTOs.Activity;

public class ActivityDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public ActivityType Type { get; set; }
    public DateTime? Deadline { get; set; }
    public int LearningPathId { get; set; }
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
