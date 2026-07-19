using backend.BLL.DTOs.Course;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/courses")]
[Authorize]
public class CourseController : BaseController
{
    private readonly ICourseService _courseService;

    public CourseController(ICourseService courseService)
    {
        _courseService = courseService;
    }

    [HttpGet]
    public async Task<IActionResult> GetCourses()
    {
        // Default to instructor logic for generic list (or we can block learners here)
        var role = GetCurrentUserRole();
        if (role == "Learner") return StatusCode(403, ApiResponse.Fail("Chỉ giảng viên mới xem được danh sách tất cả khóa học."));
        var courses = await _courseService.GetCoursesByInstructorAsync(GetCurrentUserId());
        return Ok(ApiResponse.Success(courses));
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyCourses()
    {
        var role = GetCurrentUserRole();
        if (role == "Learner")
        {
            var courses = await _courseService.GetCoursesByLearnerAsync(GetCurrentUserId());
            return Ok(ApiResponse.Success(courses));
        }
        else
        {
            var courses = await _courseService.GetCoursesByInstructorAsync(GetCurrentUserId());
            return Ok(ApiResponse.Success(courses));
        }
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetCourse(int id)
    {
        var course = await _courseService.GetCourseByIdAsync(id, GetCurrentUserId());
        if (course == null) return NotFound(ApiResponse.Fail("Không tìm thấy môn học hoặc bạn không có quyền truy cập."));
        return Ok(ApiResponse.Success(course));
    }

    [HttpPost]
    public async Task<IActionResult> CreateCourse(CreateCourseDto dto)
    {
        var course = await _courseService.CreateCourseAsync(dto, GetCurrentUserId());
        return CreatedAtAction(nameof(GetCourse), new { id = course.Id }, ApiResponse.Success(course));
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateCourse(int id, CreateCourseDto dto)
    {
        var course = await _courseService.UpdateCourseAsync(id, dto, GetCurrentUserId());
        if (course == null) return NotFound(ApiResponse.Fail("Không tìm thấy môn học hoặc bạn không có quyền cập nhật."));
        return Ok(ApiResponse.Success(course));
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteCourse(int id)
    {
        var result = await _courseService.DeleteCourseAsync(id, GetCurrentUserId());
        if (!result) return NotFound(ApiResponse.Fail("Không tìm thấy môn học hoặc bạn không có quyền xóa."));
        return Ok(ApiResponse.Success(new { success = true }, "Xóa thành công."));
    }
}
