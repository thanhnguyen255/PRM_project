namespace backend.BLL.DTOs.Class;

public class ClassDto
{
    public int Id { get; set; }
    public int CourseId { get; set; }
    public string CourseTitle { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public int MemberCount { get; set; }
    public int WeekCount { get; set; }
    public double ProgressPercent { get; set; }
    public string? InstructorName { get; set; }
}

public class ClassMemberDto
{
    public int UserId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public DateTime JoinedAt { get; set; }
}
