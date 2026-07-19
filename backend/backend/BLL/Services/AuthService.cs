using backend.BLL.DTOs.Auth;
using backend.BLL.Helpers;
using backend.BLL.Interfaces;
using backend.DAL;
using backend.DAL.Enums;
using backend.DAL.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using System.Security.Cryptography;

namespace backend.BLL.Services;

public class AuthService : IAuthService
{
    private readonly AppDbContext _db;
    private readonly JwtHelper _jwt;
    private readonly IMemoryCache _cache;
    private readonly IEmailService _emailService;

    public AuthService(AppDbContext db, JwtHelper jwt, IMemoryCache cache, IEmailService emailService)
    {
        _db = db;
        _jwt = jwt;
        _cache = cache;
        _emailService = emailService;
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

        var otp = RandomNumberGenerator.GetInt32(100000, 999999).ToString();
        
        // Save OTP to cache with 5 minutes expiration
        _cache.Set($"OTP_{email}", otp, TimeSpan.FromMinutes(5));

        var body = $@"
            <h2>Khôi phục mật khẩu</h2>
            <p>Mã OTP của bạn là: <strong>{otp}</strong></p>
            <p>Mã này sẽ hết hạn sau 5 phút.</p>";

        await _emailService.SendEmailAsync(email, "Mã OTP khôi phục mật khẩu", body);
    }

    public async Task<string> VerifyOtpAsync(VerifyOtpDto dto)
    {
        if (!_cache.TryGetValue($"OTP_{dto.Email}", out string? storedOtp) || storedOtp != dto.Otp)
            throw new ArgumentException("Mã OTP không hợp lệ hoặc đã hết hạn.");

        // OTP is valid. Clear OTP and generate a temporary reset token (valid for 15 mins)
        _cache.Remove($"OTP_{dto.Email}");
        var resetToken = Guid.NewGuid().ToString("N");
        _cache.Set($"ResetToken_{dto.Email}", resetToken, TimeSpan.FromMinutes(15));

        return resetToken;
    }

    public async Task ResetPasswordAsync(ResetPasswordDto dto)
    {
        if (!_cache.TryGetValue($"ResetToken_{dto.Email}", out string? storedToken) || storedToken != dto.ResetToken)
            throw new ArgumentException("Phiên làm việc không hợp lệ hoặc đã hết hạn.");

        var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
        if (user == null)
            throw new KeyNotFoundException("User không tồn tại.");

        user.PasswordHash = PasswordHelper.Hash(dto.NewPassword);
        await _db.SaveChangesAsync();

        _cache.Remove($"ResetToken_{dto.Email}");
    }
}
