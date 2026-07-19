namespace backend.BLL.DTOs.Course;

public class CourseDetailDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? CoverImageUrl { get; set; }
    public string InstructorName { get; set; } = string.Empty;
    public string? InstructorAvatar { get; set; }
    public DateTime? CreatedAt { get; set; }
    
    public List<CourseClassDto> Classes { get; set; } = new();
}

public class CourseClassDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public int MemberCount { get; set; }
}
