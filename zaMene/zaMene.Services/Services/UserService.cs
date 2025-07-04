using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using MapsterMapper;
using zaMene.Model.SearchObjects;
using Azure;
using System.Linq.Dynamic;
using Microsoft.EntityFrameworkCore.Storage;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Identity;
using System.Data;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using RabbitMQ.Client;
using System.Threading.Channels;
using IModel = RabbitMQ.Client.IModel;
using Newtonsoft.Json;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;
using Microsoft.AspNetCore.Hosting;
using System.Security.Claims;
using zaMene.Model.Entity;
using zaMene.Model.ViewModel;
using zaMene.Services.Interface;

namespace zaMene.Services.Service
{
    public class UserService : BaseCRUDService<User, UserSearchObject, User, UserDTO, UserUpdateDto>, IUserService
    {
        ILogger<UserService> _logger;
        private readonly RabbitMqService _rabbitMqService;
        private readonly IModel _channel;
        private readonly IWebHostEnvironment _environment;
        private readonly AppDbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public UserService(AppDbContext context, IMapper mapper, ILogger<UserService> logger,
            RabbitMqService rabbitMqService, IWebHostEnvironment environment, IHttpContextAccessor httpContextAccessor, AppDbContext context1) : base(context, mapper)
        {
            _logger = logger;
            _rabbitMqService = rabbitMqService;
            _environment = environment;
            _httpContextAccessor = httpContextAccessor;
            _context = context1;
        }

        public override IQueryable<User> AddFilter(UserSearchObject searchObject, IQueryable<User> query)
        {
            query = base.AddFilter(searchObject, query);

            if(!string.IsNullOrWhiteSpace(searchObject.FirstNameGTE))
            {
                query = query.Where(x => x.FirstName.StartsWith(searchObject.FirstNameGTE));
            }

            if (!string.IsNullOrWhiteSpace(searchObject.LastNameGTE))
            {
                query = query.Where(x => x.LastName.StartsWith(searchObject.LastNameGTE));
            }

            if (!string.IsNullOrWhiteSpace(searchObject.Email))
            {
                query = query.Where(x => x.Email.StartsWith(searchObject.Email));
            }

            return query;
        }

        public override void BeforeInsert(UserDTO request, User entity)
        {
            base.BeforeInsert(request, entity);

            Mapper.Map(request, entity);
        }

        public override void BeforeUpdate(UserUpdateDto request, User entity)
        {
            base.BeforeUpdate(request, entity);
            Mapper.Map(request, entity);

        }

        public async Task<string> Login(string username, string password)
        {
            var entity = await _context.Users
                .Include(x => x.UserRoles).ThenInclude(y => y.Role)
                .FirstOrDefaultAsync(x => x.Username == username);

            if (entity == null)
                return null;

            var hash = VerifyPassword(password, entity.PasswordHash);
            if (!hash)
                return null;

            var roleID = await _context.UserRoles
                .Where(x => x.UserID == entity.UserID)
                .Select(y => y.RoleID)
                .FirstOrDefaultAsync();

            var roleName = await _context.Roles
                .Where(x => x.RoleID == roleID)
                .Select(y => y.Name)
                .FirstOrDefaultAsync();

            var token = JwtService.JWTTokenGenerate(entity, roleName);
            return token;
        }

        public async Task<bool> Register(UserDTO request)
        {

            if (string.IsNullOrWhiteSpace(request.FirstName) || string.IsNullOrWhiteSpace(request.LastName))
                throw new Exception("Ime i prezime su obavezni.");

            if (_context.Users.Any(u => u.Username == request.Username))
                throw new Exception("Korisnik s tim korisničkim imenom već postoji");

            if (_context.Users.Any(u => u.Email == request.Email))
                throw new Exception("Korisnik s tim emailom već postoji");

            if (!IsValidName(request.FirstName) || !IsValidName(request.LastName))
                throw new Exception("Ime i prezime mogu sadržavati samo slova.");

            if (!IsValidEmail(request.Email))
                throw new Exception("Email nije u ispravnom formatu.");


            request.FirstName = Capitalize(request.FirstName);
            request.LastName = Capitalize(request.LastName);


            var entity = Mapper.Map<User>(request);
            entity.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            var userRole = _context.Roles.FirstOrDefault(r => r.Name == "User");
            if (userRole == null)
                throw new Exception("User rola ne postoji");

            entity.UserRoles = new List<UserRole>
            {
                new UserRole
                {
                    RoleID = userRole.RoleID
                }
            };

            _context.Users.Add(entity);
            await _context.SaveChangesAsync();


            _rabbitMqService.PublishRegistrationEmail(request.Email);

            return true;
        }

