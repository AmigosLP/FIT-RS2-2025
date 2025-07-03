using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BCrypt.Net;
using Microsoft.EntityFrameworkCore;
using zaMene.Model;
using zaMene.Model.Entity;

namespace zaMene.Services.Data
{
    public class DatabaseSeeder
    {
        private readonly AppDbContext _context;

        public DatabaseSeeder(AppDbContext context)
        {
            _context = context;
        }

        public async Task SeedAsync()
        {
            await SeedRolesAsync();
            await SeedAdminUserAsync();
            await SeedUsersAsync();
            await SeedPropertiesAsync();
            await SeedNotificationsAsync();
            await SeedCitiesAsync();
            await SeedPaymentsAsync();
            await SeedUserRolesAsync();
            await SeedReviewsAsync();
        }

        private async Task SeedRolesAsync()
        {
            if (!_context.Roles.Any())
            {
                var connection = _context.Database.GetDbConnection();
                await connection.OpenAsync();

                var command = connection.CreateCommand();

                command.CommandText = "SET IDENTITY_INSERT Roles ON";
                await command.ExecuteNonQueryAsync();

                _context.Roles.AddRange(
                    new Role { RoleID = 1, Name = "Admin" },
                    new Role { RoleID = 2, Name = "User" }
                );

                await _context.SaveChangesAsync();
                Console.WriteLine("Roles added");

                command.CommandText = "SET IDENTITY_INSERT Roles OFF";
                await command.ExecuteNonQueryAsync();

                await connection.CloseAsync();
            }
            else
            {
                Console.WriteLine("Roles already exist");
            }
        }


