using backend.BLL.DTOs.Course;
using backend.BLL.Interfaces;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class CourseService : ICourseService
{
    private readonly IUnitOfWork _unitOfWork;

    public CourseService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<CourseDto>> GetCoursesByInstructorAsync(int instructorId)
    {
        var courses = await _unitOfWork.Repository<Course>().GetQueryable()
            .Include(c => c.Instructor)
            .Where(c => c.InstructorId == instructorId)
            .ToListAsync();

        return courses.Select(c => new CourseDto
        {
            Id = c.Id,
            Title = c.Title,
            Description = c.Description,
            CoverImageUrl = c.CoverImageUrl,
            InstructorId = c.InstructorId,
            InstructorName = c.Instructor.FullName
        });
    }

    public async Task<CourseDto?> GetCourseByIdAsync(int id, int instructorId)
    {
        var course = await _unitOfWork.Repository<Course>().GetQueryable()
            .Include(c => c.Instructor)
            .FirstOrDefaultAsync(c => c.Id == id && c.InstructorId == instructorId);

        if (course == null) return null;

        return new CourseDto
        {
            Id = course.Id,
            Title = course.Title,
            Description = course.Description,
            CoverImageUrl = course.CoverImageUrl,
            InstructorId = course.InstructorId,
            InstructorName = course.Instructor.FullName
        };
    }

    public async Task<CourseDto> CreateCourseAsync(CreateCourseDto dto, int instructorId)
    {
        var course = new Course
        {
            Title = dto.Title,
            Description = dto.Description,
            CoverImageUrl = dto.CoverImageUrl,
            InstructorId = instructorId,
            CreatedAt = DateTime.UtcNow
        };

        await _unitOfWork.Repository<Course>().AddAsync(course);
        await _unitOfWork.SaveChangesAsync();

        // Get instructor details to return DTO
        var instructor = await _unitOfWork.Repository<User>().GetByIdAsync(instructorId);

        return new CourseDto
        {
            Id = course.Id,
            Title = course.Title,
            Description = course.Description,
            CoverImageUrl = course.CoverImageUrl,
            InstructorId = course.InstructorId,
            InstructorName = instructor?.FullName ?? string.Empty
        };
    }

    public async Task<CourseDto?> UpdateCourseAsync(int id, CreateCourseDto dto, int instructorId)
    {
        var course = await _unitOfWork.Repository<Course>().GetQueryable()
            .FirstOrDefaultAsync(c => c.Id == id && c.InstructorId == instructorId);

        if (course == null) return null;

        course.Title = dto.Title;
        course.Description = dto.Description;
        course.CoverImageUrl = dto.CoverImageUrl;

        _unitOfWork.Repository<Course>().Update(course);
        await _unitOfWork.SaveChangesAsync();

        var instructor = await _unitOfWork.Repository<User>().GetByIdAsync(instructorId);

        return new CourseDto
        {
            Id = course.Id,
            Title = course.Title,
            Description = course.Description,
            CoverImageUrl = course.CoverImageUrl,
            InstructorId = course.InstructorId,
            InstructorName = instructor?.FullName ?? string.Empty
        };
    }

    public async Task<bool> DeleteCourseAsync(int id, int instructorId)
    {
        var course = await _unitOfWork.Repository<Course>().GetQueryable()
            .FirstOrDefaultAsync(c => c.Id == id && c.InstructorId == instructorId);

        if (course == null) return false;

        _unitOfWork.Repository<Course>().Delete(course);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }
}
