using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("Courses")]
public class Course
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(2000)]
    public string? Description { get; set; }

    [MaxLength(500)]
    public string? CoverImageUrl { get; set; }

    [Required]
    public int InstructorId { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    [ForeignKey(nameof(InstructorId))]
    public User Instructor { get; set; } = null!;

    public ICollection<Class> Classes { get; set; } = [];
}
