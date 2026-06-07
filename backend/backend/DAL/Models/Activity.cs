using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using backend.DAL.Enums;

namespace backend.DAL.Models;

[Table("Activities")]
public class Activity
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int LearningPathId { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(3000)]
    public string? Description { get; set; }

    [Required]
    public ActivityType Type { get; set; }

    public DateTime? Deadline { get; set; }

    // Navigation
    [ForeignKey(nameof(LearningPathId))]
    public LearningPath LearningPath { get; set; } = null!;

    public ICollection<ActivitySubmission> Submissions { get; set; } = [];
}
