using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model;
using zaMene.Model.SearchObjects;

namespace zaMene.Services
{
    public abstract class BaseService<TModel, TSearch, TDbEntity> : IService<TModel, TSearch> where TSearch: BaseSearchObject where TDbEntity : class where TModel : class
    {
        protected readonly AppDbContext _context;
        public IMapper Mapper { get; set; }
        public BaseService(AppDbContext context, IMapper mapper)
        {
            _context = context;
            Mapper = mapper;
        }

        public PagedResult<TModel> GetPaged(TSearch search)
        {

            List<TModel> result = new List<TModel>();

            var query = _context.Set<TDbEntity>().AsQueryable();
            query = AddFilter(search, query);


            int count = query.Count();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = query.ToList();
            result = Mapper.Map(list, result);

            PagedResult<TModel> PagedResult = new PagedResult<TModel>();
            PagedResult.ResultList = result;

            PagedResult.ResultList = result;
            PagedResult.Count = count;

            return PagedResult;
        }
        
        public virtual IQueryable<TDbEntity> AddFilter(TSearch search, IQueryable<TDbEntity> query)
        {
            return query;
        }

        public TModel GetById(int id)
        {
            var entity = _context.Set<TDbEntity>().Find(id);
            if (entity != null)
            {
                return Mapper.Map<TModel>(entity);
            }
            else
            {
                return null;
            }

        }
    }
}
