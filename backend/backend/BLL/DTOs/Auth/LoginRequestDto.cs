using System.ComponentModel.DataAnnotations;

namespace backend.BLL.DTOs.Auth;

public class LoginRequestDto
{
    [Required(ErrorMessage = "Vui lòng nhập email.")]
    [EmailAddress(ErrorMessage = "Vui lòng nhập email hợp lệ.")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Vui lòng nhập mật khẩu.")]
    public string Password { get; set; } = string.Empty;
}
