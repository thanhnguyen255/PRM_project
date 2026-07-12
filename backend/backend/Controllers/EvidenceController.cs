using backend.BLL.DTOs.Evidence;
using backend.BLL.Interfaces;
using backend.DAL.Enums;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace backend.Controllers;

[ApiController]
[Route("api/evidences")]
[Authorize]
public class EvidenceController : BaseController
{
    private readonly IEvidenceService _evidenceService;
    private readonly IUnitOfWork _unitOfWork;

    public EvidenceController(IEvidenceService evidenceService, IUnitOfWork unitOfWork)
    {
        _evidenceService = evidenceService;
        _unitOfWork = unitOfWork;
    }

    [HttpPost]
    public async Task<IActionResult> SubmitEvidence([FromForm] CreateEvidenceDto dto)
    {
        if (string.IsNullOrEmpty(dto.Note) && (dto.File == null || dto.File.Length == 0))
        {
            return BadRequest(ApiResponse.Fail("Vui lòng nhập ghi chú hoặc đính kèm file."));
        }

        var result = await _evidenceService.SubmitEvidenceAsync(dto, GetCurrentUserId());
        if (result == null) return BadRequest(ApiResponse.Fail("Không tìm thấy hoạt động hoặc người dùng."));

        return Created("", ApiResponse.Success(result, "Nộp bằng chứng thành công."));
    }

    [HttpGet]
    public async Task<IActionResult> GetEvidences([FromQuery] int? classId, [FromQuery] string? status)
    {
        int instructorId = GetCurrentUserId();

        var query = _unitOfWork.Repository<ActivitySubmission>().GetQueryable()
            .Include(s => s.User)
            .Include(s => s.Activity)
            .ThenInclude(a => a.LearningPath)
            .ThenInclude(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .Where(s => s.Activity.LearningPath.Class.Course.InstructorId == instructorId);

        if (classId.HasValue && classId.Value > 0)
        {
            query = query.Where(s => s.Activity.LearningPath.ClassId == classId.Value);
        }

        if (!string.IsNullOrEmpty(status))
        {
            if (Enum.TryParse<EvidenceStatus>(status, true, out var evStatus))
            {
                query = query.Where(s => s.Status == evStatus);
            }
        }

        var submissions = await query.ToListAsync();

        var result = submissions.Select(s => new EvidenceDto
        {
            Id = s.Id,
            ActivityId = s.ActivityId,
            ActivityTitle = s.Activity.Title,
            UserId = s.UserId,
            UserFullName = s.User.FullName,
            FileUrl = s.FileUrl,
            Note = s.Note,
            Status = s.Status,
            SubmittedAt = s.SubmittedAt
        });

        return Ok(ApiResponse.Success(result));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetEvidence(int id)
    {
        int instructorId = GetCurrentUserId();
        var evidence = await _evidenceService.GetEvidenceByIdAsync(id, instructorId);
        if (evidence == null) return NotFound(ApiResponse.Fail("Không tìm thấy bài nộp hoặc bạn không có quyền xem."));
        return Ok(ApiResponse.Success(evidence));
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateStatus(int id, UpdateEvidenceStatusDto dto)
    {
        int instructorId = GetCurrentUserId();
        var evidence = await _evidenceService.UpdateEvidenceStatusAsync(id, dto, instructorId);
        if (evidence == null) return NotFound(ApiResponse.Fail("Không tìm thấy bài nộp hoặc bạn không có quyền phê duyệt."));
        return Ok(ApiResponse.Success(evidence));
    }

    [HttpPut("{id}/approve")]
    public async Task<IActionResult> Approve(int id)
    {
        int instructorId = GetCurrentUserId();
        var dto = new UpdateEvidenceStatusDto { Status = EvidenceStatus.Approved };
        var evidence = await _evidenceService.UpdateEvidenceStatusAsync(id, dto, instructorId);
        if (evidence == null) return NotFound(ApiResponse.Fail("Không tìm thấy bài nộp hoặc bạn không có quyền phê duyệt."));
        return Ok(ApiResponse.Success(evidence));
    }

    [HttpPut("{id}/reject")]
    public async Task<IActionResult> Reject(int id)
    {
        int instructorId = GetCurrentUserId();
        var dto = new UpdateEvidenceStatusDto { Status = EvidenceStatus.Rejected };
        var evidence = await _evidenceService.UpdateEvidenceStatusAsync(id, dto, instructorId);
        if (evidence == null) return NotFound(ApiResponse.Fail("Không tìm thấy bài nộp hoặc bạn không có quyền từ chối."));
        return Ok(ApiResponse.Success(evidence));
    }

    [HttpGet("{id}/comments")]
    public async Task<IActionResult> GetComments(int id)
    {
        var userId = GetCurrentUserId();
        var comments = await _evidenceService.GetCommentsByEvidenceIdAsync(id, userId);
        return Ok(ApiResponse.Success(comments));
    }

    [HttpPost("{id}/comments")]
    public async Task<IActionResult> AddComment(int id, CreateEvidenceCommentDto dto)
    {
        int userId = GetCurrentUserId();
        var comment = await _evidenceService.AddCommentToEvidenceAsync(id, dto, userId);
        if (comment == null) return BadRequest(ApiResponse.Fail("Không thể gửi bình luận (bài nộp không tồn tại hoặc người dùng không tồn tại)."));
        return Ok(ApiResponse.Success(comment));
    }
}
