namespace backend.BLL.DTOs.Course;

public class MyCourseDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? CoverImageUrl { get; set; }
    public string InstructorName { get; set; } = string.Empty;
    public double ProgressPercent { get; set; }
    public int ActiveClassId { get; set; }
    public string ActiveClassName { get; set; } = string.Empty;
}
