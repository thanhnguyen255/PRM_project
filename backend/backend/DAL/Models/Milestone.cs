using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("Milestones")]
public class Milestone
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int ProjectId { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(2000)]
    public string? Description { get; set; }

    [Required]
    public DateTime DueDate { get; set; }

    // Navigation
    [ForeignKey(nameof(ProjectId))]
    public Project Project { get; set; } = null!;

    public ICollection<MilestoneSubmission> Submissions { get; set; } = [];
}
