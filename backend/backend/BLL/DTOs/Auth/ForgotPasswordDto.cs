using System.ComponentModel.DataAnnotations;

namespace backend.BLL.DTOs.Auth;

public class ForgotPasswordDto
{
    [Required(ErrorMessage = "Vui lòng nhập email.")]
    [EmailAddress(ErrorMessage = "Vui lòng nhập email hợp lệ.")]
    public string Email { get; set; } = string.Empty;
}
