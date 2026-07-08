namespace backend.BLL.DTOs.LearningPath;

public class LearningPathDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public int WeekNumber { get; set; }
    public int TotalActivities { get; set; }
    public int CompletedActivities { get; set; }
    public string State { get; set; } = string.Empty; // completed | inProgress | locked
    public int ClassId { get; set; }
}

public class LearningPathDetailDto
{
    public int Id { get; set; }
    public int ClassId { get; set; }
    public string Title { get; set; } = string.Empty;
    public int WeekNumber { get; set; }
    public List<MaterialDto> Materials { get; set; } = new();
    public List<ActivitySummaryDto> PreClassActivities { get; set; } = new();
    public List<ActivitySummaryDto> InClassActivities { get; set; } = new();
    public List<ActivitySummaryDto> PostClassActivities { get; set; } = new();
}

public class MaterialDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty; // Video | Document | Link
    public string? FileUrl { get; set; }
    public string? LinkUrl { get; set; }
}

public class ActivitySummaryDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public DateTime? Deadline { get; set; }
    public string? SubmissionStatus { get; set; } 
}

public class CreateLearningPathDto
{
    public string Title { get; set; } = string.Empty;
    public int ClassId { get; set; }
    public int WeekNumber { get; set; }
}
