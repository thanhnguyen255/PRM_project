using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using backend.DAL.Enums;

namespace backend.DAL.Models;

[Table("Users")]
public class User
{
    [Key]
    public int Id { get; set; }

    [Required]
    [MaxLength(255)]
    public string Email { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string PasswordHash { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string FullName { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? AvatarUrl { get; set; }

    [Required]
    public UserRole Role { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public ICollection<Course> Courses { get; set; } = [];
    public ICollection<ClassMember> ClassMembers { get; set; } = [];
    public ICollection<ActivitySubmission> Submissions { get; set; } = [];
    public ICollection<EvidenceComment> Comments { get; set; } = [];
    public ICollection<MilestoneSubmission> MilestoneSubmissions { get; set; } = [];
    public ICollection<Notification> Notifications { get; set; } = [];
}
