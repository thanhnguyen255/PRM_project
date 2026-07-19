using System.ComponentModel.DataAnnotations;

namespace backend.BLL.DTOs.Auth;

public class VerifyOtpDto
{
    [Required(ErrorMessage = "Email không được để trống")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Mã OTP không được để trống")]
    [StringLength(6, MinimumLength = 6, ErrorMessage = "Mã OTP phải có 6 ký tự")]
    public string Otp { get; set; } = string.Empty;
}