        private async Task SeedAdminUserAsync()
        {
            if (!_context.Users.Any(u => u.Email == "admin@zamene.ba"))
            {
                var adminUser = new User
                {
                    UserID = 1,
                    FirstName = "Admin",
                    LastName = "Admin",
                    Username = "admin",
                    Email = "admin@zamene.ba",
                    PasswordHash = HashPassword("AdminZaMene22"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "123456789"
                };


                var connection = _context.Database.GetDbConnection();
                await connection.OpenAsync();
                var command = connection.CreateCommand();

                command.CommandText = "SET IDENTITY_INSERT Users ON";
                await command.ExecuteNonQueryAsync();
                _context.Users.Add(adminUser);
                await _context.SaveChangesAsync();
                Console.WriteLine("Users added");

                command.CommandText = "SET IDENTITY_INSERT Users OFF";
                await command.ExecuteNonQueryAsync();
                await connection.CloseAsync();

                var adminRole = _context.Roles.First(r => r.Name == "Admin");

                _context.UserRoles.Add(new UserRole
                {
                    UserID = adminUser.UserID,
                    RoleID = adminRole.RoleID
                });
                await _context.SaveChangesAsync();

                Console.WriteLine("Admin user added");
            }
        }

        private async Task SeedUsersAsync()
        {
            if (!_context.Users.Any(u => u.Email != "admin@zamene.ba"))
            {
                var users = new List<User>
                {
                new User
                {
                    UserID = 2,
                    FirstName = "Jasmin",
                    LastName = "Karić",
                    Email = "jasminkaric@gmail.com",
                    Username = "jasmin.k",
                    PasswordHash = HashPassword("JasminPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762123456",
                    Gender = "Muško"
                },
                new User
                {
                    UserID = 3,
                    FirstName = "Amila",
                    LastName = "Delić",
                    Email = "amila.delic@gmail.com",
                    Username = "amila_d",
                    PasswordHash = HashPassword("AmilaPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762345678",
                    Gender = "Žensko"
                },
                new User
                {
                    UserID = 4,
                    FirstName = "Adnan",
                    LastName = "Hasić",
                    Email = "adnan.hasic@gmail.com",
                    Username = "adnan.h",
                    PasswordHash = HashPassword("AdnanPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762456789",
                    Gender = "Muško"
                },
                new User
                {
                    UserID = 5,
                    FirstName = "Sara",
                    LastName = "Begović",
                    Email = "sara.begovic@gmail.com",
                    Username = "sara_b",
                    PasswordHash = HashPassword("SaraPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762567890",
                    Gender = "Žensko"
                },
                new User
                {
                    UserID = 6, 
                    FirstName = "Haris",
                    LastName = "Kovačević",
                    Email = "haris.kovacevic@gmail.com",
                    Username = "haris.k",
                    PasswordHash = HashPassword("HarisPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762678901",
                    Gender = "Muško"
                },
                new User
                {
                    UserID = 7,
                    FirstName = "Lejla",
                    LastName = "Suljić",
                    Email = "lejla.suljic@gmail.com",
                    Username = "lejla_s",
                    PasswordHash = HashPassword("LejlaPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762789012",
                    Gender = "Žensko"
                },
                new User
                {
                    UserID = 8,
                    FirstName = "Edin",
                    LastName = "Mehić",
                    Email = "edin.mehic@gmail.com",
                    Username = "edin_m",
                    PasswordHash = HashPassword("EdinPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762890123",
                    Gender = "Muško"
                },
                new User
                {
                    UserID = 9,
                    FirstName = "Nina",
                    LastName = "Hadžić",
                    Email = "nina.hadzic@gmail.com",
                    Username = "nina_h",
                    PasswordHash = HashPassword("NinaPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762901234",
                    Gender = "Žensko"
                },
                new User
                {
                    UserID = 10,
                    FirstName = "Almir",
                    LastName = "Zukić",
                    Email = "almir.zukic@gmail.com",
                    Username = "almir_z",
                    PasswordHash = HashPassword("AlmirPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762012345",
                    Gender = "Muško"
                },
                new User
                {
                    UserID = 11,
                    FirstName = "Emina",
                    LastName = "Osmanović",
                    Email = "emina.osmanovic@gmail.com",
                    Username = "emina_o",
                    PasswordHash = HashPassword("EminaPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762123457",
                    Gender = "Žensko"
                },
                new User
                {
                    UserID = 12,
                    FirstName = "Mirza",
                    LastName = "Ćurić",
                    Email = "mirza.curic@gmail.com",
                    Username = "mirza_c",
                    PasswordHash = HashPassword("MirzaPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762234567",
                    Gender = "Muško"
                },
                new User
                {
                    UserID = 13,
                    FirstName = "Ivana",
                    LastName = "Petrović",
                    Email = "ivana.petrovic@gmail.com",
                    Username = "ivana_p",
                    PasswordHash = HashPassword("IvanaPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762345679",
                    Gender = "Žensko"
                },
                new User
                {
                    UserID = 14,
                    FirstName = "Tarik",
                    LastName = "Đulović",
                    Email = "tarik.dulovic@gmail.com",
                    Username = "tarik_d",
                    PasswordHash = HashPassword("TarikPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762456780",
                    Gender = "Muško"
                },
                new User
                {
                    UserID = 15,
                    FirstName = "Ajla",
                    LastName = "Selimović",
                    Email = "ajla.selimovic@gmail.com",
                    Username = "ajla_s",
                    PasswordHash = HashPassword("AjlaPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762567891",
                    Gender = "Žensko"
                },
                new User
                {
                    UserID = 16,
                    FirstName = "Damir",
                    LastName = "Begić",
                    Email = "damir.begic@gmail.com",
                    Username = "damir_b",
                    PasswordHash = HashPassword("DamirPass22!"),
                    RegistrationDate = DateTime.UtcNow,
                    Phone = "+38762678902",
                    Gender = "Muško"
                }


            };

                var connection = _context.Database.GetDbConnection();
                await connection.OpenAsync();
                var command = connection.CreateCommand();

                command.CommandText = "SET IDENTITY_INSERT Users ON";
                await command.ExecuteNonQueryAsync();
                _context.Users.AddRange(users);
                await _context.SaveChangesAsync();
                Console.WriteLine("Users added");

                command.CommandText = "SET IDENTITY_INSERT Users OFF";
                await command.ExecuteNonQueryAsync();
                await connection.CloseAsync();
            }
        }


        private async Task SeedPropertiesAsync()
        {
            if (!_context.Properties.Any())
            {
                var admin = _context.Users.FirstOrDefault(u => u.Email == "admin@zamene.ba");
                if (admin == null)
                {
                    Console.WriteLine("Admin user not found, properties not seeded.");
                    return;
                }

                var properties = new List<Property>
                {
                    new Property
                    {
                        PropertyID = 1,
                        Title = "Lijep stan u centru",
                        Description = "Moderno opremljen stan sa svim sadržajima.",
                        Price = 400,
                        Address = "Ulica bb 10",
                        City = "Sarajevo",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 3,
                        Area = 85.5m,
                        PublisheDate = DateTime.UtcNow,
                        isTopProperty = true,
                        viewCount = 120
                    },
                    new Property
                    {
                        PropertyID = 2,
                        Title = "Stan kraj rijeke",
                        Description = "Stan sa prelijepim pogledom na rijeku.",
                        Price = 550,
                        Address = "Obala bb 3",
                        City = "Mostar",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 2,
                        Area = 60.0m,
                        PublisheDate = DateTime.UtcNow,
                        isTopProperty = false,
                        viewCount = 45
                    },
                    new Property
                    {
                        PropertyID = 3,
                        Title = "Lijep stan u centru",
                        Description = "Moderno opremljen stan sa svim sadržajima.",
                        Price = 400.00m,
                        Address = "Ulica bb 10",
                        City = "Sarajevo",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 3,
                        Area = 85.50m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5879304"),
                        ImageUrl = null,
                        isTopProperty = true,
                        viewCount = 120,
                    },
                    new Property
                    {
                        PropertyID = 4, 
                        Title = "Stan kraj rijeke",
                        Description = "Stan sa prelijepim pogledom na rijeku.",
                        Price = 550,
                        Address = "Obala bb 3",
                        City = "Mostar",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 2,
                        Area = 60.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880241"),
                        ImageUrl = null,
                        isTopProperty = false,
                        viewCount = 45,
                    },
                    new Property
                    {
                        PropertyID = 5, 
                        Title = "Moderan stan u centru Tuzle",
                        Description = "Stan sa dvije spavaće sobe, modernom kuhinjom, velikim dnevnim boravkom, brzim WiFi internetom, pametnim TV-om i parking mjestom. Dozvoljeni su kućni ljubimci, a stan je udaljen 5 minuta od parka.",
                        Price = 380,
                        Address = "Aleja Alije Izetbegovića 12",
                        City = "Tuzla",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 3,
                        Area = 75.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880244"),
                        ImageUrl = null,
                        isTopProperty = true,
                        viewCount = 130
                    },
                    new Property
                    {
                        PropertyID = 6,
                        Title = "Stan sa pogledom na Vrbas",
                        Description = "Prelijep stan u Banjaluci sa terasom s koje se pruža pogled na rijeku Vrbas, dvije spavaće sobe, modernim kupatilom i potpuno opremljenom kuhinjom. Brzi internet i mogućnost držanja malih kućnih ljubimaca.",
                        Price = 410,
                        Address = "Obala Vojvode Stepe 5",
                        City = "Banjaluka",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 3,
                        Area = 68.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880246"),
                        ImageUrl = null,
                        isTopProperty = false,
                        viewCount = 75
                    },
                    new Property
                    {
                        PropertyID = 7,
                        Title = "Luksuzni penthouse Sarajevo",
                        Description = "Luksuzni penthouse u centru Sarajeva, sa panoramskim pogledom na grad, velikom terasom, jacuzzi kadom, podnim grijanjem i pametnim kućnim sistemom. WiFi i osiguran parking uključeni.",
                        Price = 220,
                        Address = "Titova 3",
                        City = "Sarajevo",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 4,
                        Area = 120.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880248"),
                        ImageUrl = null,
                        isTopProperty = true,
                        viewCount = 200
                    },
                    new Property
                    {
                        PropertyID = 8,
                        Title = "Stan blizu Starog Mosta",
                        Description = "Stan u Mostaru, udaljen 3 minute hoda od Starog Mosta, idealan za turiste, sa dvije spavaće sobe, klimatizacijom, WiFi, TV-om i modernom kuhinjom. Prikladno za porodice i parove.",
                        Price = 700,
                        Address = "Mala Tepa 8",
                        City = "Mostar",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 2,
                        Area = 65.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880255"),
                        ImageUrl = null,
                        isTopProperty = false,
                        viewCount = 60
                    },
                    new Property
                    {
                        PropertyID = 9,
                        Title = "Mirni stan u Tuzli",
                        Description = "Dvosoban stan u mirnom naselju, sa balkonom, brzim internetom, kuhinjom sa mašinom za suđe, malim kućnim ljubimcima dozvoljen ulazak. Blizina škole i supermarketa.",
                        Price = 560,
                        Address = "Irac 4",
                        City = "Tuzla",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 2,
                        Area = 55.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880257"),
                        ImageUrl = null,
                        isTopProperty = false,
                        viewCount = 40
                    },
                    new Property
                    {
                        PropertyID = 10,
                        Title = "Porodični stan u Banjaluci",
                        Description = "Veliki porodični stan sa tri spavaće sobe, dvije terase, dvostrukom garažom, WiFi i kablovskom TV. Nalazi se u blizini igrališta i parkova, idealno za porodice sa djecom.",
                        Price = 120,
                        Address = "Gundulićeva 14",
                        City = "Banjaluka",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 4,
                        Area = 95.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880331"),
                        ImageUrl = null,
                        isTopProperty = true,
                        viewCount = 110
                    },
                    new Property
                    {
                        PropertyID = 11,
                        Title = "Jednosoban stan Sarajevo",
                        Description = "Kompaktan jednosoban stan u centru Sarajeva sa kompletno opremljenom kuhinjom, renoviranim kupatilom, brzim WiFi i radnim prostorom za studente ili rad od kuće.",
                        Price = 300,
                        Address = "Koševo 7",
                        City = "Sarajevo",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 1,
                        Area = 42.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880334"),
                        ImageUrl = null,
                        isTopProperty = false,
                        viewCount = 50
                    },
                    new Property
                    {
                        PropertyID = 12,
                        Title = "Apartman Mostar sa garažom",
                        Description = "Apartman sa jednom spavaćom sobom, terasom, WiFi, TV-om i garažnim mjestom, klimatizacija uključena, pogodno za samce ili parove.",
                        Price = 280,
                        Address = "Blagajska 2",
                        City = "Mostar",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 1,
                        Area = 48.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880337"),
                        ImageUrl = null,
                        isTopProperty = false,
                        viewCount = 35
                    },
                    new Property
                    {
                        PropertyID = 13,
                        Title = "Stan sa baštom Tuzla",
                        Description = "Stan sa malom privatnom baštom, idealno za ljubitelje prirode, kuhinja sa novim aparatima, WiFi internet, dozvoljeni mali kućni ljubimci.",
                        Price = 100,
                        Address = "Mejdan 9",
                        City = "Tuzla",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 2,
                        Area = 58.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880339"),
                        ImageUrl = null,
                        isTopProperty = false,
                        viewCount = 42
                    },
                    new Property
                    {
                        PropertyID = 14,
                        Title = "Lux studio Sarajevo",
                        Description = "Moderan studio apartman sa brzim internetom, podnim grijanjem, pametnom rasvjetom i modernom kuhinjom, u neposrednoj blizini tramvajske stanice.",
                        Price = 750,
                        Address = "Alipašina 15",
                        City = "Sarajevo",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 1,
                        Area = 40.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880341"),
                        ImageUrl = null,
                        isTopProperty = false,
                        viewCount = 48
                    },
                    new Property
                    {
                        PropertyID = 15,
                        Title = "Stan u Mostaru sa pogledom",
                        Description = "Stan na petom spratu sa predivnim pogledom na grad, dvije spavaće sobe, WiFi, klima, opremljena kuhinja i balkon.",
                        Price = 800,
                        Address = "Rondou 1",
                        City = "Mostar",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 2,
                        Area = 65.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880343"),
                        ImageUrl = null,
                        isTopProperty = false
                    },
                    new Property
                    {
                        PropertyID = 16, 
                        Title = "Stan blizu kampusa Banjaluka",
                        Description = "Savršen stan za studente, WiFi, radni sto, nova kuhinja i blizina univerziteta, parking ispred zgrade.",
                        Price = 670,
                        Address = "Bulevar Stepe Stepanovića 22",
                        City = "Banjaluka",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 1,
                        Area = 45.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880345"),
                        ImageUrl = null,
                        isTopProperty = false,
                        viewCount = 40
                    },
                    new Property
                    {
                        PropertyID = 17, 
                        Title = "Porodični stan Sarajevo",
                        Description = "Trosoban stan sa velikom terasom, WiFi, kablovskom televizijom, podnim grijanjem, parking mjestom i blizinom škole.",
                        Price = 100,
                        Address = "Grbavica 10",
                        City = "Sarajevo",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 3,
                        Area = 80.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880347"),
                        ImageUrl = null,
                        isTopProperty = true,
                        viewCount = 90
                    },
                    new Property
                    {
                        PropertyID = 18,
                        Title = "Stan Mostar uz rijeku",
                        Description = "Stan uz rijeku sa terasom, pogledom na Neretvu, WiFi, parking, nova kuhinja, idealno za parove ili porodice.",
                        Price = 450,
                        Address = "Neretvanska 5",
                        City = "Mostar",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 2,
                        Area = 62.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880349"),
                        ImageUrl = null,
                        isTopProperty = true,
                        viewCount = 70
                    },
                    new Property
                    {
                        PropertyID = 19,
                        Title = "Stan Tuzla sa velikim dvorištem",
                        Description = "Stan sa tri spavaće sobe, velikim dvorištem, roštiljem, WiFi internetom i prostorom za kućne ljubimce.",
                        Price = 900,
                        Address = "Slatina 11",
                        City = "Tuzla",
                        Country = "BiH",
                        AgentID = admin.UserID,
                        RoomCount = 3,
                        Area = 88.00m,
                        PublisheDate = DateTime.Parse("2025-07-03 17:05:06.5880351"),
                        ImageUrl = null,
                        isTopProperty = true,
                        viewCount = 95
                    },

                };

                var connection = _context.Database.GetDbConnection();
                await connection.OpenAsync();
                var command = connection.CreateCommand();

                command.CommandText = "SET IDENTITY_INSERT Properties ON";
                await command.ExecuteNonQueryAsync();
                _context.Properties.AddRange(properties);
                await _context.SaveChangesAsync();
                Console.WriteLine("Properties added");

                command.CommandText = "SET IDENTITY_INSERT Properties OFF";
                await command.ExecuteNonQueryAsync();
                await connection.CloseAsync();

              
            }
        }

        private async Task SeedNotificationsAsync()
        {
            if (!_context.Notification.Any())
            {
                var users = _context.Users.Take(10).ToList();

                var notifications = new List<Notification>() {
                     new Notification
                    {
                        Title = "Dobrodošli!",
                        Message = $"Pozdrav Amila, dobrodošli u aplikaciju!",
                        UserId = 3,
                        CreatedAt = DateTime.UtcNow,
                        IsRead = false,
                        Type = "ReservationCreated"
                    },

                    new Notification
                    {
                        Title = "Novi update",
                        Message = "Dodane su nove funkcionalnosti, provjerite ih!",
                        UserId = 8,
                        CreatedAt = DateTime.UtcNow,
                        IsRead = false,
                        Type = "Information"
                    },

                    new Notification
                    {
                        Title = "Bukiranje uspješno",
                        Message = $"Uspješno ste izvršili bukiranje od {DateTime.Now.AddDays(-7):dd.MM.yyyy} do {DateTime.Now.AddDays(-3):dd.MM.yyyy}.",
                        UserId = 9,
                        CreatedAt = DateTime.UtcNow,
                        IsRead = false,
                        Type = "Information"
                    },


                   new Notification
                    {
                        Title = "Plaćanje potvrđeno",
                        Message = $"Vaše plaćanje za rezervaciju od {DateTime.Now.AddDays(-7):dd.MM.yyyy} do {DateTime.Now.AddDays(-3):dd.MM.yyyy} je uspješno izvršeno dana {DateTime.Now.AddDays(-6):dd.MM.yyyy}.",
                        UserId = 2,
                        CreatedAt = DateTime.UtcNow,
                        IsRead = false,
                        Type = "PaymentSuccess"

                   },

                    new Notification
                    {
                        Title = "Novi update",
                        Message = "Dodane su nove funkcionalnosti, provjerite ih!",
                        UserId = 8,
                        CreatedAt = DateTime.UtcNow,
                        IsRead = false,
                        Type = "Information"
                    },

                     new Notification
                    {
                        Title = "Novi update",
                        Message = "Od naredne sedmice popusti na sve stanove iz Tuzle, provjerite ih!",
                        UserId = 12,
                        CreatedAt = DateTime.UtcNow,
                        IsRead = false,
                        Type = "Information"
                    },

                      new Notification
                    {
                        Title = "Novo Upozorenje",
                        Message = "Od ponedjeljka cemo smanjit stanove u reonu Banjaluke!",
                        UserId = 14,
                        CreatedAt = DateTime.UtcNow,
                        IsRead = false,
                        Type = "Warning"
                    },
                };

                var connection = _context.Database.GetDbConnection();
                await connection.OpenAsync();
                var command = connection.CreateCommand();

                command.CommandText = "SET IDENTITY_INSERT Notification ON";
                await command.ExecuteNonQueryAsync();
                _context.Notification.AddRange(notifications);
                await _context.SaveChangesAsync();
                Console.WriteLine("Notifications added");

                command.CommandText = "SET IDENTITY_INSERT Notification OFF";
                await command.ExecuteNonQueryAsync();
                await connection.CloseAsync();
            }
        }

        private async Task SeedCitiesAsync()
        {
            if (!_context.City.Any())
            {
                var cities = new List<City>
                {
                    new City { CityID = 1, Name = "Sarajevo" },
                    new City { CityID = 2, Name = "Mostar" },
                    new City { CityID = 3, Name = "Tuzla" },
                    new City { CityID = 4, Name = "Zenica" },
                    new City { CityID = 5, Name = "Banja Luka" },
                    new City { CityID = 6, Name = "Bihac" }
                 };


                var connection = _context.Database.GetDbConnection();
                await connection.OpenAsync();
                var command = connection.CreateCommand();

                command.CommandText = "SET IDENTITY_INSERT City ON";
                await command.ExecuteNonQueryAsync();
                _context.City.AddRange(cities);
                await _context.SaveChangesAsync();
                Console.WriteLine("Cities added");

                command.CommandText = "SET IDENTITY_INSERT City OFF";
                await command.ExecuteNonQueryAsync();
                await connection.CloseAsync();
            }
        }

        private async Task SeedPaymentsAsync()
        {
            if (!_context.Payments.Any())
            {
                var reservations = _context.Reservations.Take(5).ToList();

                if (reservations.Count == 0)
                {
                    Console.WriteLine("Nema rezervacija u bazi, Payments nisu seedovani.");
                    return;
                }

                var payments = new List<Payment>
                {
                     new Payment
                     {
                         ReservationID = 1,
                         Amount = 400.00m,
                         PaymentDate = DateTime.UtcNow.AddDays(-10),
                         PaymentMethod = "PayPal",
                         Status = "Completed"
                     },
                     new Payment
                     {
                         ReservationID = 2,
                         Amount = 550.00m,
                         PaymentDate = DateTime.UtcNow.AddDays(-7),
                         PaymentMethod = "Credit Card",
                         Status = "Completed"
                     },
                     new Payment
                     {
                         ReservationID = 3,
                         Amount = 380.00m,
                         PaymentDate = DateTime.UtcNow.AddDays(-5),
                         PaymentMethod = "Bank Transfer",
                         Status = "Pending"
                     },
                     new Payment
                     {
                         ReservationID = 4,
                         Amount = 410.00m,
                         PaymentDate = DateTime.UtcNow.AddDays(-3),
                         PaymentMethod = "PayPal",
                         Status = "Failed"
                     },
                     new Payment
                     {
                         ReservationID = 5,
                         Amount = 220.00m,
                         PaymentDate = DateTime.UtcNow.AddDays(-1),
                         PaymentMethod = "Credit Card",
                         Status = "Completed"
                     }
                };

                var connection = _context.Database.GetDbConnection();
                await connection.OpenAsync();
                var command = connection.CreateCommand();

           
                Console.WriteLine("Payments added");

                await connection.CloseAsync();

           
            }
        }

        private async Task SeedUserRolesAsync()
        {
            if (!_context.UserRoles.Any())
            {
                var userRoles = new List<UserRole>
            {
                new UserRole
                {
                    UserID = 2,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 3,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 4,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 5,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 6,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 7,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 8,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 9,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 10,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 11,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 12,
                    RoleID = 2
                },new UserRole
                {
                    UserID = 13,
                    RoleID = 2
                },new UserRole
                {
                    UserID = 14,
                    RoleID = 2
                },new UserRole
                {
                    UserID = 15,
                    RoleID = 2
                },
                new UserRole
                {
                    UserID = 16,
                    RoleID = 2
                }

                };
                _context.UserRoles.AddRange(userRoles);
                await _context.SaveChangesAsync();
                Console.WriteLine("Reviews added");
            }

        }


        private async Task SeedReviewsAsync()
        {
            if (!_context.Reviews.Any())
            {
                var reviews = new List<Review>
        {
            new Review
            {
                UserID = 2,
                PropertyID = 1,
                Rating = 5,
                Comment = "Odličan stan, sve je bilo kako treba!",
                ReviewDate = new DateTime(2023, 5, 12)
            },
            new Review
            {
                UserID = 3,
                PropertyID = 2,
                Rating = 4,
                Comment = "Dobar stan, ali malo buka vani.",
                ReviewDate = new DateTime(2023, 5, 15)
            },
            new Review
            {
                UserID = 4,
                PropertyID = 3,
                Rating = 3,
                Comment = "Stan je prosječan, ali cijena je pristupačna.",
                ReviewDate = new DateTime(2023, 6, 1)
            },
            new Review
            {
                UserID = 5,
                PropertyID = 4,
                Rating = 5,
                Comment = "Predivan pogled i uredan stan.",
                ReviewDate = new DateTime(2023, 6, 10)
            }
        };

                _context.Reviews.AddRange(reviews);
                await _context.SaveChangesAsync();

                Console.WriteLine("Reviews added");
            }
        }

        private string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }

    }
}
