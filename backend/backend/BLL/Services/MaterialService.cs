using backend.BLL.DTOs.Material;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using backend.DAL.Interfaces;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class MaterialService : IMaterialService
{
    private readonly AppDbContext _db;
    private readonly IUnitOfWork _unitOfWork;

    public MaterialService(AppDbContext db, IUnitOfWork unitOfWork)
    {
        _db = db;
        _unitOfWork = unitOfWork;
    }

    public async Task<List<MaterialDto>> GetByPathAsync(int pathId, string? type)
    {
        var query = _db.LearningMaterials.Where(m => m.LearningPathId == pathId);

        if (!string.IsNullOrEmpty(type) && Enum.TryParse<MaterialType>(type, true, out var materialType))
            query = query.Where(m => m.Type == materialType);

        return await query
            .Select(m => new MaterialDto
            {
                Id = m.Id,
                Title = m.Title,
                Type = m.Type.ToString(),
                FileUrl = m.FileUrl,
                LinkUrl = m.LinkUrl,
                LearningPathId = m.LearningPathId
            })
            .ToListAsync();
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
            Type = m.Type.ToString(),
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

        string? fileUrl = dto.FileUrl;
        if (dto.File != null && dto.File.Length > 0)
        {
            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            var uniqueFileName = Guid.NewGuid().ToString() + "_" + Path.GetFileName(dto.File.FileName);
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await dto.File.CopyToAsync(stream);
            }

            fileUrl = "/uploads/" + uniqueFileName;
        }

        var material = new LearningMaterial
        {
            Title = dto.Title,
            Type = dto.Type,
            FileUrl = fileUrl,
            LinkUrl = dto.LinkUrl,
            LearningPathId = dto.LearningPathId
        };

        await _unitOfWork.Repository<LearningMaterial>().AddAsync(material);
        await _unitOfWork.SaveChangesAsync();

        return new MaterialDto
        {
            Id = material.Id,
            Title = material.Title,
            Type = material.Type.ToString(),
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

    public async Task<MaterialDto?> GetByIdAsync(int id)
    {
        var m = await _db.LearningMaterials.FirstOrDefaultAsync(m => m.Id == id);
        if (m == null) return null;
        
        return new MaterialDto
        {
            Id = m.Id,
            Title = m.Title,
            Type = m.Type.ToString(),
            FileUrl = m.FileUrl,
            LinkUrl = m.LinkUrl,
            LearningPathId = m.LearningPathId
        };
    }
}
