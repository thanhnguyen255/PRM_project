using backend.BLL.DTOs.Class;
using backend.BLL.Interfaces;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class ClassService : IClassService
{
    private readonly IUnitOfWork _unitOfWork;

    public ClassService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<ClassDto>> GetClassesByCourseAsync(int courseId, int instructorId)
    {
        // Verify course belongs to instructor
        var course = await _unitOfWork.Repository<Course>().GetQueryable()
            .FirstOrDefaultAsync(c => c.Id == courseId && c.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu khóa học này.");

        var classes = await _unitOfWork.Repository<Class>().GetQueryable()
            .Where(c => c.CourseId == courseId)
            .ToListAsync();

        return classes.Select(c => new ClassDto
        {
            Id = c.Id,
            Name = c.Name,
            CourseId = c.CourseId,
            CourseTitle = course.Title,
            StartDate = c.StartDate,
            EndDate = c.EndDate
        });
    }

    public async Task<ClassDto> CreateClassAsync(CreateClassDto dto, int instructorId)
    {
        // Verify course belongs to instructor
        var course = await _unitOfWork.Repository<Course>().GetQueryable()
            .FirstOrDefaultAsync(c => c.Id == dto.CourseId && c.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu khóa học này.");

        var newClass = new Class
        {
            Name = dto.Name,
            CourseId = dto.CourseId,
            StartDate = dto.StartDate,
            EndDate = dto.EndDate
        };

        await _unitOfWork.Repository<Class>().AddAsync(newClass);
        await _unitOfWork.SaveChangesAsync();

        return new ClassDto
        {
            Id = newClass.Id,
            Name = newClass.Name,
            CourseId = newClass.CourseId,
            CourseTitle = course.Title,
            StartDate = newClass.StartDate,
            EndDate = newClass.EndDate
        };
    }

    public async Task<bool> AddMemberToClassAsync(int classId, AddClassMemberDto dto, int instructorId)
    {
        // Verify class belongs to course owned by instructor
        var classObj = await _unitOfWork.Repository<Class>().GetQueryable()
            .Include(c => c.Course)
            .FirstOrDefaultAsync(c => c.Id == classId && c.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu lớp học này.");

        // Check if user exists by email
        var user = await _unitOfWork.Repository<User>().GetQueryable()
            .FirstOrDefaultAsync(u => u.Email == dto.Email);
        if (user == null) return false;

        // Check if member already in class
        var existingMember = await _unitOfWork.Repository<ClassMember>().GetQueryable()
            .FirstOrDefaultAsync(cm => cm.ClassId == classId && cm.UserId == user.Id);

        if (existingMember != null) return true; // Already added

        var classMember = new ClassMember
        {
            ClassId = classId,
            UserId = user.Id,
            JoinedAt = DateTime.UtcNow
        };

        await _unitOfWork.Repository<ClassMember>().AddAsync(classMember);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }

    public async Task<bool> RemoveMemberFromClassAsync(int classId, int userId, int instructorId)
    {
        // Verify class belongs to course owned by instructor
        var classObj = await _unitOfWork.Repository<Class>().GetQueryable()
            .Include(c => c.Course)
            .FirstOrDefaultAsync(c => c.Id == classId && c.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu lớp học này.");

        // Find member
        var classMember = await _unitOfWork.Repository<ClassMember>().GetQueryable()
            .FirstOrDefaultAsync(cm => cm.ClassId == classId && cm.UserId == userId);

        if (classMember == null) return false;

        _unitOfWork.Repository<ClassMember>().Delete(classMember);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }
}
