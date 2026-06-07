using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("Classes")]
public class Class
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int CourseId { get; set; }

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [Required]
    public DateTime StartDate { get; set; }

    [Required]
    public DateTime EndDate { get; set; }

    // Navigation
    [ForeignKey(nameof(CourseId))]
    public Course Course { get; set; } = null!;

    public ICollection<ClassMember> Members { get; set; } = [];
    public ICollection<LearningPath> LearningPaths { get; set; } = [];
    public ICollection<Project> Projects { get; set; } = [];
    public ICollection<ReviewSession> ReviewSessions { get; set; } = [];
}
