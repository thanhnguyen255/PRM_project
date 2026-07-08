using backend.BLL.DTOs.Class;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/classes")]
public class ClassController : ControllerBase
{
    private readonly IClassService _classService;

    public ClassController(IClassService classService)
    {
        _classService = classService;
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
    public async Task<ActionResult<IEnumerable<ClassDto>>> GetClasses([FromQuery] int courseId)
    {
        try
        {
            var classes = await _classService.GetClassesByCourseAsync(courseId, CurrentInstructorId);
            return Ok(classes);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpPost]
    public async Task<ActionResult<ClassDto>> CreateClass(CreateClassDto dto)
    {
        try
        {
            var newClass = await _classService.CreateClassAsync(dto, CurrentInstructorId);
            return Ok(newClass);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpPost("{id}/members")]
    public async Task<IActionResult> AddMember(int id, AddClassMemberDto dto)
    {
        try
        {
            var result = await _classService.AddMemberToClassAsync(id, dto, CurrentInstructorId);
            if (!result) return BadRequest("Không thể thêm thành viên (người dùng không tồn tại).");
            return Ok("Đã thêm thành viên vào lớp thành công.");
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpDelete("{id}/members/{uid}")]
    public async Task<IActionResult> RemoveMember(int id, int uid)
    {
        try
        {
            var result = await _classService.RemoveMemberFromClassAsync(id, uid, CurrentInstructorId);
            if (!result) return NotFound("Thành viên không tồn tại trong lớp.");
            return Ok("Đã xóa thành viên khỏi lớp thành công.");
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }
}
