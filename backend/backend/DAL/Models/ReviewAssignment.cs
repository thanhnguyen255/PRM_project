using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("ReviewAssignments")]
public class ReviewAssignment
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int SessionId { get; set; }

    [Required]
    public int ReviewerId { get; set; }

    [Required]
    public int RevieweeId { get; set; }

    // Navigation
    [ForeignKey(nameof(SessionId))]
    public ReviewSession Session { get; set; } = null!;

    [ForeignKey(nameof(ReviewerId))]
    public User Reviewer { get; set; } = null!;

    [ForeignKey(nameof(RevieweeId))]
    public User Reviewee { get; set; } = null!;

    public ICollection<Feedback> Feedbacks { get; set; } = [];
}
