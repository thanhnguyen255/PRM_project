using backend.BLL.DTOs.Review;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/review-sessions")]
[Authorize]
public class ReviewSessionController : BaseController
{
    private readonly IReviewService _reviewService;

    public ReviewSessionController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    [HttpGet]
    public async Task<IActionResult> GetSessions([FromQuery] int classId)
    {
        var sessions = await _reviewService.GetSessionsByClassAsync(classId);
        return Ok(ApiResponse.Success(sessions));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetSession(int id)
    {
        var session = await _reviewService.GetSessionByIdAsync(id);
        if (session == null) return NotFound(ApiResponse.Fail("Không tìm thấy phiên đánh giá chéo."));
        return Ok(ApiResponse.Success(session));
    }

    [HttpPost]
    public async Task<IActionResult> CreateSession(CreateReviewSessionDto dto)
    {
        var session = await _reviewService.CreateSessionAsync(dto);
        return StatusCode(201, ApiResponse.Success(session, "Session created"));
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteSession(int id)
    {
        var result = await _reviewService.DeleteSessionAsync(id);
        if (!result) return NotFound(ApiResponse.Fail("Không tìm thấy phiên đánh giá chéo để xóa."));
        return Ok(ApiResponse.Success<object?>(null));
    }

    [HttpGet("{id}/monitor")]
    public async Task<IActionResult> GetMonitor(int id)
    {
        var monitor = await _reviewService.GetReviewMonitorAsync(id);
        return Ok(ApiResponse.Success(monitor));
    }
}
