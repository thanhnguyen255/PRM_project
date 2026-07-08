namespace backend.BLL.DTOs.Material;

public class MaterialDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty; // Video | Document | Link
    public string? FileUrl { get; set; }
    public string? LinkUrl { get; set; }
}
