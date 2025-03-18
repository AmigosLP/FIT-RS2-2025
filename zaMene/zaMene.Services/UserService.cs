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

namespace zaMene.Services
{
    public class UserService : BaseCRUDService<Model.User, UserSearchObject, User, UserDTO, UserUpdateDto>, IUserService
    {
        ILogger<UserService> _logger;
        public UserService(AppDbContext context, IMapper mapper, ILogger<UserService> logger) : base(context, mapper)
        {
            _logger = logger;
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

        public Model.User Login(string username, string password)
        {
            var entity = _context.Users.Include(x=>x.UserRoles).ThenInclude(y=>y.Role)
                .FirstOrDefault(x => x.FirstName == username);
            if (entity == null)
            {
                return null;
            }

            var hash = VerifyPassword(password, entity.PasswordHash);
            if (!hash) 
            {
                return null;
            }

            return this.Mapper.Map<Model.User>(entity);
              
        }

        public bool VerifyPassword(string password, string hashedPassword)
        {
            return BCrypt.Net.BCrypt.Verify(password, hashedPassword);
        }
    }
}
