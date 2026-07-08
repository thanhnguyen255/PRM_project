using backend.BLL.DTOs.Course;

namespace backend.BLL.Interfaces;

public interface ICourseService
{
    Task<IEnumerable<CourseDto>> GetCoursesByInstructorAsync(int instructorId);
    Task<IEnumerable<MyCourseDto>> GetCoursesByLearnerAsync(int learnerId);
    Task<CourseDto?> GetCourseByIdAsync(int id, int instructorId);
    Task<CourseDto> CreateCourseAsync(CreateCourseDto dto, int instructorId);
    Task<CourseDto?> UpdateCourseAsync(int id, CreateCourseDto dto, int instructorId);
    Task<bool> DeleteCourseAsync(int id, int instructorId);
}
