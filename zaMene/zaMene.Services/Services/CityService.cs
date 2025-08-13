using MapsterMapper;
using zaMene.Model;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModel;
using zaMene.Model.ViewModels;
using zaMene.Services.Interface;
using zaMene.Services.Interfaces;

namespace zaMene.Services.Service
{
    public class CityService : BaseCRUDService<City, CitySearchObject, City, CityDto, CityUpdateDto>, ICityService
    {
        public CityService(AppDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<City> AddFilter(CitySearchObject search, IQueryable<City> query)
        {
            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(c => c.Name.ToLower().Contains(search.Name.ToLower()));
            }

            return base.AddFilter(search, query);
        }

        public override void BeforeInsert(CityDto request, City entity)
        {
            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(CityUpdateDto request, City entity)
        {
            base.BeforeUpdate(request, entity);
        }
    }
}