        public async Task UpdateUserProfileAsync(int userId, UpdateUserProfileDto dto)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                throw new Exception("Korisnik nije pronađen.");

            if (!string.IsNullOrWhiteSpace(dto.Username))
            {
                if (user.Username != dto.Username)
                {
                    bool usernameExists = await _context.Users.AnyAsync(u => u.Username == dto.Username && u.UserID != userId);
                    if (usernameExists)
                        throw new Exception("Korisničko ime je već zauzeto.");

                    user.Username = dto.Username;
                }
            }

            if (!string.IsNullOrWhiteSpace(dto.FirstName))
            {
                user.FirstName = dto.FirstName;
            }

            if (!string.IsNullOrWhiteSpace(dto.LastName))
            {
                user.LastName = dto.LastName;
            }

            if (!string.IsNullOrWhiteSpace(dto.Email))
            {
                if (user.Email != dto.Email)
                {
                    bool emailExists = await _context.Users.AnyAsync(u => u.Email == dto.Email && u.UserID != userId);
                    if (emailExists)
                        throw new Exception("Email je već zauzet.");

                    user.Email = dto.Email;
                }
            }

            if (!string.IsNullOrWhiteSpace(dto.Password))
            {
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);
            }

            if (dto.ProfileImagePath != null)
            {
                var fileName = $"{Guid.NewGuid()}{Path.GetExtension(dto.ProfileImagePath.FileName)}";
                var uploadsFolder = Path.Combine(_environment.WebRootPath, "uploads");
                if (!Directory.Exists(uploadsFolder))
                    Directory.CreateDirectory(uploadsFolder);

                var filePath = Path.Combine(uploadsFolder, fileName);
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await dto.ProfileImagePath.CopyToAsync(stream);
                }

                user.ProfileImagePath = $"/uploads/{fileName}";
            }

            await _context.SaveChangesAsync();
        }

        public async Task<UserProfileDto> GetCurrentUserProfile(ClaimsPrincipal user)
        {
            if (user == null)
                throw new ArgumentNullException(nameof(user));

            var userIdClaim = user.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null)
                throw new Exception("User ID claim nije pronađen.");

            var userId = int.Parse(userIdClaim.Value);

            var userEntity = await _context.Users.FirstOrDefaultAsync(u => u.UserID == userId);
            if (userEntity == null)
                throw new Exception("Korisnik nije pronađen u bazi.");

            var httpContext = _httpContextAccessor.HttpContext;
            if (httpContext == null)
                throw new Exception("HttpContext nije dostupan.");

            var request = httpContext.Request;
            var baseUrl = $"{request.Scheme}://{request.Host}";

            if (string.IsNullOrEmpty(userEntity.ProfileImagePath))
            {
                return new UserProfileDto
                {
                    Id = userEntity.UserID,
                    Username = userEntity.Username,
                    Email = userEntity.Email,
                    FirstName = userEntity.FirstName,
                    LastName = userEntity.LastName,
                    ProfileImageUrl = null
                };
            }

            var fileName = Path.GetFileName(userEntity.ProfileImagePath);

            return new UserProfileDto
            {
                Id = userEntity.UserID,
                Username = userEntity.Username,
                Email = userEntity.Email,
                FirstName = userEntity.FirstName,
                LastName = userEntity.LastName,
                ProfileImageUrl = $"{baseUrl}/uploads/{fileName}"
            };
        }

        public bool VerifyPassword(string password, string hashedPassword)
        {
            return BCrypt.Net.BCrypt.Verify(password, hashedPassword);
        }

        private string Capitalize(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return input;

            input = input.Trim();
            return char.ToUpper(input[0]) + input.Substring(1).ToLower();
        }

        private bool IsValidName(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
                return false;

            return Regex.IsMatch(name, @"^[A-Za-zŠšĐđČčĆćŽž]+(?: [A-Za-zŠšĐđČčĆćŽž]+)*$");
        }

        private bool IsValidEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            return Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$");
        }

    }
}
