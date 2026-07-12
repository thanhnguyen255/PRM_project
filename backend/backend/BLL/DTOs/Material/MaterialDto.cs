using backend.DAL.Enums;
namespace backend.BLL.DTOs.Material;

public class MaterialDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty; // Changed to string to unify
    public string? FileUrl { get; set; }
    public string? LinkUrl { get; set; }
    public int LearningPathId { get; set; }
}

public class CreateMaterialDto
{
    public string Title { get; set; } = string.Empty;
    public MaterialType Type { get; set; }
    public string? FileUrl { get; set; }
    public string? LinkUrl { get; set; }
    public int LearningPathId { get; set; }
    public Microsoft.AspNetCore.Http.IFormFile? File { get; set; }
}
