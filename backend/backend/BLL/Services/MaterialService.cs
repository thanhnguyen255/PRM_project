using backend.BLL.DTOs.Material;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class MaterialService : IMaterialService
{
    private readonly AppDbContext _db;

    public MaterialService(AppDbContext db)
    {
        _db = db;
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
                LinkUrl = m.LinkUrl
            })
            .ToListAsync();
    }
}
