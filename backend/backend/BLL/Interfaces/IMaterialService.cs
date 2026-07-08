using backend.BLL.DTOs.Material;

namespace backend.BLL.Interfaces;

public interface IMaterialService
{
    Task<List<MaterialDto>> GetByPathAsync(int pathId, string? type);
}
