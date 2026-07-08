using backend.BLL.DTOs.Review;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/review-sessions")]
public class ReviewSessionController : ControllerBase
{
    private readonly IReviewService _reviewService;

    public ReviewSessionController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ReviewSessionDto>>> GetSessions([FromQuery] int classId)
    {
        var sessions = await _reviewService.GetSessionsByClassAsync(classId);
        return Ok(sessions);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ReviewSessionDto>> GetSession(int id)
    {
        var session = await _reviewService.GetSessionByIdAsync(id);
        if (session == null) return NotFound("Không tìm thấy phiên đánh giá chéo.");
        return Ok(session);
    }

    [HttpPost]
    public async Task<ActionResult<ReviewSessionDto>> CreateSession(CreateReviewSessionDto dto)
    {
        var session = await _reviewService.CreateSessionAsync(dto);
        return CreatedAtAction(nameof(GetSession), new { id = session.Id }, session);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteSession(int id)
    {
        var result = await _reviewService.DeleteSessionAsync(id);
        if (!result) return NotFound("Không tìm thấy phiên đánh giá chéo để xóa.");
        return NoContent();
    }

    [HttpGet("{id}/monitor")]
    public async Task<ActionResult<IEnumerable<ReviewMonitorDto>>> GetMonitor(int id)
    {
        var monitor = await _reviewService.GetReviewMonitorAsync(id);
        return Ok(monitor);
    }
}
