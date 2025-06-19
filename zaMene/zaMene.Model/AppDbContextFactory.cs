using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace zaMene.Model
{
    public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
    {
        public AppDbContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<AppDbContext>();
            optionsBuilder.UseSqlServer("Server=KARLO\\SERVER;Database=zaMene;User Id=sa;Password=QWEasd123!;TrustServerCertificate=True"); // stavi stvarni connection string

            return new AppDbContext(optionsBuilder.Options);
        }
    }
}
