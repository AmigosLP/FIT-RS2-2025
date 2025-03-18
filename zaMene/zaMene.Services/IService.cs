using System;
using System.Collections.Generic;
using System.Linq;
using zaMene.Model;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model.SearchObjects;

namespace zaMene.Services
{
    public interface IService<TModel, TSearch> where TSearch : BaseSearchObject
    {
        public PagedResult<TModel> GetPaged(TSearch search);
        public TModel GetById(int id);
    }
}
