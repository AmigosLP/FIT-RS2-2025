using zaMene.Model;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System;

namespace zaMene.Services.Data
{
    public class DatabaseSeeder
    {
        private readonly AppDbContext _context;

        public DatabaseSeeder(AppDbContext context)
        {
            _context = context;
        }

        public void Seed()
        {
            // Seed Role
            if (!_context.Roles.Any())
            {
                _context.Roles.AddRange(
                    new Role { Name = "Admin" },
                    new Role { Name = "User" }
                );
                _context.SaveChanges();
            }

            // Seed Admin User
            if (!_context.Users.Any(u => u.Email == "admin@zamene.ba"))
            {
                var admin = new User
                {
                    FirstName = "Admin",
                    LastName = "Admin",
                    Email = "admin@zamene.ba",
                    PasswordHash = HashPassword("AdminZaMene22"),
                    RegistrationDate = DateTime.Now
                };

                _context.Users.Add(admin);
                _context.SaveChanges();

                var adminRole = _context.Roles.First(r => r.Name == "Admin");

                _context.UserRoles.Add(new UserRole
                {
                    UserID = admin.UserID,
                    RoleID = adminRole.RoleID
                });

                _context.SaveChanges();
            }
        }

        private string HashPassword(string password)
        {
            using var sha256 = System.Security.Cryptography.SHA256.Create();
            var bytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(bytes);
        }
    }
}
