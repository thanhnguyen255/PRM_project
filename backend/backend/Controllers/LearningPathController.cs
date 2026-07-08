using backend.BLL.DTOs.LearningPath;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/learning-paths")]
[Authorize]
public class LearningPathController : BaseController
{
    private readonly ILearningPathService _learningPathService;

    public LearningPathController(ILearningPathService learningPathService)
    {
        _learningPathService = learningPathService;
    }

    [HttpGet]
    public async Task<IActionResult> GetPaths([FromQuery] int classId)
    {
        try
        {
            var role = GetCurrentUserRole();
            if (role == "Learner")
            {
                var paths = await _learningPathService.GetByClassAsync(classId, GetCurrentUserId());
                return Ok(ApiResponse.Success(paths));
            }
            else
            {
                var paths = await _learningPathService.GetLearningPathsByClassAsync(classId, GetCurrentUserId());
                return Ok(ApiResponse.Success(paths));
            }
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetLearningPathDetail(int id)
    {
        try
        {
            var detail = await _learningPathService.GetByIdAsync(id, GetCurrentUserId());
            return Ok(ApiResponse.Success(detail));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse.Fail(ex.Message));
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreatePath(CreateLearningPathDto dto)
    {
        try
        {
            var role = GetCurrentUserRole();
            if (role == "Learner") return Forbid("Chỉ giảng viên mới tạo được lộ trình học.");
            var newPath = await _learningPathService.CreateLearningPathAsync(dto, GetCurrentUserId());
            return Ok(ApiResponse.Success(newPath));
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletePath(int id)
    {
        var role = GetCurrentUserRole();
        if (role == "Learner") return Forbid("Chỉ giảng viên mới xóa được lộ trình học.");
        var result = await _learningPathService.DeleteLearningPathAsync(id, GetCurrentUserId());
        if (!result) return NotFound(ApiResponse.Fail("Không tìm thấy tuần học hoặc bạn không có quyền xóa."));
        return Ok(ApiResponse.Success(new { success = true }, "Xóa thành công."));
    }
}
