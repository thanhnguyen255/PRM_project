using backend.BLL.DTOs.User;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/profile")]
[Authorize]
public class ProfileController : BaseController
{
    private readonly IProfileService _service;

    public ProfileController(IProfileService service)
    {
        _service = service;
    }

    /// <summary>GET /api/profile — Lấy thông tin người dùng hiện tại</summary>
    [HttpGet]
    public async Task<IActionResult> GetProfile()
    {
        var result = await _service.GetProfileAsync(GetCurrentUserId());
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>PUT /api/profile — Cập nhật thông tin cá nhân</summary>
    [HttpPut]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ApiResponse.Fail("Dữ liệu không hợp lệ."));

        var result = await _service.UpdateProfileAsync(GetCurrentUserId(), dto);
        return Ok(ApiResponse.Success(result));
    }
}
