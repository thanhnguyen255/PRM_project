using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("EvidenceComments")]
public class EvidenceComment
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int SubmissionId { get; set; }

    [Required]
    public int UserId { get; set; }

    [Required]
    [MaxLength(1000)]
    public string Content { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    [ForeignKey(nameof(SubmissionId))]
    public ActivitySubmission Submission { get; set; } = null!;

    [ForeignKey(nameof(UserId))]
    public User User { get; set; } = null!;
}
