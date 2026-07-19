using System.ComponentModel.DataAnnotations;

namespace backend.BLL.DTOs.Auth;

public class ResetPasswordDto
{
    [Required(ErrorMessage = "Email không được để trống")]
    [EmailAddress(ErrorMessage = "Email không hợp lệ")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Mật khẩu mới không được để trống")]
    [MinLength(6, ErrorMessage = "Mật khẩu phải có ít nhất 6 ký tự")]
    public string NewPassword { get; set; } = string.Empty;
    
    [Required(ErrorMessage = "Mã xác thực không được để trống")]
    public string ResetToken { get; set; } = string.Empty;
}
