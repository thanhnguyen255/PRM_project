using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/learning-paths")]
[Authorize]
public class LearningPathsController : BaseController
{
    private readonly ILearningPathService _service;

    public LearningPathsController(ILearningPathService service)
    {
        _service = service;
    }

    /// <summary>GET /api/learning-paths?classId={classId} — Danh sách tuần học</summary>
    [HttpGet]
    public async Task<IActionResult> GetByClass([FromQuery] int classId)
    {
        if (classId <= 0) return BadRequest(ApiResponse.Fail("classId không hợp lệ."));

        var result = await _service.GetByClassAsync(classId, GetCurrentUserId());
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>GET /api/learning-paths/{id} — Chi tiết tuần học</summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _service.GetByIdAsync(id, GetCurrentUserId());
        return Ok(ApiResponse.Success(result));
    }
}
