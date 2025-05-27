using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model;
using zaMene.Model.SearchObjects;

namespace zaMene.Services
{
    public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate> : BaseService<TModel, TSearch, TDbEntity> where TModel : class where TSearch : BaseSearchObject where TDbEntity : class
    {
        protected readonly IMapper _mapper;

        public BaseCRUDService(AppDbContext context, IMapper mapper) : base(context, mapper)
        {
            _mapper = mapper;
        }

        public TModel Insert(TInsert request)
        {

            TDbEntity entity = Mapper.Map<TDbEntity>(request);

            BeforeInsert(request, entity);
            _context.Add(entity);
            _context.SaveChanges();

           return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeInsert(TInsert request, TDbEntity entity)
        {
            if (request is UserDTO userDto && entity is User user)
            {
                if (_context.Users.AnyAsync(u => u.Email == userDto.Email).Result)
                {
                    throw new Exception("User with this email already exists.");
                }

                // Hashiranje lozinke
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(userDto.Password);
                user.RegistrationDate = DateTime.UtcNow; // Setovanje datuma registracije
            }
        }

        public TModel Update(int id, TUpdate request)
        {
            var set = _context.Set<TDbEntity>();
            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Entity not found.");
            }

            Mapper.Map(request, entity);

            BeforeUpdate(request, entity);

            _context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }
        
        public virtual void BeforeUpdate(TUpdate request, TDbEntity entity)
        {

            if (request is UserUpdateDto userUpdateDto && entity is User user)
            {
                Mapper.Map(userUpdateDto, user);
            }
        }

    }
}
