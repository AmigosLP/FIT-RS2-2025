using MapsterMapper;
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

        public async Task<double> GetAverageRating(int propertyId)
        {
            var property = await _context.Properties
                .Include(p => p.Reviews)
                .FirstOrDefaultAsync(p => p.PropertyID == propertyId);

            if (property == null || !property.Reviews.Any())
                return 0;

            return property.Reviews.Average(r => r.Rating);
        }

        public async Task<List<PropertyDto>> GetAllWithImagesAsync()
        {
            var properties = await _context.Properties.ToListAsync();
            var result = new List<PropertyDto>();

            foreach (var property in properties)
            {
                var dto = new PropertyDto
                {
                    Title = property.Title,
                    Description = property.Description,
                    Price = property.Price,
                    Address = property.Address,
                    City = property.City,
                    Country = property.Country,
                    AgentID = property.AgentID,
                    RoomCount = property.RoomCount,
                    Area = property.Area,
                
                    // Dodaj druge potrebne propertije
                };

                dto.ImageUrls = await _context.PropertyImages
                    .Where(x => x.PropertyID == property.PropertyID)
                    .Select(x => "http://localhost:5283" + x.ImageUrl)
                    .ToListAsync();

                result.Add(dto);
            }

            return result;
        }


    }
}
