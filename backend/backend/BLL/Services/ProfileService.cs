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
        user.AvatarUrl = dto.AvatarUrl;
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
