using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using backend.DAL.Enums;

namespace backend.DAL.Models;

[Table("LearningMaterials")]
public class LearningMaterial
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int LearningPathId { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    public MaterialType Type { get; set; }

    [MaxLength(500)]
    public string? FileUrl { get; set; }

    [MaxLength(500)]
    public string? LinkUrl { get; set; }

    // Navigation
    [ForeignKey(nameof(LearningPathId))]
    public LearningPath LearningPath { get; set; } = null!;
}
