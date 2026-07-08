using backend.BLL.DTOs.Auth;
using backend.BLL.Helpers;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.BLL.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _db;
    private readonly JwtHelper _jwt;

    public AuthService(AppDbContext db, JwtHelper jwt)
    {
        _db = db;
        _jwt = jwt;
    }

    public async Task<LoginResponseDto> LoginAsync(LoginRequestDto dto)
    {
        var user = await _db.Users
            .FirstOrDefaultAsync(u => u.Email == dto.Email);

        if (user == null || !PasswordHelper.Verify(dto.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Email hoặc mật khẩu không đúng.");

        return new LoginResponseDto
        {
            Token = _jwt.GenerateToken(user),
            UserId = user.Id,
            FullName = user.FullName,
            Role = user.Role.ToString(),
            AvatarUrl = user.AvatarUrl
        };
    }

    public async Task<LoginResponseDto> RegisterAsync(RegisterRequestDto dto)
    {
        if (await _db.Users.AnyAsync(u => u.Email == dto.Email))
            throw new InvalidOperationException("Email này đã được sử dụng.");

        var user = new User
        {
            Email = dto.Email,
            PasswordHash = PasswordHelper.Hash(dto.Password),
            FullName = dto.FullName,
            Role = UserRole.Learner,
            CreatedAt = DateTime.UtcNow
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();

        return new LoginResponseDto
        {
            Token = _jwt.GenerateToken(user),
            UserId = user.Id,
            FullName = user.FullName,
            Role = user.Role.ToString(),
            AvatarUrl = user.AvatarUrl
        };
    }

    public async Task ForgotPasswordAsync(string email)
    {
        var exists = await _db.Users.AnyAsync(u => u.Email == email);
        if (!exists)
            throw new KeyNotFoundException("Email không tồn tại trong hệ thống.");

        // v1: In-app only — không gửi email thật. Sprint 2 sẽ tích hợp email service.
        Console.WriteLine($"[ForgotPassword] User {email} requested password reset at {DateTime.UtcNow:u}");
    }
}
