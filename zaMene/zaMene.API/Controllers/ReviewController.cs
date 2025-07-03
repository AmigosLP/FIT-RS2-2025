using Microsoft.AspNetCore.Mvc;
using zaMene.API.Controllers;
using zaMene.Model.SearchObjects;
using RabbitMQ.Client;
using zaMene.Model.Entity;
using zaMene.Model.ViewModel;
using zaMene.Services.Interface;
using Microsoft.AspNetCore.Authorization;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ReviewController : BaseCRUDController<Review, ReviewSearchObject, ReviewDto, ReviewUpdateDto>
{
    private readonly IReviewService _reviewService;
    public ReviewController(IReviewService reviewService) : base(reviewService)
    {
        _reviewService = reviewService;
    }

    [Authorize(AuthenticationSchemes = "Bearer")]
    [HttpPost("Create")]
    public async Task<IActionResult> CreateReview([FromBody] ReviewCreateDto request)
    {
        try
        {
            var review = await _reviewService.CreateReview(request);
            return Ok(review);
        } 
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [Authorize(AuthenticationSchemes = "Bearer")]
    [HttpGet("ByProperty/{propertyId}")]
    public async Task<IActionResult> GetReviewsByProperty(int propertyId)
    {
        var result = await _reviewService.GetReviewsByPropertyId(propertyId);
        return Ok(result);
    }

    [Authorize(AuthenticationSchemes = "Bearer")]
    [HttpGet("GetAll")]
    public async Task<IActionResult> GetAll()
    {
        var result = await _reviewService.GetAllReview();
        return Ok(result);
    }

    [Authorize(AuthenticationSchemes = "Bearer")]
    [HttpPut("Update/{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] ReviewUpdateDto dto)
    {
        try
        {
            var result = await _reviewService.UpdateReview(id, dto);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [Authorize(AuthenticationSchemes = "Bearer")]
    [HttpDelete("Delete/{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        try
        {
            var success = await _reviewService.DeleteReview(id);

            if (!success)
                return NotFound(new { message = "Recenzija nije pronađena." });

            return Ok(new { message = "Recenzija uspješno obrisana." });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = $"Greška prilikom brisanja: {ex.Message}" });
        }
    }

}
