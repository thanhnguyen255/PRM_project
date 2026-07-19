using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;

namespace backend.BLL.DTOs.User;

public class UserDto
{
    public int Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public string Role { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class UpdateProfileDto
{
    [Required(ErrorMessage = "Vui lòng nhập họ và tên.")]
    [MaxLength(100)]
    public string FullName { get; set; } = string.Empty;

    [MaxLength(500)]
    public string? AvatarUrl { get; set; }

    // Ảnh đại diện dạng file (multipart) — tùy chọn. Nếu có sẽ được lưu và ghi đè AvatarUrl.
    public IFormFile? Avatar { get; set; }
}
