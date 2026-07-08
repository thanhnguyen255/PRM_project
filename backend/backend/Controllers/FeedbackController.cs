using backend.BLL.DTOs.Review;
using backend.BLL.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/feedbacks")]
public class FeedbackController : ControllerBase
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
    public async Task<ActionResult<FeedbackDto>> SubmitFeedback(CreateFeedbackDto dto)
    {
        try
        {
            var feedback = await _reviewService.SubmitFeedbackAsync(dto, CurrentUserId);
            return Ok(feedback);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ex.Message);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid(ex.Message);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ex.Message);
        }
    }

    [HttpGet("received")]
    public async Task<ActionResult<IEnumerable<FeedbackDto>>> GetReceivedFeedback([FromQuery] int sessionId)
    {
        var feedbacks = await _reviewService.GetReceivedFeedbackAsync(sessionId, CurrentUserId);
        return Ok(feedbacks);
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<FeedbackDto>>> GetAllFeedbacks([FromQuery] int sessionId)
    {
        var feedbacks = await _reviewService.GetAllFeedbacksInSessionAsync(sessionId);
        return Ok(feedbacks);
    }
}
