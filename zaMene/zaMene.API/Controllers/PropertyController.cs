using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RabbitMQ.Client;
using zaMene.Model;
using zaMene.Model.SearchObjects;
using zaMene.Services;

namespace zaMene.API.Controllers
{

    [ApiController]
    [Route("api/[controller]")]
    [Authorize]

    public class PropertyController : BaseCRUDController<Property, PropertySearchObject, PropertyDto, PropertyUpdateDto>
    {
        private readonly IPropertyService _propertyService;
        private readonly AppDbContext _context;
        public PropertyController(IPropertyService propertyService, AppDbContext context) : base(propertyService)
        {
            _propertyService = propertyService;
            _context = context;
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpGet("with-images")]
        public async Task<IActionResult> GetAllWithImages()
        {
            var result = await _propertyService.GetAllWithImagesAsync();
            return Ok(result);
        }

        [HttpGet("{id}/average-rating")]
        public async Task<IActionResult> GetAverageRating(int id)
        {
            var avg = await _propertyService.GetAverageRating(id);
            return Ok(avg);
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpPost("create-with-images")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> CreateWithImages([FromForm] PropertyCreateRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                var result = await _propertyService.CreatePropertyWithImagesAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpPost("{id}/add-images")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> AddImagesToProperty(int id, [FromForm] List<IFormFile> images)
        {
            try
            {
                var result = await _propertyService.AddImagesToPropertyAsync(id, images);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var success = await _propertyService.DeletePropertyAsync(id);
                if (success)
                    return Ok(new { message = "Nekretnina uspješno obrisana." });
                else
                    return NotFound();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpGet("Details/{id}")]
        public async Task<IActionResult> GetPropertyDetails(int id)
        {
            try
            {
                var result = await _propertyService.GetPropertyDetails(id);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpPut("update/{propertyId}")]
        public async Task<IActionResult> UpdatePropertyAsync(int propertyId, UpdatePropertyRequestDto request)
        {
            try
            {
                var result = await _propertyService.UpdatePropertyAsync(propertyId, request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
