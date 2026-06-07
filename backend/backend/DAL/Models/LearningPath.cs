using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("LearningPaths")]
public class LearningPath
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int ClassId { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    public int WeekNumber { get; set; }

    // Navigation
    [ForeignKey(nameof(ClassId))]
    public Class Class { get; set; } = null!;

    public ICollection<LearningMaterial> Materials { get; set; } = [];
    public ICollection<Activity> Activities { get; set; } = [];
}
