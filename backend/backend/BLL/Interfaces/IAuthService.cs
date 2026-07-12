using backend.BLL.DTOs.Auth;

namespace backend.BLL.Interfaces;

public interface IAuthService
{
    Task<LoginResponseDto> LoginAsync(LoginRequestDto dto);
    Task<LoginResponseDto> RegisterAsync(RegisterRequestDto dto);
    Task ForgotPasswordAsync(string email);
    Task<string> VerifyOtpAsync(VerifyOtpDto dto);
    Task ResetPasswordAsync(ResetPasswordDto dto);
}
