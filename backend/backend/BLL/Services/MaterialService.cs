using backend.BLL.DTOs.Material;
using backend.BLL.Interfaces;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class MaterialService : IMaterialService
{
    private readonly IUnitOfWork _unitOfWork;

    public MaterialService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<IEnumerable<MaterialDto>> GetMaterialsByPathAsync(int pathId, int instructorId)
    {
        // Verify learning path belongs to class of course owned by instructor
        var learningPath = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Include(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(lp => lp.Id == pathId && lp.Class.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu tuần học này.");

        var materials = await _unitOfWork.Repository<LearningMaterial>().GetQueryable()
            .Where(m => m.LearningPathId == pathId)
            .ToListAsync();

        return materials.Select(m => new MaterialDto
        {
            Id = m.Id,
            Title = m.Title,
            Type = m.Type,
            FileUrl = m.FileUrl,
            LinkUrl = m.LinkUrl,
            LearningPathId = m.LearningPathId
        });
    }

    public async Task<MaterialDto> CreateMaterialAsync(CreateMaterialDto dto, int instructorId)
    {
        // Verify learning path belongs to class of course owned by instructor
        var learningPath = await _unitOfWork.Repository<LearningPath>().GetQueryable()
            .Include(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(lp => lp.Id == dto.LearningPathId && lp.Class.Course.InstructorId == instructorId)
            ?? throw new UnauthorizedAccessException("Bạn không sở hữu tuần học này.");

        var material = new LearningMaterial
        {
            Title = dto.Title,
            Type = dto.Type,
            FileUrl = dto.FileUrl,
            LinkUrl = dto.LinkUrl,
            LearningPathId = dto.LearningPathId
        };

        await _unitOfWork.Repository<LearningMaterial>().AddAsync(material);
        await _unitOfWork.SaveChangesAsync();

        return new MaterialDto
        {
            Id = material.Id,
            Title = material.Title,
            Type = material.Type,
            FileUrl = material.FileUrl,
            LinkUrl = material.LinkUrl,
            LearningPathId = material.LearningPathId
        };
    }

    public async Task<bool> DeleteMaterialAsync(int id, int instructorId)
    {
        // Verify material belongs to course owned by instructor
        var material = await _unitOfWork.Repository<LearningMaterial>().GetQueryable()
            .Include(m => m.LearningPath)
            .ThenInclude(lp => lp.Class)
            .ThenInclude(c => c.Course)
            .FirstOrDefaultAsync(m => m.Id == id && m.LearningPath.Class.Course.InstructorId == instructorId);

        if (material == null) return false;

        _unitOfWork.Repository<LearningMaterial>().Delete(material);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }
}
