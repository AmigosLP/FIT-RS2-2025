using Microsoft.AspNetCore.Mvc;
using zaMene.Model;
using zaMene.Services;

namespace zaMene.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProductController : ControllerBase
    {
    
        protected IProductService _service;
        public ProductController(IProductService service)
        {
            _service = service;
        }

        [HttpGet]
        public List<Product> GetList()
        {
            return _service.GetList();
        }
    }
}
