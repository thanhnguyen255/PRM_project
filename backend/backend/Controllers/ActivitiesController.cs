using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/activities")]
[Authorize]
public class ActivitiesController : BaseController
{
    private readonly IActivityService _service;

    public ActivitiesController(IActivityService service)
    {
        _service = service;
    }

    /// <summary>GET /api/activities?pathId={pathId}&amp;type={type} — Danh sách hoạt động</summary>
    [HttpGet]
    public async Task<IActionResult> GetByPath([FromQuery] int pathId, [FromQuery] string? type)
    {
        if (pathId <= 0) return BadRequest(ApiResponse.Fail("pathId không hợp lệ."));

        var result = await _service.GetByPathAsync(pathId, type, GetCurrentUserId());
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>GET /api/activities/{id} — Chi tiết hoạt động</summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _service.GetByIdAsync(id, GetCurrentUserId());
        return Ok(ApiResponse.Success(result));
    }
}
