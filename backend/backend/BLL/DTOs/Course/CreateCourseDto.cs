namespace backend.BLL.DTOs.Course;

public class CreateCourseDto
{
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? CoverImageUrl { get; set; }
}
