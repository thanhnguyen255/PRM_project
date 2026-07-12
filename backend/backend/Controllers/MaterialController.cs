using backend.BLL.DTOs.Material;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/materials")]
[Authorize]
public class MaterialController : BaseController
{
    private readonly IMaterialService _materialService;

    public MaterialController(IMaterialService materialService)
    {
        _materialService = materialService;
    }

    [HttpGet]
    public async Task<IActionResult> GetMaterials([FromQuery] int pathId)
    {
        var role = GetCurrentUserRole();
        if (role == "Learner")
        {
            var result = await _materialService.GetByPathAsync(pathId, null);
            return Ok(ApiResponse.Success(result));
        }
        else
        {
            var materials = await _materialService.GetMaterialsByPathAsync(pathId, GetCurrentUserId());
            return Ok(ApiResponse.Success(materials));
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateMaterial([FromForm] CreateMaterialDto dto)
    {
        var role = GetCurrentUserRole();
        if (role == "Learner") return Forbid("Chỉ giảng viên mới tạo được tài liệu.");
        var newMaterial = await _materialService.CreateMaterialAsync(dto, GetCurrentUserId());
        return Ok(ApiResponse.Success(newMaterial));
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteMaterial(int id)
    {
        var role = GetCurrentUserRole();
        if (role == "Learner") return Forbid("Chỉ giảng viên mới xóa được tài liệu.");
        var result = await _materialService.DeleteMaterialAsync(id, GetCurrentUserId());
        if (!result) return NotFound(ApiResponse.Fail("Không tìm thấy tài liệu học tập hoặc bạn không có quyền xóa."));
        return Ok(ApiResponse.Success(new { success = true }, "Xóa thành công."));
    }
}
