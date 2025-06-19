using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using zaMene.Model;

namespace zaMene.Model
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Property> Properties { get; set; }
        public DbSet<Reservation> Reservations { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Payment> Payments { get; set; }
        public DbSet<PropertyImage> PropertyImages { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<IdentityUserLogin<int>>(b =>
            {
                b.HasKey(login => new { login.LoginProvider, login.ProviderKey });
            });

            modelBuilder.Entity<IdentityUserRole<int>>(b =>
            {
                b.HasKey(r => new { r.UserId, r.RoleId });
            });

            modelBuilder.Entity<IdentityUserToken<int>>(b =>
            {
                b.HasKey(t => new { t.UserId, t.LoginProvider, t.Name });
            });

            // Unique constraint za email korisnika
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // Relacija Property -> User (Agent)
            modelBuilder.Entity<Property>()
                .HasOne(p => p.Agent)
                .WithMany()
                .HasForeignKey(p => p.AgentID)
                .OnDelete(DeleteBehavior.Restrict); // 🛠 Sprečava kaskadno brisanje

            // Relacija Reservation -> User (korisnik koji rezerviše)
            modelBuilder.Entity<Reservation>()
                .HasOne(r => r.User)
                .WithMany(u => u.Reservations)
                .HasForeignKey(r => r.UserID)
                .OnDelete(DeleteBehavior.Restrict); // 🛠 Sprečava kaskadno brisanje

            // Relacija Reservation -> Property (nekretnina koja se rezerviše)
            modelBuilder.Entity<Reservation>()
                .HasOne(r => r.Property)
                .WithMany(p => p.Reservations)
                .HasForeignKey(r => r.PropertyID)
                .OnDelete(DeleteBehavior.Restrict); // 🛠 Sprečava kaskadno brisanje

            // Relacija Review -> User (ko je ostavio recenziju)
            modelBuilder.Entity<Review>()
                .HasOne(r => r.User)
                .WithMany(u => u.Reviews)
                .HasForeignKey(r => r.UserID)
                .OnDelete(DeleteBehavior.Restrict);

            // Relacija Review -> Property (koji je stan ocijenjen)
            modelBuilder.Entity<Review>()
                .HasOne(r => r.Property)
                .WithMany(p => p.Reviews)
                .HasForeignKey(r => r.PropertyID)
                .OnDelete(DeleteBehavior.Cascade);

            // Relacija Payment -> Reservation
            modelBuilder.Entity<Payment>()
                .HasOne(p => p.Reservation)
                .WithMany()
                .HasForeignKey(p => p.ReservationID)
                .OnDelete(DeleteBehavior.Cascade);

            // Osiguraj da su decimal polja pravilno definisana
            modelBuilder.Entity<Property>()
                .Property(p => p.Price)
                .HasPrecision(18, 2);

            modelBuilder.Entity<Property>()
                .Property(p => p.Area)
                .HasPrecision(18, 2);

            modelBuilder.Entity<Reservation>()
                .Property(r => r.TotalPrice)
                .HasPrecision(18, 2);

            modelBuilder.Entity<Payment>()
                .Property(p => p.Amount)
                .HasPrecision(18, 2);

            modelBuilder.Entity<UserRole>()
                .HasKey(ur => new { ur.UserID, ur.RoleID });

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserID);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleID);
        }
    }
}
