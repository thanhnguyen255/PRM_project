using backend.BLL.DTOs.Review;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/feedbacks")]
public class FeedbackController : BaseController
{
    private readonly IReviewService _reviewService;

    public FeedbackController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    private int CurrentUserId
    {
        get
        {
            if (Request.Headers.TryGetValue("X-User-Id", out var value) && int.TryParse(value, out var id))
            {
                return id;
            }
            return 3; // Default to learner1 for testing
        }
    }

    [HttpPost]
    public async Task<IActionResult> SubmitFeedback(CreateFeedbackDto dto)
    {
        try
        {
            var feedback = await _reviewService.SubmitFeedbackAsync(dto, CurrentUserId);
            return StatusCode(201, ApiResponse.Success(feedback, "Feedback created"));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse.Fail(ex.Message));
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(403, ApiResponse.Fail(ex.Message));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse.Fail(ex.Message));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse.Fail(ex.Message));
        }
    }

    [HttpGet("received")]
    public async Task<IActionResult> GetReceivedFeedback([FromQuery] int sessionId)
    {
        var feedbacks = await _reviewService.GetReceivedFeedbackAsync(sessionId, CurrentUserId);
        return Ok(ApiResponse.Success(feedbacks));
    }

    [HttpGet]
    public async Task<IActionResult> GetAllFeedbacks([FromQuery] int sessionId)
    {
        var feedbacks = await _reviewService.GetAllFeedbacksInSessionAsync(sessionId);
        return Ok(ApiResponse.Success(feedbacks));
    }
}
