using backend.BLL.DTOs.Project;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/projects")]
[Authorize]
public class ProjectController : BaseController
{
    private readonly IProjectService _projectService;

    public ProjectController(IProjectService projectService)
    {
        _projectService = projectService;
    }

    [HttpGet]
    public async Task<IActionResult> GetProjects([FromQuery] int classId)
    {
        var projects = await _projectService.GetProjectsByClassAsync(classId);
        return Ok(ApiResponse.Success(projects));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetProject(int id)
    {
        var project = await _projectService.GetProjectByIdAsync(id);
        if (project == null) return NotFound(ApiResponse.Fail("Không tìm thấy dự án."));
        return Ok(ApiResponse.Success(project));
    }

    [HttpPost]
    public async Task<IActionResult> CreateProject(CreateProjectDto dto)
    {
        var project = await _projectService.CreateProjectAsync(dto);
        return StatusCode(201, ApiResponse.Success(project, "Project created"));
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProject(int id)
    {
        var result = await _projectService.DeleteProjectAsync(id);
        if (!result) return NotFound(ApiResponse.Fail("Không tìm thấy dự án để xóa."));
        return Ok(ApiResponse.Success<object?>(null));
    }
}
