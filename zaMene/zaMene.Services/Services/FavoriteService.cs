using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Model;
using zaMene.Services.Interfaces;
using zaMene.Services.Service;

namespace zaMene.Services.Services
{
    public class FavoriteService : BaseCRUDService<Favorite, FavoriteSearchObject, Favorite, FavoriteDto, FavoriteUpdateDto>, IFavoriteService
    {
        public FavoriteService(AppDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Favorite> AddFilter(FavoriteSearchObject search, IQueryable<Favorite> query)
        {
            if (search.UserID.HasValue)
                query = query.Where(f => f.UserID == search.UserID);

            if (search.PropertyID.HasValue)
                query = query.Where(f => f.PropertyID == search.PropertyID);

            return base.AddFilter(search, query);
        }

        public override void BeforeInsert(FavoriteDto request, Favorite entity)
        {
            bool exists = _context.Favorite.Any(f => f.UserID == request.UserID && f.PropertyID == request.PropertyID);

            if (exists)
                throw new Exception("Vec je oznaceno kao favorit.");

            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(FavoriteUpdateDto request, Favorite entity)
        {
            base.BeforeUpdate(request, entity);
        }

        public IEnumerable<Favorite> Search(FavoriteSearchObject search)
        {
            var set = _context.Set<Favorite>().AsQueryable();
            set = AddFilter(search, set);
            return set.ToList();
        }
    }
}
