using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/materials")]
[Authorize]
public class MaterialsController : BaseController
{
    private readonly IMaterialService _service;

    public MaterialsController(IMaterialService service)
    {
        _service = service;
    }

    /// <summary>GET /api/materials?pathId={pathId}&amp;type={type} — Danh sách tài liệu</summary>
    [HttpGet]
    public async Task<IActionResult> GetByPath([FromQuery] int pathId, [FromQuery] string? type)
    {
        if (pathId <= 0) return BadRequest(ApiResponse.Fail("pathId không hợp lệ."));

        var result = await _service.GetByPathAsync(pathId, type);
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>GET /api/materials/{id} — Chi tiết tài liệu</summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _service.GetByIdAsync(id);
        if (result == null) return NotFound(ApiResponse.Fail("Không tìm thấy tài liệu."));
        return Ok(ApiResponse.Success(result));
    }
}
