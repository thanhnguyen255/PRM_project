namespace backend.BLL.DTOs.Course;

public class CourseDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? CoverImageUrl { get; set; }
    public int InstructorId { get; set; }
    public string InstructorName { get; set; } = string.Empty;
}
