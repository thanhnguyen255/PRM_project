using backend.BLL.DTOs.Evidence;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/evidences")]
public class EvidenceController : ControllerBase
{
    private readonly IEvidenceService _evidenceService;

    public EvidenceController(IEvidenceService evidenceService)
    {
        _evidenceService = evidenceService;
    }

    private int CurrentInstructorId
    {
        get
        {
            if (Request.Headers.TryGetValue("X-Instructor-Id", out var value) && int.TryParse(value, out var id))
            {
                return id;
            }
            return 1; // Default to instructor 1 for easy testing
        }
    }

    private int CurrentUserId
    {
        get
        {
            if (Request.Headers.TryGetValue("X-User-Id", out var value) && int.TryParse(value, out var id))
            {
                return id;
            }
            return CurrentInstructorId; // Fallback to instructor
        }
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<EvidenceDto>>> GetEvidences([FromQuery] int? classId)
    {
        var evidences = await _evidenceService.GetEvidencesAsync(classId, CurrentInstructorId);
        return Ok(evidences);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<EvidenceDto>> GetEvidence(int id)
    {
        var evidence = await _evidenceService.GetEvidenceByIdAsync(id, CurrentInstructorId);
        if (evidence == null) return NotFound("Không tìm thấy bài nộp hoặc bạn không có quyền xem.");
        return Ok(evidence);
    }

    [HttpPut("{id}/status")]
    public async Task<ActionResult<EvidenceDto>> UpdateStatus(int id, UpdateEvidenceStatusDto dto)
    {
        var evidence = await _evidenceService.UpdateEvidenceStatusAsync(id, dto, CurrentInstructorId);
        if (evidence == null) return NotFound("Không tìm thấy bài nộp hoặc bạn không có quyền phê duyệt.");
        return Ok(evidence);
    }

    [HttpPut("{id}/approve")]
    public async Task<ActionResult<EvidenceDto>> Approve(int id)
    {
        var dto = new UpdateEvidenceStatusDto { Status = backend.DAL.Enums.EvidenceStatus.Approved };
        var evidence = await _evidenceService.UpdateEvidenceStatusAsync(id, dto, CurrentInstructorId);
        if (evidence == null) return NotFound("Không tìm thấy bài nộp hoặc bạn không có quyền phê duyệt.");
        return Ok(evidence);
    }

    [HttpPut("{id}/reject")]
    public async Task<ActionResult<EvidenceDto>> Reject(int id)
    {
        var dto = new UpdateEvidenceStatusDto { Status = backend.DAL.Enums.EvidenceStatus.Rejected };
        var evidence = await _evidenceService.UpdateEvidenceStatusAsync(id, dto, CurrentInstructorId);
        if (evidence == null) return NotFound("Không tìm thấy bài nộp hoặc bạn không có quyền từ chối.");
        return Ok(evidence);
    }

    [HttpGet("{id}/comments")]
    public async Task<ActionResult<IEnumerable<EvidenceCommentDto>>> GetComments(int id)
    {
        var comments = await _evidenceService.GetCommentsByEvidenceIdAsync(id, CurrentInstructorId);
        return Ok(comments);
    }

    [HttpPost("{id}/comments")]
    public async Task<ActionResult<EvidenceCommentDto>> AddComment(int id, CreateEvidenceCommentDto dto)
    {
        var comment = await _evidenceService.AddCommentToEvidenceAsync(id, dto, CurrentUserId);
        if (comment == null) return BadRequest("Không thể gửi bình luận (bài nộp không tồn tại hoặc người dùng không tồn tại).");
        return Ok(comment);
    }
}
