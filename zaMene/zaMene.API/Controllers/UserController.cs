using Microsoft.AspNetCore.Mvc;
using zaMene.Model;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using zaMene.Services;
using zaMene.Model.SearchObjects;
using Microsoft.AspNetCore.Authorization;

namespace zaMene.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : BaseCRUDController<Model.User, UserSearchObject, UserDTO, UserUpdateDto>
    {
        public UsersController(IUserService userService) : base(userService) {}

        [HttpPost("login")]
        [AllowAnonymous]
        public Model.User Login(string username, string password)
        {
            return (_service as IUserService).Login(username, password);
        }
    }
}
