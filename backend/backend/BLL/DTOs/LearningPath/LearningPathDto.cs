namespace backend.BLL.DTOs.LearningPath;

public class LearningPathDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public int ClassId { get; set; }
    public int WeekNumber { get; set; }
}

public class CreateLearningPathDto
{
    public string Title { get; set; } = string.Empty;
    public int ClassId { get; set; }
    public int WeekNumber { get; set; }
}
