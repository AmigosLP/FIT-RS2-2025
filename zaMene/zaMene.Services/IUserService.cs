
using zaMene.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model.SearchObjects;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace zaMene.Services
{
    public interface IUserService : ICRUDService<User, UserSearchObject, UserDTO, UserUpdateDto>
    {
        bool VerifyPassword (string password, string hashedPassword);
        Task<string> Login(string username, string password);
        Task<bool> Register(UserDTO request);
        Task UpdateUserProfileAsync(int userId, UpdateUserProfileDto dto);
        Task<UserProfileDto> GetCurrentUserProfile(ClaimsPrincipal user);
    }
}

