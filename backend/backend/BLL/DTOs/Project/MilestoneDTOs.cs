namespace backend.BLL.DTOs.Project;

public class MilestoneDto
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime DueDate { get; set; }
    public int StepNumber { get; set; }
    public bool IsSubmitted { get; set; }
    public DateTime? SubmittedAt { get; set; }
}

public class CreateMilestoneDto
{
    public int ProjectId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime? DueDate { get; set; }
}

public class MilestoneSubmissionDto
{
    public int Id { get; set; }
    public int MilestoneId { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public string? FileUrl { get; set; }
    public string? Description { get; set; }
    public DateTime SubmittedAt { get; set; }
}

public class CreateMilestoneSubmissionDto
{
    public int MilestoneId { get; set; }
    public Microsoft.AspNetCore.Http.IFormFile? File { get; set; }
    public string? Description { get; set; }
}
