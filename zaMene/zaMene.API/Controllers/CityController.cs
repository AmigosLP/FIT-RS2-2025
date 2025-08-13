using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModel;
using zaMene.Model.ViewModels;
using zaMene.Services.Interface;
using zaMene.Services.Interfaces;

namespace zaMene.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CityController : BaseCRUDController<City, CitySearchObject, CityDto, CityUpdateDto>
    {
        public CityController(ICityService service) : base(service)
        {

        }
    }
}
