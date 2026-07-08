using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

/// <summary>
/// Base controller cung cấp GetCurrentUserId() helper dùng chung.
/// </summary>
[ApiController]
public abstract class BaseController : ControllerBase
{
    protected int GetCurrentUserId()
    {
        var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (claim == null)
            throw new UnauthorizedAccessException("Token không hợp lệ.");
        return int.Parse(claim);
    }

    protected string GetCurrentUserRole()
    {
        return User.FindFirstValue(ClaimTypes.Role) ?? string.Empty;
    }
}
