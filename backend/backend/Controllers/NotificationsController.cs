using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[Route("api/notifications")]
[Authorize]
public class NotificationsController : BaseController
{
    private readonly INotificationService _service;

    public NotificationsController(INotificationService service)
    {
        _service = service;
    }

    /// <summary>GET /api/notifications?page=1&amp;pageSize=20 — Danh sách thông báo</summary>
    [HttpGet]
    public async Task<IActionResult> GetList([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        if (page < 1) page = 1;
        if (pageSize < 1 || pageSize > 100) pageSize = 20;

        var result = await _service.GetListAsync(GetCurrentUserId(), page, pageSize);
        return Ok(ApiResponse.Success(result));
    }

    /// <summary>GET /api/notifications/unread-count — Số thông báo chưa đọc</summary>
    [HttpGet("unread-count")]
    public async Task<IActionResult> GetUnreadCount()
    {
        var count = await _service.GetUnreadCountAsync(GetCurrentUserId());
        return Ok(ApiResponse.Success(new { count }));
    }

    /// <summary>PUT /api/notifications/read-all — Đánh dấu tất cả đã đọc</summary>
    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllRead()
    {
        await _service.MarkAllReadAsync(GetCurrentUserId());
        return NoContent();
    }

    /// <summary>PUT /api/notifications/{id}/read — Đánh dấu 1 thông báo đã đọc</summary>
    [HttpPut("{id:int}/read")]
    public async Task<IActionResult> MarkRead(int id)
    {
        await _service.MarkReadAsync(id, GetCurrentUserId());
        return NoContent();
    }
}
