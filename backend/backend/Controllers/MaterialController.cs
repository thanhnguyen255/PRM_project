using backend.BLL.DTOs.Material;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/materials")]
public class MaterialController : ControllerBase
{
    private readonly IMaterialService _materialService;

    public MaterialController(IMaterialService materialService)
    {
        _materialService = materialService;
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

    [HttpGet]
    public async Task<ActionResult<IEnumerable<MaterialDto>>> GetMaterials([FromQuery] int pathId)
    {
        try
        {
            var materials = await _materialService.GetMaterialsByPathAsync(pathId, CurrentInstructorId);
            return Ok(materials);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpPost]
    public async Task<ActionResult<MaterialDto>> CreateMaterial(CreateMaterialDto dto)
    {
        try
        {
            var newMaterial = await _materialService.CreateMaterialAsync(dto, CurrentInstructorId);
            return Ok(newMaterial);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteMaterial(int id)
    {
        var result = await _materialService.DeleteMaterialAsync(id, CurrentInstructorId);
        if (!result) return NotFound("Không tìm thấy tài liệu học tập hoặc bạn không có quyền xóa.");
        return NoContent();
    }
}
