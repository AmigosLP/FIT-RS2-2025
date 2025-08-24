using Mapster;
using Mapster.Models;
using MapsterMapper;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Trainers;
using zaMene.Model;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModel;
using zaMene.Services.Interface;

namespace zaMene.Services.Service
{
    public class PropertyService : BaseCRUDService<Property, PropertySearchObject, Property, PropertyDto, PropertyUpdateDto>, IPropertyService
    {
        private readonly AppDbContext _context;
        static MLContext mlContext = null;
        static object isLocked = new object();
        static ITransformer model = null;
        private readonly IWebHostEnvironment _env;
        private readonly IHttpContextAccessor _http;

        public PropertyService(AppDbContext context, IMapper mapper, IWebHostEnvironment env, IHttpContextAccessor http)
            : base(context, mapper)
        {
            _context = context;
            _env = env;
            _http = http;
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
                .Include(p => p.Agent)
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
                imageUrls = p.Images.Select(i => MakeAbsolute(i.ImageUrl)).ToList(),
                images = p.Images.Select(i => new
                {
                    id = i.PropertyImageID,
                    url = MakeAbsolute(i.ImageUrl)
                }).ToList(),
                AgentFullName = p.Agent != null ? $"{p.Agent.FirstName} {p.Agent.LastName}" : null,
                AgentPhoneNumber = p.Agent?.Phone
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

            if (request.Images != null)
            {
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

                        var relUrl = $"/images/properties/{uniqueFileName}";
                        savedImageUrls.Add(MakeAbsolute(relUrl));

                        _context.PropertyImages.Add(new PropertyImage
                        {
                            PropertyID = property.PropertyID,
                            ImageUrl = relUrl
                        });
                    }
                }
            }

            await _context.SaveChangesAsync();

