using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("ReviewSessions")]
public class ReviewSession
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int ClassId { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    public DateTime StartDate { get; set; }

    [Required]
    public DateTime EndDate { get; set; }

    // Navigation
    [ForeignKey(nameof(ClassId))]
    public Class Class { get; set; } = null!;

    public ICollection<ReviewAssignment> Assignments { get; set; } = [];
}
