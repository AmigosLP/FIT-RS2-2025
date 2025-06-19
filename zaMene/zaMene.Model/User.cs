using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Runtime.CompilerServices;
using System.Text;

namespace zaMene.Model
{
    public class User
    {
        [Key]
        public int UserID { get; set; }

        [Required, MaxLength(100)]
        public string FirstName { get; set; }

        [Required, MaxLength(100)]
        public string LastName { get; set; }

        [Required, MaxLength(100)]
        public string Username { get; set; }

        [Required, EmailAddress, MaxLength(255)]
        public string Email { get; set; }

        [Required]
        public string PasswordHash { get; set; }
        public string? Gender { get; set; }
        public string? ProfileImagePath { get; set; }
        public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
        public DateTime RegistrationDate {  get; set; } = DateTime.Now;
        public string? Phone { get; set; }

        public List<Reservation> Reservations { get; set; } = new List<Reservation>();
        public List<Review> Reviews { get; set; } = new List<Review>();
    }
}
