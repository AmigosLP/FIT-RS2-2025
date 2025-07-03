using Microsoft.AspNetCore.Mvc;
using zaMene.Model;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using zaMene.Model.SearchObjects;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using EasyNetQ;
using zaMene.Model.Entity;
using zaMene.Model.ViewModel;
using zaMene.Services.Interface;

namespace zaMene.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UsersController : BaseCRUDController<User, UserSearchObject, UserDTO, UserUpdateDto>
    {
        private readonly IUserService _userService;
        private readonly AppDbContext _context;
        public UsersController(IUserService userService, AppDbContext context) : base(userService)
        {
            _userService = userService;
            _context = context;
        }

        [AllowAnonymous]
        [HttpPost("Login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (request == null)
                return BadRequest(new { Message = "Invalid request data" });

            var token = await _userService.Login(request.Username, request.Password);

            if (token == null)
                return Unauthorized(new { Message = "Invalid username or password" });

            var user = await _context.Users
                .Include(x => x.UserRoles).ThenInclude(y => y.Role)
                .FirstOrDefaultAsync(x => x.Username == request.Username);

            if (user == null)
                return BadRequest(new { Message = "Invalid email or password" });

            var roleName = user.UserRoles.Select(ur => ur.Role.Name).FirstOrDefault();

            return Ok(new
            {
                token = token,
                username = user.Username,
                firstName = user.FirstName,
                lastName = user.LastName,
                email = user.Email
            });
        }


        [AllowAnonymous]
        [HttpPost("Register")]
        public async Task<IActionResult> Register([FromBody] UserDTO request)
        {
            if (request == null)
            {
                return BadRequest("Invalid data");
            }

            try
            {
                var result = await _userService.Register(request);
                if (!result)
                    return BadRequest("Registracija nije uspjela");

                return Ok(new { Message = "Registracija uspješna" });
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("već postoji") || ex.Message.Contains("samo slova"))
                {
                    return BadRequest(new { Message = ex.Message });
                }

                return StatusCode(500, new { Message = "Došlo je do greške na serveru." });
            }
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpPut("profile/{userId}")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UpdateProfile(int userId, [FromForm] UpdateUserProfileDto dto)
        {
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (userIdStr == null)
                return Unauthorized();

            try
            {
                await _userService.UpdateUserProfileAsync(userId, dto);

                return Ok(new { message = "Profil uspješno ažuriran." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpGet("Me")]
        public async Task<IActionResult> GetMyProfile()
        {
            try
            {
                var profile = await _userService.GetCurrentUserProfile(User);
                return Ok(profile);
            }
            catch (UnauthorizedAccessException)
            {
                return Unauthorized();
            }
            catch (KeyNotFoundException)
            {
                return NotFound();
            }
        }
    }
}
