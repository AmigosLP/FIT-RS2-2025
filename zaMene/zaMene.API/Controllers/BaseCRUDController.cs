using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using zaMene.Model.SearchObjects;
using zaMene.Services.Interface;

namespace zaMene.API.Controllers
{
    public class BaseCRUDController<TModel, TSearch, TInsert, TUpdate> : BaseController<TModel, TSearch> where TSearch : BaseSearchObject where TModel : class
    {
        public new ICRUDService<TModel, TSearch, TInsert, TUpdate> _service;
        public BaseCRUDController(ICRUDService<TModel, TSearch, TInsert, TUpdate> service) : base(service)
        {
            _service = service;
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpPost]
        public virtual TModel Insert(TInsert request)
        {
            return _service.Insert(request);
        }

        [HttpPut("{id}")]
        public virtual TModel Update(int id, TUpdate request)
        {
            return _service.Update(id, request);
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _service.Delete(id);
            return NoContent();
        }
    }
}
