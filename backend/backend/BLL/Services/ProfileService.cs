using backend.BLL.DTOs.User;
using backend.BLL.Interfaces;
using backend.DAL;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class ProfileService : IProfileService
{
    private readonly AppDbContext _db;

    public ProfileService(AppDbContext db)
    {
        _db = db;
    }

    public async Task<UserDto> GetProfileAsync(int userId)
    {
        var user = await _db.Users.FindAsync(userId)
            ?? throw new KeyNotFoundException("Không tìm thấy người dùng.");

        return MapToDto(user);
    }

    public async Task<UserDto> UpdateProfileAsync(int userId, UpdateProfileDto dto)
    {
        var user = await _db.Users.FindAsync(userId)
            ?? throw new KeyNotFoundException("Không tìm thấy người dùng.");

        user.FullName = dto.FullName;

        if (dto.Avatar != null && dto.Avatar.Length > 0)
        {
            // Ưu tiên file ảnh upload: lưu vào thư mục uploads (ngoài project) rồi gán đường dẫn.
            var uploadsFolder = backend.BLL.Helpers.UploadPaths.Root;
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            var uniqueFileName = $"{Guid.NewGuid()}_{Path.GetFileName(dto.Avatar.FileName)}";
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await dto.Avatar.CopyToAsync(stream);
            }

            user.AvatarUrl = $"/uploads/{uniqueFileName}";
        }
        else if (dto.AvatarUrl != null)
        {
            // Không có file mới -> giữ/đặt theo URL truyền lên (nếu có).
            user.AvatarUrl = dto.AvatarUrl;
        }

        await _db.SaveChangesAsync();

        return MapToDto(user);
    }

    private static UserDto MapToDto(DAL.Models.User user) => new()
    {
        Id = user.Id,
        Email = user.Email,
        FullName = user.FullName,
        AvatarUrl = user.AvatarUrl,
        Role = user.Role.ToString(),
        CreatedAt = user.CreatedAt
    };
}
