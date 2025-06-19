using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using zaMene.Model;
using zaMene.Model.SearchObjects;


namespace zaMene.Services
{
    public class PropertyService : BaseCRUDService<Property, PropertySearchObject, Property, PropertyDto, PropertyUpdateDto>, IPropertyService
    {
        private readonly AppDbContext _context;

        public PropertyService(AppDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        public override IQueryable<Property> AddFilter(PropertySearchObject search, IQueryable<Property> query)
        {
            if (!string.IsNullOrWhiteSpace(search.Title))
                query = query.Where(p => p.Title.Contains(search.Title));

            if (!string.IsNullOrWhiteSpace(search.City))
                query = query.Where(p => p.City.Contains(search.City));

            return base.AddFilter(search, query);
        }

        public override void BeforeInsert(PropertyDto request, Property entity)
        {
            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(PropertyUpdateDto request, Property entity)
        {
            base.BeforeUpdate(request, entity);
        }

        public async Task<IEnumerable<object>> GetAllWithImagesAsync()
        {
            var properties = await _context.Properties
                .Include(p => p.Images)
                .ToListAsync();

            return properties.Select(p => new
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
        }

        public async Task<double> GetAverageRating(int propertyId)
        {
            var property = await _context.Properties
                .Include(p => p.Reviews)
                .FirstOrDefaultAsync(p => p.PropertyID == propertyId);

            if (property == null || !property.Reviews.Any())
                return 0;

            return property.Reviews.Average(r => r.Rating);
        }

        public async Task<object> CreatePropertyWithImagesAsync(PropertyCreateRequest request)
        {
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
            await _context.SaveChangesAsync();

            var uploadPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images/properties");
            if (!Directory.Exists(uploadPath))
                Directory.CreateDirectory(uploadPath);

            var savedImageUrls = new List<string>();

            foreach (var file in request.Images)
            {
                if (file != null && file.Length > 0)
                {
                    var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                    if (extension != ".jpg" && extension != ".jpeg" && extension != ".png")
                        throw new Exception("Dozvoljeni su samo .jpg, .jpeg i .png formati slika.");

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

            await _context.SaveChangesAsync();

            return new
            {
                property.PropertyID,
                property.Title,
                Slike = savedImageUrls,
                message = "Nekretnina uspješno kreirana sa slikama."
            };
        }



        public async Task<object> AddImagesToPropertyAsync(int propertyId, List<IFormFile> images)
        {
            var property = await _context.Properties.FindAsync(propertyId);
            if (property == null)
                throw new Exception($"Nekretnina s ID-jem {propertyId} nije pronađena.");

            var uploadPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images/properties");
            if (!Directory.Exists(uploadPath))
                Directory.CreateDirectory(uploadPath);

            var savedImageUrls = new List<string>();

            foreach (var file in images)
            {
                if (file != null && file.Length > 0)
                {
                    var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                    if (extension != ".jpg" && extension != ".jpeg" && extension != ".png")
                        throw new Exception("Dozvoljeni su samo .jpg, .jpeg i .png formati slika.");

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

            await _context.SaveChangesAsync();

            return new
            {
                property.PropertyID,
                noveSlike = savedImageUrls,
                message = "Slike su uspješno dodane postojećoj nekretnini."
            };
        }

        public async Task<bool> DeletePropertyAsync(int propertyId)
        {
            var property = await _context.Properties
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.PropertyID == propertyId);

            if(property == null)
            {
                throw new Exception("Nekretnina nije pronadjena");
            }

            foreach(var image in property.Images)
            {
                var imagePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", image.ImageUrl.TrimStart('/'));
                if(File.Exists(imagePath))
                {
                    File.Delete(imagePath);
                }
               
            }
            _context.PropertyImages.RemoveRange(property.Images);
            _context.Properties.Remove(property);

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<object> GetPropertyDetails(int propertyId)
        {
            var property = await _context.Properties
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.PropertyID == propertyId);

            if (property == null)
                throw new Exception($"Nekretnina s ID-jem {propertyId} nije pronađena.");

            return new
            {
                property.PropertyID,
                property.Title,
                property.Description,
                property.Price,
                property.City,
                property.Country,
                property.Address,
                property.AgentID,
                property.RoomCount,
                property.Area,
                imageUrls = property.Images.Select(i => "http://10.0.2.2:5283" + i.ImageUrl).ToList()
            };
        }

        public async Task<object> UpdatePropertyAsync(int propertyId, UpdatePropertyRequestDto request)
        {
            var property = await _context.Properties
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.PropertyID == propertyId);

            if (property == null)
                throw new Exception($"Nekretnina s ID-jem {propertyId} nije pronađena.");

            property.Title = request.Title;
            property.Description = request.Description;
            property.Price = request.Price;
            property.City = request.City;
            property.Country = request.Country;
            property.Address = request.Address;
            property.RoomCount = request.RoomCount;
            property.Area = request.Area;

            await _context.SaveChangesAsync();

            return new
            {
                message = "Nekretnina je uspješno ažurirana.",
                property.PropertyID
            };
        }
    }
}
