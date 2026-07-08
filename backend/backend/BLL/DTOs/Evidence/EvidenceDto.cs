using backend.DAL.Enums;

namespace backend.BLL.DTOs.Evidence;

public class EvidenceDto
{
    public int Id { get; set; }
    public int ActivityId { get; set; }
    public string ActivityTitle { get; set; } = string.Empty;
    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public string? FileUrl { get; set; }
    public string? Note { get; set; }
    public EvidenceStatus Status { get; set; }
    public DateTime SubmittedAt { get; set; }
}

public class UpdateEvidenceStatusDto
{
    public EvidenceStatus Status { get; set; }
}

public class EvidenceCommentDto
{
    public int Id { get; set; }
    public int SubmissionId { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public UserRole UserRole { get; set; }
    public string Content { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class CreateEvidenceCommentDto
{
    public string Content { get; set; } = string.Empty;
}
