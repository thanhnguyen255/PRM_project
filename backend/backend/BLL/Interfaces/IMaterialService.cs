using backend.BLL.DTOs.Material;

namespace backend.BLL.Interfaces;

public interface IMaterialService
{
    Task<IEnumerable<MaterialDto>> GetMaterialsByPathAsync(int pathId, int instructorId);
    Task<MaterialDto> CreateMaterialAsync(CreateMaterialDto dto, int instructorId);
    Task<bool> DeleteMaterialAsync(int id, int instructorId);
}
