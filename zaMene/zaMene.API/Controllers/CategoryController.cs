using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModel;
using zaMene.Model.ViewModels;
using zaMene.Services.Interfaces;

namespace zaMene.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CategoryController : BaseCRUDController<Category, CategorySearchObject, CategoryDto, CategoryUpdateDto>
    {
        public CategoryController(ICategoryService service) : base(service)
        {
        }
    }
}