            return new
            {
                property.PropertyID,
                property.Title,
                imageUrls = savedImageUrls,
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

                    var relUrl = $"/images/properties/{uniqueFileName}";
                    savedImageUrls.Add(MakeAbsolute(relUrl));

                    _context.PropertyImages.Add(new PropertyImage
                    {
                        PropertyID = property.PropertyID,
                        ImageUrl = relUrl
                    });
                }
            }

            await _context.SaveChangesAsync();

            return new
            {
                property.PropertyID,
                imageUrls = savedImageUrls,
                message = "Slike su uspješno dodane postojećoj nekretnini."
            };
        }

        public async Task<bool> DeletePropertyAsync(int propertyId)
        {
            var property = await _context.Properties
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.PropertyID == propertyId);

            if (property == null)
            {
                throw new Exception("Nekretnina nije pronadjena");
            }

            foreach (var image in property.Images)
            {
                var imagePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", image.ImageUrl.TrimStart('/'));
                if (File.Exists(imagePath))
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
                .Include(p => p.Agent)
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
                imageUrls = property.Images.Select(i => MakeAbsolute(i.ImageUrl)).ToList(),
                images = property.Images.Select(i => new
                {
                    id = i.PropertyImageID,
                    url = MakeAbsolute(i.ImageUrl)
                }).ToList(),
                AgentFullName = property.Agent != null ? $"{property.Agent.FirstName} {property.Agent.LastName}" : null,
                AgentImageUrl = property.Agent?.ProfileImagePath,
                AgentPhoneNumber = property.Agent?.Phone
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

            if (request.DeleteImageIds != null && request.DeleteImageIds.Any())
            {
                var slikeZaBrisati = property.Images
                    .Where(img => request.DeleteImageIds.Contains(img.PropertyImageID))
                    .ToList();

                foreach (var slika in slikeZaBrisati)
                {
                    var abs = ToAbsolutePath(slika.ImageUrl);
                    if (System.IO.File.Exists(abs))
                    {
                        try { System.IO.File.Delete(abs); } catch { /* log */ }
                    }
                    _context.PropertyImages.Remove(slika);
                }
            }

            if (request.NewImages != null && request.NewImages.Any())
            {
                foreach (var image in request.NewImages)
                {
                    var fileName = $"{Guid.NewGuid()}_{Path.GetFileName(image.FileName)}";
                    var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/images/properties");

                    if (!Directory.Exists(uploadsFolder))
                        Directory.CreateDirectory(uploadsFolder);

                    var filePath = Path.Combine(uploadsFolder, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await image.CopyToAsync(stream);
                    }

                    var newImage = new PropertyImage
                    {
                        PropertyID = property.PropertyID,
                        ImageUrl = $"/images/properties/{fileName}"
                    };

                    _context.PropertyImages.Add(newImage);
                }
            }

            await _context.SaveChangesAsync();

            return new
            {
                message = "Nekretnina je uspješno ažurirana.",
                property.PropertyID
            };
        }

        public async Task<List<PropertyStatisticsDto>> GetPropertyStatistics()
        {
            var properties = await _context.Properties
                .Include(p => p.Reservations)
                .Include(p => p.Reviews)
                .ToListAsync();

            var stats = properties.Select(p => new PropertyStatisticsDto
            {
                PropertyID = p.PropertyID,
                Title = p.Title,
                City = p.City,
                TotalReservation = p.Reservations.Count,
                AverageRating = p.Reviews.Any() ? p.Reviews.Average(r => r.Rating) : 0,
                ViewCount = p.viewCount,
                IsTopProperty = p.isTopProperty
            }).ToList();

            return stats;
        }

        public List<PropertyDto> GetRecommendedProperties(int userId)
        {
            lock (isLocked)
            {
                if (mlContext == null)
                {
                    mlContext = new MLContext();

                    var rentals = _context.Reservations
                        .Where(r => r.UserID != null)
                        .ToList();

                    var data = rentals.Select(r => new PropertyRecommendationEntry
                    {
                        UserID = (uint)r.UserID,
                        PropertyID = (uint)r.PropertyID,
                        Label = 1
                    }).ToList();

                    if (!data.Any())
                        return new List<PropertyDto>();

                    var trainData = mlContext.Data.LoadFromEnumerable(data);

                    var options = new MatrixFactorizationTrainer.Options
                    {
                        MatrixColumnIndexColumnName = nameof(PropertyRecommendationEntry.UserID),
                        MatrixRowIndexColumnName = nameof(PropertyRecommendationEntry.PropertyID),
                        LabelColumnName = nameof(PropertyRecommendationEntry.Label),
                        LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                        Alpha = 0.01,
                        Lambda = 0.025,
                        NumberOfIterations = 100,
                        C = 0.00001
                    };

                    var est = mlContext.Recommendation().Trainers.MatrixFactorization(options);
                    model = est.Fit(trainData);
                }

                if (model == null)
                    return new List<PropertyDto>();

                var properties = _context.Properties.ToList();
                var predictionEngine = mlContext.Model.CreatePredictionEngine<PropertyRecommendationEntry, PropertyRecommendationPrediction>(model);

                var predictions = properties.Select(p => new
                {
                    Property = p,
                    predictionEngine.Predict(new PropertyRecommendationEntry
                    {
                        UserID = (uint)userId,
                        PropertyID = (uint)p.PropertyID
                    }).Score
                })
                .OrderByDescending(x => x.Score)
                .Take(5)
                .Select(x => x.Property)
                .ToList();

                return predictions.Adapt<List<PropertyDto>>();
            }
        }

        public List<PropertyDto> GetContentBasedRecommendations(int userId)
        {
            var userPropertyIds = _context.Reservations
                .Where(r => r.UserID == userId)
                .Select(r => r.PropertyID)
                .ToList();

            if (!userPropertyIds.Any())
            {
                var fallbackProperties = _context.Properties
                    .Include(p => p.Images)
                    .Include(p => p.Agent)
                    .OrderBy(p => p.Price)
                    .Take(5)
                    .ToList();

                return MapPropertiesToDto(fallbackProperties);
            }

            var userProperties = _context.Properties
                .Where(p => userPropertyIds.Contains(p.PropertyID))
                .ToList();

            var avgRooms = userProperties.Average(p => p.RoomCount);
            var avgPrice = userProperties.Average(p => p.Price);
            var avgArea = userProperties.Average(p => p.Area);
            var commonCities = userProperties
                .GroupBy(p => p.City)
                .OrderByDescending(g => g.Count())
                .Select(g => g.Key)
                .Take(2)
                .ToList();

            var recommendedProperties = _context.Properties
                .Include(p => p.Images)
                .Include(p => p.Agent)
                .Where(p =>
                    !userPropertyIds.Contains(p.PropertyID) &&
                    p.RoomCount >= avgRooms - 1 && p.RoomCount <= avgRooms + 1 &&
                    p.Price >= avgPrice * 0.7m && p.Price <= avgPrice * 1.3m &&
                    p.Area >= avgArea * 0.8m && p.Area <= avgArea * 1.2m &&
                    commonCities.Contains(p.City))
                .Take(10)
                .ToList();

            return MapPropertiesToDto(recommendedProperties);
        }

        public async Task<(string message, List<PropertyDto> properties)> GetHomepageRecommendations(int userId)
        {
            var recommendations = GetContentBasedRecommendations(userId);

            if (recommendations == null || !recommendations.Any())
            {
                var fallback = await _context.Properties
                    .Include(p => p.Images)
                    .Include(p => p.Agent)
                    .OrderBy(p => p.Price)
                    .Take(5)
                    .ToListAsync();

                return ("Preporučujemo ove povoljne stanove", MapPropertiesToDto(fallback));
            }
            else
            {
                return ("Slične i najbolje ponude za vas!", recommendations);
            }
        }

        private List<PropertyDto> MapPropertiesToDto(List<Property> properties)
        {
            return properties.Select(p => new PropertyDto
            {
                PropertyID = p.PropertyID,
                Title = p.Title,
                Description = p.Description,
                Price = p.Price,
                City = p.City,
                Country = p.Country,
                Address = p.Address,
                AgentID = p.AgentID,
                RoomCount = p.RoomCount,
                Area = p.Area,
                AverageRating = p.Reviews.Any() ? p.Reviews.Average(r => r.Rating) : 0,
                AgentFullName = p.Agent != null ? p.Agent.FirstName + " " + p.Agent.LastName : null,
                AgentPhoneNumber = p.Agent != null ? p.Agent.Phone : null,
                AgentProfileImageUrl = p.Agent?.ProfileImagePath,
                ImageUrls = p.Images.Select(i => MakeAbsolute(i.ImageUrl)).ToList()
            }).ToList();
        }

        private string ToAbsolutePath(string webPath)
        {
            var rel = (webPath ?? "").Replace('\\', '/');
            if (rel.StartsWith("/")) rel = rel.Substring(1);
            var root = _env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
            return Path.Combine(root, rel);
        }

        private string MakeAbsolute(string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return url ?? "";
            var normalized = url.Replace('\\', '/');
            if (normalized.StartsWith("http", StringComparison.OrdinalIgnoreCase)) return normalized;

            var req = _http.HttpContext?.Request;
            var baseUrl = $"{req?.Scheme}://{req?.Host.Value}";
            if (!normalized.StartsWith("/")) normalized = "/" + normalized;
            return baseUrl + normalized;
        }
    }
}
