using backend.BLL.DTOs.Project;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api")]
[Authorize]
public class MilestoneController : BaseController
{
    private readonly IProjectService _projectService;

    public MilestoneController(IProjectService projectService)
    {
        _projectService = projectService;
    }



    [HttpGet("milestones")]
    public async Task<IActionResult> GetMilestones([FromQuery] int projectId)
    {
        var milestones = await _projectService.GetMilestonesByProjectAsync(projectId);
        return Ok(ApiResponse.Success(milestones));
    }

    [HttpGet("milestones/{id}")]
    public async Task<IActionResult> GetMilestone(int id)
    {
        var milestone = await _projectService.GetMilestoneByIdAsync(id);
        if (milestone == null) return NotFound(ApiResponse.Fail("Không tìm thấy Milestone."));
        return Ok(ApiResponse.Success(milestone));
    }

    [HttpPost("milestones")]
    public async Task<IActionResult> CreateMilestone(CreateMilestoneDto dto)
    {
        var milestone = await _projectService.CreateMilestoneAsync(dto);
        return StatusCode(201, ApiResponse.Success(milestone, "Milestone created"));
    }

    [HttpDelete("milestones/{id}")]
    public async Task<IActionResult> DeleteMilestone(int id)
    {
        var result = await _projectService.DeleteMilestoneAsync(id);
        if (!result) return NotFound(ApiResponse.Fail("Không tìm thấy Milestone để xóa."));
        return Ok(ApiResponse.Success<object?>(null));
    }

    [HttpPost("milestone-submissions")]
    public async Task<IActionResult> SubmitMilestone([FromForm] CreateMilestoneSubmissionDto dto)
    {
        try
        {
            var submission = await _projectService.SubmitMilestoneAsync(dto, GetCurrentUserId());
            return StatusCode(201, ApiResponse.Success(submission, "Đã nộp bài thành công"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse.Fail(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse.Fail(ex.Message));
        }
    }

    [HttpGet("milestones/{id}/submissions")]
    public async Task<IActionResult> GetSubmissions(int id)
    {
        var submissions = await _projectService.GetSubmissionsByMilestoneAsync(id);
        return Ok(ApiResponse.Success(submissions));
    }

    [HttpGet("milestone-submissions")]
    public async Task<IActionResult> GetMySubmission([FromQuery] int milestoneId, [FromQuery] string userId)
    {
        int targetUserId = GetCurrentUserId();
        if (userId != "me")
        {
            if (int.TryParse(userId, out int parsedId))
            {
                targetUserId = parsedId;
            }
        }
        
        var submission = await _projectService.GetMilestoneSubmissionAsync(milestoneId, targetUserId);
        if (submission == null) return NotFound(ApiResponse.Fail("Không tìm thấy submission."));
        return Ok(ApiResponse.Success(submission));
    }
}
