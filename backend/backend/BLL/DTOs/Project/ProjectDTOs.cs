namespace backend.BLL.DTOs.Project;

public class ProjectDto
{
    public int Id { get; set; }
    public int ClassId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int MilestoneCount { get; set; }
    public int CompletedMilestones { get; set; }
    public string? NextMilestoneTitle { get; set; }
    public DateTime? NextMilestoneDueDate { get; set; }
    public List<MilestoneDto> Milestones { get; set; } = [];
}

public class CreateProjectDto
{
    public int ClassId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
}
