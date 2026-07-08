using backend.BLL.DTOs.Material;

namespace backend.BLL.Interfaces;

public interface IMaterialService
{
    Task<List<MaterialDto>> GetByPathAsync(int pathId, string? type);
    Task<IEnumerable<MaterialDto>> GetMaterialsByPathAsync(int pathId, int instructorId);
    Task<MaterialDto> CreateMaterialAsync(CreateMaterialDto dto, int instructorId);
    Task<bool> DeleteMaterialAsync(int id, int instructorId);
}
