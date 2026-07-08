using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/classes")]
[Authorize]
public class ClassesController : BaseController
{
    private readonly IClassService _classService;

    public ClassesController(IClassService classService)
    {
        _classService = classService;
    }

    /// <summary>GET /api/classes/my — Danh sách lớp học của learner</summary>
    [HttpGet("my")]
    public async Task<IActionResult> GetMyClasses()
    {
        var result = await _classService.GetMyClassesAsync(GetCurrentUserId());
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>GET /api/classes/{id} — Chi tiết lớp học</summary>
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetClass(int id)
    {
        var result = await _classService.GetClassByIdAsync(id, GetCurrentUserId());
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>GET /api/classes/{id}/members — Thành viên của lớp</summary>
    [HttpGet("{id:int}/members")]
    public async Task<IActionResult> GetMembers(int id)
    {
        var result = await _classService.GetMembersAsync(id);
        return Ok(ApiResponse.Success(result));
    }
}
