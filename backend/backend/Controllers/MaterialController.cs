using backend.BLL.DTOs.Material;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/materials")]
public class MaterialController : BaseController
{
    private readonly IMaterialService _materialService;

    public MaterialController(IMaterialService materialService)
    {
        _materialService = materialService;
    }

    [HttpGet]
    public async Task<IActionResult> GetMaterials([FromQuery] int pathId, [FromQuery] string? type)
    {
        try
        {
            var role = GetCurrentUserRole();
            if (role == "Learner")
            {
                var materials = await _materialService.GetByPathAsync(pathId, type);
                return Ok(ApiResponse.Success(materials));
            }
            else
            {
                var materials = await _materialService.GetMaterialsByPathAsync(pathId, GetCurrentUserId());
                return Ok(materials); // Return the raw list or ApiResponse depending on previous implementation
            }
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(403, ApiResponse.Fail(ex.Message));
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetMaterial(int id)
    {
        // Ai cũng có thể xem chi tiết tài liệu học tập (Learner/Instructor đều cần)
        var material = await _materialService.GetByIdAsync(id);
        if (material == null) return NotFound(ApiResponse.Fail("Không tìm thấy tài liệu."));
        return Ok(ApiResponse.Success(material));
    }

    [HttpPost]
    public async Task<ActionResult<MaterialDto>> CreateMaterial(CreateMaterialDto dto)
    {
        try
        {
            if (GetCurrentUserRole() != "Instructor") return StatusCode(403, ApiResponse.Fail("Chỉ giảng viên mới có thể tạo tài liệu."));
            var newMaterial = await _materialService.CreateMaterialAsync(dto, GetCurrentUserId());
            return Ok(newMaterial);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(403, ApiResponse.Fail(ex.Message));
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteMaterial(int id)
    {
        if (GetCurrentUserRole() != "Instructor") return StatusCode(403, ApiResponse.Fail("Chỉ giảng viên mới có thể xóa tài liệu."));
        var result = await _materialService.DeleteMaterialAsync(id, GetCurrentUserId());
        if (!result) return NotFound("Không tìm thấy tài liệu học tập hoặc bạn không có quyền xóa.");
        return NoContent();
    }
}
