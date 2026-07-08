using backend.BLL.DTOs.Project;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api")]
public class MilestoneController : ControllerBase
{
    private readonly IProjectService _projectService;

    public MilestoneController(IProjectService projectService)
    {
        _projectService = projectService;
    }

    private int CurrentUserId
    {
        get
        {
            if (Request.Headers.TryGetValue("X-User-Id", out var value) && int.TryParse(value, out var id))
            {
                return id;
            }
            return 3; // Default to learner1
        }
    }

    [HttpGet("milestones")]
    public async Task<ActionResult<IEnumerable<MilestoneDto>>> GetMilestones([FromQuery] int projectId)
    {
        var milestones = await _projectService.GetMilestonesByProjectAsync(projectId);
        return Ok(milestones);
    }

    [HttpGet("milestones/{id}")]
    public async Task<ActionResult<MilestoneDto>> GetMilestone(int id)
    {
        var milestone = await _projectService.GetMilestoneByIdAsync(id);
        if (milestone == null) return NotFound("Không tìm thấy Milestone.");
        return Ok(milestone);
    }

    [HttpPost("milestones")]
    public async Task<ActionResult<MilestoneDto>> CreateMilestone(CreateMilestoneDto dto)
    {
        var milestone = await _projectService.CreateMilestoneAsync(dto);
        return CreatedAtAction(nameof(GetMilestone), new { id = milestone.Id }, milestone);
    }

    [HttpDelete("milestones/{id}")]
    public async Task<IActionResult> DeleteMilestone(int id)
    {
        var result = await _projectService.DeleteMilestoneAsync(id);
        if (!result) return NotFound("Không tìm thấy Milestone để xóa.");
        return NoContent();
    }

    [HttpPost("milestone-submissions")]
    public async Task<ActionResult<MilestoneSubmissionDto>> SubmitMilestone(CreateMilestoneSubmissionDto dto)
    {
        try
        {
            var submission = await _projectService.SubmitMilestoneAsync(dto, CurrentUserId);
            return Ok(submission);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ex.Message);
        }
    }

    [HttpGet("milestones/{id}/submissions")]
    public async Task<ActionResult<IEnumerable<MilestoneSubmissionDto>>> GetSubmissions(int id)
    {
        var submissions = await _projectService.GetSubmissionsByMilestoneAsync(id);
        return Ok(submissions);
    }
}
