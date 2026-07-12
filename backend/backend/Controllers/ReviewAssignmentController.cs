using backend.BLL.DTOs.Review;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/review-assignments")]
public class ReviewAssignmentController : BaseController
{
    private readonly IReviewService _reviewService;

    public ReviewAssignmentController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAssignments([FromQuery] int sessionId, [FromQuery] int? reviewerId)
    {
        if (!reviewerId.HasValue && Request.Headers.TryGetValue("X-User-Id", out var val) && int.TryParse(val, out var id))
        {
            reviewerId = id;
        }

        var assignments = await _reviewService.GetAssignmentsAsync(sessionId, reviewerId);
        return Ok(ApiResponse.Success(assignments));
    }
}
