using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace backend.DAL.Models;

[Table("ClassMembers")]
public class ClassMember
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int ClassId { get; set; }

    [Required]
    public int UserId { get; set; }

    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    [ForeignKey(nameof(ClassId))]
    public Class Class { get; set; } = null!;

    [ForeignKey(nameof(UserId))]
    public User User { get; set; } = null!;
}
