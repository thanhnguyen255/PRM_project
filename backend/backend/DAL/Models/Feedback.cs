using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("Feedbacks")]
public class Feedback
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int AssignmentId { get; set; }

    [Required]
    [MaxLength(2000)]
    public string Content { get; set; } = string.Empty;

    /// <summary>Rating from 1 to 5</summary>
    [Required]
    [Range(1, 5)]
    public int Rating { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    [ForeignKey(nameof(AssignmentId))]
    public ReviewAssignment Assignment { get; set; } = null!;
}
