using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using backend.DAL.Enums;

namespace backend.DAL.Models;

[Table("ActivitySubmissions")]
public class ActivitySubmission
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int ActivityId { get; set; }

    [Required]
    public int UserId { get; set; }

    [MaxLength(500)]
    public string? FileUrl { get; set; }

    [MaxLength(2000)]
    public string? Note { get; set; }

    [Required]
    public EvidenceStatus Status { get; set; } = EvidenceStatus.Pending;

    public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;

    public DateTime? ReviewedAt { get; set; }

    // Navigation
    [ForeignKey(nameof(ActivityId))]
    public Activity Activity { get; set; } = null!;

    [ForeignKey(nameof(UserId))]
    public User User { get; set; } = null!;

    public ICollection<EvidenceComment> Comments { get; set; } = [];
}
