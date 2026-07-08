using backend.BLL.DTOs.LearningPath;
using backend.BLL.Interfaces;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class LearningPathService : ILearningPathService
{
    private readonly IUnitOfWork _unitOfWork;

    public LearningPathService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<LearningPathDto>> GetLearningPathsByClassAsync(int classId, int instructorId)
    {
        // Verify class belongs to course owned by instructor
        var classObj = await _unitOfWork.Repository<Class>().GetQueryable()
            .Include(c => c.Course)
            .FirstOrDefaultAsync(c => c.Id == classId && c.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu lớp học này.");

        var paths = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Where(lp => lp.ClassId == classId)
            .OrderBy(lp => lp.WeekNumber)
            .ToListAsync();

        return paths.Select(lp => new LearningPathDto
        {
            Id = lp.Id,
            Title = lp.Title,
            ClassId = lp.ClassId,
            WeekNumber = lp.WeekNumber
        });
    }

    public async Task<LearningPathDto> CreateLearningPathAsync(CreateLearningPathDto dto, int instructorId)
    {
        // Verify class belongs to course owned by instructor
        var classObj = await _unitOfWork.Repository<Class>().GetQueryable()
            .Include(c => c.Course)
            .FirstOrDefaultAsync(c => c.Id == dto.ClassId && c.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu lớp học này.");

        var learningPath = new LearningPath
        {
            Title = dto.Title,
            ClassId = dto.ClassId,
            WeekNumber = dto.WeekNumber
        };

        await _unitOfWork.Repository<LearningPath>().AddAsync(learningPath);
        await _unitOfWork.SaveChangesAsync();

        return new LearningPathDto
        {
            Id = learningPath.Id,
            Title = learningPath.Title,
            ClassId = learningPath.ClassId,
            WeekNumber = learningPath.WeekNumber
        };
    }

    public async Task<bool> DeleteLearningPathAsync(int id, int instructorId)
    {
        // Verify learning path belongs to class of course owned by instructor
        var learningPath = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Include(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(lp => lp.Id == id && lp.Class.Course.InstructorId == instructorId);

        if (learningPath == null) return false;

        _unitOfWork.Repository<LearningPath>().Delete(learningPath);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }
}
