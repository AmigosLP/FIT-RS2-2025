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

        [HttpGet("{id}/average-rating")]
        public async Task<IActionResult> GetAverageRating(int id)
        {
            var avg = await _propertyService.GetAverageRating(id);
            return Ok(avg);
        }

        [HttpPost("create-with-images")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> CreateWithImages([FromForm] PropertyCreateRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var property = new Property
            {
                Title = request.Title,
                Description = request.Description,
                Price = request.Price,
                Address = request.Address,
                City = request.City,
                Country = request.Country,
                AgentID = request.AgentID,
                RoomCount = request.RoomCount,
                Area = request.Area,
                PublisheDate = DateTime.UtcNow
            };

            _context.Properties.Add(property);
            await _context.SaveChangesAsync(); // kako bismo dobili PropertyID

            var uploadPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images/properties");
            if (!Directory.Exists(uploadPath))
                Directory.CreateDirectory(uploadPath);

            var savedImageUrls = new List<string>();

            foreach (var file in request.Images)
            {
                try
                {
                    if (file != null && file.Length > 0)
                    {
                        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                        if (extension != ".jpg" && extension != ".jpeg" && extension != ".png")
                            return BadRequest("Dozvoljeni su samo .jpg, .jpeg i .png formati slika.");

                        var uniqueFileName = Guid.NewGuid().ToString() + extension;
                        var filePath = Path.Combine(uploadPath, uniqueFileName);

                        using var stream = new FileStream(filePath, FileMode.Create);
                        await file.CopyToAsync(stream);

                        var imageUrl = $"/images/properties/{uniqueFileName}";
                        savedImageUrls.Add(imageUrl);

                        _context.PropertyImages.Add(new PropertyImage
                        {
                            PropertyID = property.PropertyID,
                            ImageUrl = imageUrl
                        });
                    }
                }
                catch (Exception ex)
                {
                    return StatusCode(500, new
                    {
                        error = $"Greška pri snimanju slike: {file.FileName}",
                        details = ex.Message
                    });
                }
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                property.PropertyID,
                property.Title,
                Slike = savedImageUrls,
                message = "Nekretnina uspješno kreirana sa slikama."
            });
        }

        [HttpGet("with-images")]
        public async Task<IActionResult> GetAllWithImages()
        {
            var properties = await _context.Properties
                .Include(p => p.Images)
                .ToListAsync();

            var result = properties.Select(p => new
            {
                p.PropertyID,
                p.Title,
                p.Description,
                p.Price,
                p.City,
                p.Country,
                p.Address,
                p.AgentID,
                p.RoomCount,
                p.Area,
                imageUrls = p.Images.Select(i => "http://10.0.2.2:5283" + i.ImageUrl).ToList()
            });

            return Ok(result);
        }

        [HttpPost("{id}/add-images")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> AddImagesToProperty(int id, List<IFormFile> images)
        {
            try
            {
                var property = await _context.Properties.FindAsync(id);
                if (property == null)
                    return NotFound($"Nekretnina s ID-jem {id} nije pronađena.");

                var uploadPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images/properties");

                // log
                Console.WriteLine($"[DEBUG] Upload path: {uploadPath}");

                if (!Directory.Exists(uploadPath))
                {
                    Console.WriteLine("[DEBUG] Directory ne postoji, kreiram...");
                    Directory.CreateDirectory(uploadPath);
                }

                var savedImageUrls = new List<string>();

                foreach (var file in images)
                {
                    if (file != null && file.Length > 0)
                    {
                        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                        if (extension != ".jpg" && extension != ".jpeg" && extension != ".png")
                            return BadRequest("Dozvoljeni su samo .jpg, .jpeg i .png formati slika.");

                        var uniqueFileName = Guid.NewGuid().ToString() + extension;
                        var filePath = Path.Combine(uploadPath, uniqueFileName);

                        Console.WriteLine($"[DEBUG] Snimam fajl na: {filePath}");

                        using var stream = new FileStream(filePath, FileMode.Create);
                        await file.CopyToAsync(stream);

                        var imageUrl = $"/images/properties/{uniqueFileName}";
                        savedImageUrls.Add(imageUrl);

                        _context.PropertyImages.Add(new PropertyImage
                        {
                            PropertyID = property.PropertyID,
                            ImageUrl = imageUrl
                        });
                    }
                }

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    property.PropertyID,
                    noveSlike = savedImageUrls,
                    message = "Slike su uspješno dodane postojećoj nekretnini."
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine("[ERROR] " + ex.Message);
                Console.WriteLine("[STACK] " + ex.StackTrace);
                return StatusCode(500, "Greška na serveru: " + ex.Message);
            }
        }

    }


}
