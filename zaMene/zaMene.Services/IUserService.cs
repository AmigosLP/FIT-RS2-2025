
using zaMene.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model.SearchObjects;

namespace zaMene.Services
{
    public interface IUserService : ICRUDService<User, UserSearchObject, UserDTO, UserUpdateDto>
    {
        bool VerifyPassword (string password, string hashedPassword);
        Model.User Login(string username, string password);
    }
}

