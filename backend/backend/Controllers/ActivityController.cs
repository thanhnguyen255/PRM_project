using backend.BLL.DTOs.Activity;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/activities")]
public class ActivityController : ControllerBase
{
    private readonly IActivityService _activityService;

    public ActivityController(IActivityService activityService)
    {
        _activityService = activityService;
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
    public async Task<ActionResult<IEnumerable<ActivityDto>>> GetActivities([FromQuery] int pathId, [FromQuery] string? type)
    {
        try
        {
            var activities = await _activityService.GetActivitiesByPathAsync(pathId, type, CurrentInstructorId);
            return Ok(activities);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpPost]
    public async Task<ActionResult<ActivityDto>> CreateActivity(CreateActivityDto dto)
    {
        try
        {
            var newActivity = await _activityService.CreateActivityAsync(dto, CurrentInstructorId);
            return Ok(newActivity);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<ActivityDto>> UpdateActivity(int id, UpdateActivityDto dto)
    {
        var updatedActivity = await _activityService.UpdateActivityAsync(id, dto, CurrentInstructorId);
        if (updatedActivity == null) return NotFound("Không tìm thấy hoạt động hoặc bạn không có quyền cập nhật.");
        return Ok(updatedActivity);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteActivity(int id)
    {
        var result = await _activityService.DeleteActivityAsync(id, CurrentInstructorId);
        if (!result) return NotFound("Không tìm thấy hoạt động hoặc bạn không có quyền xóa.");
        return NoContent();
    }
}
