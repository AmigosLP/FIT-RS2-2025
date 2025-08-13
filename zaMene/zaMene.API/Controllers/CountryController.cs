using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using zaMene.Model;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Services.Interfaces;

namespace zaMene.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CountryController : BaseCRUDController<Country, CountrySearchObject, CountryDto, CountryUpdateDto>
    {
        public CountryController(ICountryService service) : base(service)
        {
        }
    }
}
