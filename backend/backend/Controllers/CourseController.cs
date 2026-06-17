using backend.BLL.DTOs.Course;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/courses")]
public class CourseController : ControllerBase
{
    private readonly ICourseService _courseService;

    public CourseController(ICourseService courseService)
    {
        _courseService = courseService;
    }

    private int CurrentInstructorId
    {
        get
        {
            if (Request.Headers.TryGetValue("X-Instructor-Id", out var value) && int.TryParse(value, out var id))
            {
                return id;
            }
            return 1; // Default to instructor 1 (from seed data) for easy testing
        }
    }

    [HttpGet]
    [HttpGet("my")]
    public async Task<ActionResult<IEnumerable<CourseDto>>> GetCourses()
    {
        var courses = await _courseService.GetCoursesByInstructorAsync(CurrentInstructorId);
        return Ok(courses);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<CourseDto>> GetCourse(int id)
    {
        var course = await _courseService.GetCourseByIdAsync(id, CurrentInstructorId);
        if (course == null) return NotFound("Không tìm thấy môn học hoặc bạn không có quyền truy cập.");
        return Ok(course);
    }

    [HttpPost]
    public async Task<ActionResult<CourseDto>> CreateCourse(CreateCourseDto dto)
    {
        var course = await _courseService.CreateCourseAsync(dto, CurrentInstructorId);
        return CreatedAtAction(nameof(GetCourse), new { id = course.Id }, course);
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<CourseDto>> UpdateCourse(int id, CreateCourseDto dto)
    {
        var course = await _courseService.UpdateCourseAsync(id, dto, CurrentInstructorId);
        if (course == null) return NotFound("Không tìm thấy môn học hoặc bạn không có quyền cập nhật.");
        return Ok(course);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteCourse(int id)
    {
        var result = await _courseService.DeleteCourseAsync(id, CurrentInstructorId);
        if (!result) return NotFound("Không tìm thấy môn học hoặc bạn không có quyền xóa.");
        return NoContent();
    }
}
