using backend.BLL.DTOs.Auth;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/auth")]
public class AuthController : BaseController
{
    private readonly IAuthService _auth;

    public AuthController(IAuthService auth)
    {
        _auth = auth;
    }

    /// <summary>POST /api/auth/login</summary>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ApiResponse.Fail("Dữ liệu không hợp lệ."));

        var result = await _auth.LoginAsync(dto);
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>POST /api/auth/register</summary>
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ApiResponse.Fail("Dữ liệu không hợp lệ."));

        var result = await _auth.RegisterAsync(dto);
        return StatusCode(201, ApiResponse.Success(result));
    }

    /// <summary>POST /api/auth/forgot-password</summary>
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ApiResponse.Fail("Dữ liệu không hợp lệ."));

        await _auth.ForgotPasswordAsync(dto.Email);
        return Ok(ApiResponse.Success<object?>(null, "Nếu email tồn tại, mã OTP đã được gửi."));
    }

    /// <summary>POST /api/auth/verify-otp</summary>
    [HttpPost("verify-otp")]
    public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ApiResponse.Fail("Dữ liệu không hợp lệ."));

        var resetToken = await _auth.VerifyOtpAsync(dto);
        return Ok(ApiResponse.Success(new { token = resetToken }, "Xác thực OTP thành công."));
    }

    /// <summary>POST /api/auth/reset-password</summary>
    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ApiResponse.Fail("Dữ liệu không hợp lệ."));

        await _auth.ResetPasswordAsync(dto);
        return Ok(ApiResponse.Success<object?>(null, "Đổi mật khẩu thành công."));
    }
}
