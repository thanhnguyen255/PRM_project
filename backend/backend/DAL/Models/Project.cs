using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("Projects")]
public class Project
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int ClassId { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(3000)]
    public string? Description { get; set; }

    // Navigation
    [ForeignKey(nameof(ClassId))]
    public Class Class { get; set; } = null!;

    public ICollection<Milestone> Milestones { get; set; } = [];
}
