using zaMene.Model;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Services.Interfaces;
using MapsterMapper;
using zaMene.Model.Entity;

namespace zaMene.Services.Service
{
    public class CountryService : BaseCRUDService<Country, CountrySearchObject, Country, CountryDto, CountryUpdateDto>, ICountryService
    {
        public CountryService(AppDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Country> AddFilter(CountrySearchObject search, IQueryable<Country> query)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(c => c.Name.ToLower().Contains(search.Name.ToLower()));
            }

            return base.AddFilter(search, query);
        }
    }
}
