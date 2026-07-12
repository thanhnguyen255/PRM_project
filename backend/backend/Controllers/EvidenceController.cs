using backend.BLL.DTOs.Evidence;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/evidences")]
public class EvidenceController : BaseController
{
    private readonly IEvidenceService _evidenceService;

    public EvidenceController(IEvidenceService evidenceService)
    {
        _evidenceService = evidenceService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<EvidenceDto>>> GetEvidences([FromQuery] int? classId)
    {
        if (GetCurrentUserRole() != "Instructor") return StatusCode(403, ApiResponse.Fail("Chỉ giảng viên mới có thể xem danh sách bài nộp."));
        var evidences = await _evidenceService.GetEvidencesAsync(classId, GetCurrentUserId());
        return Ok(evidences);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<EvidenceDto>> GetEvidence(int id)
    {
        if (GetCurrentUserRole() != "Instructor") return StatusCode(403, ApiResponse.Fail("Chỉ giảng viên mới có quyền xem chi tiết bài nộp này."));
        var evidence = await _evidenceService.GetEvidenceByIdAsync(id, GetCurrentUserId());
        if (evidence == null) return NotFound("Không tìm thấy bài nộp hoặc bạn không có quyền xem.");
        return Ok(evidence);
    }

    [HttpPost]
    public async Task<ActionResult<EvidenceDto>> SubmitEvidence([FromForm] CreateEvidenceDto dto)
    {
        if (GetCurrentUserRole() != "Learner") return StatusCode(403, ApiResponse.Fail("Chỉ học viên mới có thể nộp bài."));
        var evidence = await _evidenceService.SubmitEvidenceAsync(dto, GetCurrentUserId());
        if (evidence == null) return BadRequest(ApiResponse.Fail("Không thể nộp bài (có thể đã quá hạn hoặc dữ liệu không hợp lệ)."));
        return Ok(ApiResponse.Success(evidence));
    }

    [HttpPut("{id}/status")]
    public async Task<ActionResult<EvidenceDto>> UpdateStatus(int id, UpdateEvidenceStatusDto dto)
    {
        if (GetCurrentUserRole() != "Instructor") return StatusCode(403, ApiResponse.Fail("Chỉ giảng viên mới có quyền phê duyệt."));
        var evidence = await _evidenceService.UpdateEvidenceStatusAsync(id, dto, GetCurrentUserId());
        if (evidence == null) return NotFound("Không tìm thấy bài nộp hoặc bạn không có quyền phê duyệt.");
        return Ok(evidence);
    }

    [HttpPut("{id}/approve")]
    public async Task<ActionResult<EvidenceDto>> Approve(int id)
    {
        if (GetCurrentUserRole() != "Instructor") return StatusCode(403, ApiResponse.Fail("Chỉ giảng viên mới có quyền phê duyệt."));
        var dto = new UpdateEvidenceStatusDto { Status = backend.DAL.Enums.EvidenceStatus.Approved };
        var evidence = await _evidenceService.UpdateEvidenceStatusAsync(id, dto, GetCurrentUserId());
        if (evidence == null) return NotFound("Không tìm thấy bài nộp hoặc bạn không có quyền phê duyệt.");
        return Ok(evidence);
    }

    [HttpPut("{id}/reject")]
    public async Task<ActionResult<EvidenceDto>> Reject(int id)
    {
        if (GetCurrentUserRole() != "Instructor") return StatusCode(403, ApiResponse.Fail("Chỉ giảng viên mới có quyền từ chối."));
        var dto = new UpdateEvidenceStatusDto { Status = backend.DAL.Enums.EvidenceStatus.Rejected };
        var evidence = await _evidenceService.UpdateEvidenceStatusAsync(id, dto, GetCurrentUserId());
        if (evidence == null) return NotFound("Không tìm thấy bài nộp hoặc bạn không có quyền từ chối.");
        return Ok(evidence);
    }

    [HttpGet("{id}/comments")]
    public async Task<ActionResult<IEnumerable<EvidenceCommentDto>>> GetComments(int id)
    {
        // Both instructors and learners might need this, but for now we only support instructor fetching
        var comments = await _evidenceService.GetCommentsByEvidenceIdAsync(id, GetCurrentUserId());
        return Ok(comments);
    }

    [HttpPost("{id}/comments")]
    public async Task<ActionResult<EvidenceCommentDto>> AddComment(int id, CreateEvidenceCommentDto dto)
    {
        var comment = await _evidenceService.AddCommentToEvidenceAsync(id, dto, GetCurrentUserId());
        if (comment == null) return BadRequest("Không thể gửi bình luận (bài nộp không tồn tại hoặc người dùng không tồn tại).");
        return Ok(comment);
    }
}
