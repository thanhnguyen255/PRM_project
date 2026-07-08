using backend.BLL.DTOs.LearningPath;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/learning-paths")]
public class LearningPathController : ControllerBase
{
    private readonly ILearningPathService _learningPathService;

    public LearningPathController(ILearningPathService learningPathService)
    {
        _learningPathService = learningPathService;
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
    public async Task<ActionResult<IEnumerable<LearningPathDto>>> GetPaths([FromQuery] int classId)
    {
        try
        {
            var paths = await _learningPathService.GetLearningPathsByClassAsync(classId, CurrentInstructorId);
            return Ok(paths);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpPost]
    public async Task<ActionResult<LearningPathDto>> CreatePath(CreateLearningPathDto dto)
    {
        try
        {
            var newPath = await _learningPathService.CreateLearningPathAsync(dto, CurrentInstructorId);
            return Ok(newPath);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletePath(int id)
    {
        var result = await _learningPathService.DeleteLearningPathAsync(id, CurrentInstructorId);
        if (!result) return NotFound("Không tìm thấy tuần học hoặc bạn không có quyền xóa.");
        return NoContent();
    }
}
