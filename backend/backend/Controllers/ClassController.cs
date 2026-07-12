using backend.BLL.DTOs.Class;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/classes")]
[Authorize]
public class ClassController : BaseController
{
    private readonly IClassService _classService;

    public ClassController(IClassService classService)
    {
        _classService = classService;
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyClasses()
    {
        var result = await _classService.GetMyClassesAsync(GetCurrentUserId());
        return Ok(ApiResponse.Success(result));
    }

    [HttpGet]
    public async Task<IActionResult> GetClasses([FromQuery] int courseId)
    {
        try
        {
            var role = GetCurrentUserRole();
            if (role == "Learner") return Forbid("Chỉ giảng viên mới xem được danh sách lớp học của khóa học.");
            var classes = await _classService.GetClassesByCourseAsync(courseId, GetCurrentUserId());
            return Ok(ApiResponse.Success(classes));
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetClass(int id)
    {
        try
        {
            var classDetail = await _classService.GetClassByIdAsync(id, GetCurrentUserId());
            return Ok(ApiResponse.Success(classDetail));
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse.Fail(ex.Message));
        }
    }

    [HttpGet("{id}/members")]
    public async Task<IActionResult> GetMembers(int id)
    {
        var members = await _classService.GetMembersAsync(id);
        return Ok(ApiResponse.Success(members));
    }

    [HttpPost]
    public async Task<IActionResult> CreateClass(CreateClassDto dto)
    {
        try
        {
            var role = GetCurrentUserRole();
            if (role == "Learner") return Forbid("Chỉ giảng viên mới tạo được lớp học.");
            var newClass = await _classService.CreateClassAsync(dto, GetCurrentUserId());
            return Ok(ApiResponse.Success(newClass));
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
            var role = GetCurrentUserRole();
            if (role == "Learner") return Forbid("Chỉ giảng viên mới thêm được thành viên.");
            var result = await _classService.AddMemberToClassAsync(id, dto, GetCurrentUserId());
            if (!result) return BadRequest(ApiResponse.Fail("Không thể thêm thành viên (người dùng không tồn tại hoặc đã tồn tại)."));
            return Ok(ApiResponse.Success(new { success = true }, "Đã thêm thành viên vào lớp thành công."));
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
            var role = GetCurrentUserRole();
            if (role == "Learner") return Forbid("Chỉ giảng viên mới xóa được thành viên.");
            var result = await _classService.RemoveMemberFromClassAsync(id, uid, GetCurrentUserId());
            if (!result) return NotFound(ApiResponse.Fail("Thành viên không tồn tại trong lớp."));
            return Ok(ApiResponse.Success(new { success = true }, "Đã xóa thành viên khỏi lớp thành công."));
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
    }
}
