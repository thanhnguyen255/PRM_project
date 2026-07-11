using backend.BLL.DTOs.Evidence;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/evidences")]
[Authorize]
public class EvidencesController : BaseController
{
    private readonly IEvidenceService _service;

    public EvidencesController(IEvidenceService service)
    {
        _service = service;
    }

    /// <summary>POST /api/evidences — Nộp bằng chứng</summary>
    [HttpPost]
    public async Task<IActionResult> SubmitEvidence([FromForm] CreateEvidenceDto dto)
    {
        if (string.IsNullOrEmpty(dto.Note) && (dto.File == null || dto.File.Length == 0))
        {
            return BadRequest(ApiResponse.Fail("Vui lòng nhập ghi chú hoặc đính kèm file."));
        }

        var result = await _service.SubmitEvidenceAsync(dto, GetCurrentUserId());
        if (result == null) return BadRequest(ApiResponse.Fail("Không tìm thấy hoạt động hoặc người dùng."));

        return Created("", ApiResponse.Success(result, "Nộp bằng chứng thành công."));
    }
}
