using backend.BLL.DTOs.Activity;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/activities")]
[Authorize]
public class ActivityController : BaseController
{
    private readonly IActivityService _activityService;

    public ActivityController(IActivityService activityService)
    {
        _activityService = activityService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ActivityDto>>> GetActivities([FromQuery] int pathId, [FromQuery] string? type)
    {
        try
        {
            var activities = await _activityService.GetActivitiesByPathAsync(pathId, type, GetCurrentUserId());
            return Ok(ApiResponse.Success(activities));
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpGet("upcoming")]
    public async Task<IActionResult> GetUpcoming([FromQuery] int? classId, [FromQuery] int limit = 5)
    {
        if (GetCurrentUserRole() != "Learner") return Forbid();
        var activities = await _activityService.GetUpcomingActivitiesAsync(GetCurrentUserId(), classId, limit);
        return Ok(ApiResponse.Success(activities));
    }

    [HttpPost]
    public async Task<IActionResult> CreateActivity(CreateActivityDto dto)
    {
        try
        {
            var newActivity = await _activityService.CreateActivityAsync(dto, GetCurrentUserId());
            return Ok(ApiResponse.Success(newActivity));
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateActivity(int id, UpdateActivityDto dto)
    {
        var updatedActivity = await _activityService.UpdateActivityAsync(id, dto, GetCurrentUserId());
        if (updatedActivity == null) return NotFound(ApiResponse.Fail("Không tìm thấy hoạt động hoặc bạn không có quyền cập nhật."));
        return Ok(ApiResponse.Success(updatedActivity));
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteActivity(int id)
    {
        var result = await _activityService.DeleteActivityAsync(id, GetCurrentUserId());
        if (!result) return NotFound(ApiResponse.Fail("Không tìm thấy hoạt động hoặc bạn không có quyền xóa."));
        return Ok(ApiResponse.Success(new { success = true }, "Xóa thành công."));
    }
}
