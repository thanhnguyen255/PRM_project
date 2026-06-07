using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("MilestoneSubmissions")]
public class MilestoneSubmission
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int MilestoneId { get; set; }

    [Required]
    public int UserId { get; set; }

    [MaxLength(500)]
    public string? FileUrl { get; set; }

    [MaxLength(2000)]
    public string? Description { get; set; }

    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    [ForeignKey(nameof(MilestoneId))]
    public Milestone Milestone { get; set; } = null!;

    [ForeignKey(nameof(UserId))]
    public User User { get; set; } = null!;
}
