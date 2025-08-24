using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using zaMene.Model;
using zaMene.Model.Entity;
using zaMene.Model.Enums;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModel;
using zaMene.Model.ViewModels;
using zaMene.Services.Interface;

namespace zaMene.Services.Service
{
    public class ReservationService : BaseCRUDService<Reservation, ReservationSearchObject, Reservation ,ReservationDto, ReservationUpdateDto>, IReservationService
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;
        private readonly INotificationService _notificationService;


        public ReservationService(AppDbContext context, IMapper mapper, INotificationService notificationService) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
            _notificationService = notificationService;
        }

        public async Task<bool> IsPropertyAvailable(int propertyId, DateTime startDate, DateTime endDate)
        {
            return !await _context.Reservations.AnyAsync(r =>
                r.PropertyID == propertyId &&
                r.Status == ReservationStatus.Aktivno &&
                (startDate >= r.StartDate && startDate < r.EndDate ||
                 endDate > r.StartDate && endDate <= r.EndDate ||
                 startDate <= r.StartDate && endDate >= r.EndDate)
            );
        }

        public async Task<IEnumerable<Reservation>> GetActiveReservationsByPropertyId(int propertyId)
        {
            return await _context.Reservations
                .Where(r => r.PropertyID == propertyId && r.Status == ReservationStatus.Aktivno)
                .ToListAsync();
        }

        public async Task<Reservation> CreateReservation(Reservation reservation)
        {
            _context.Reservations.Add(reservation);
            await _context.SaveChangesAsync();

            var property = await _context.Properties.FindAsync(reservation.PropertyID);


            var notificationDto = new NotificationDto
            {
                UserID = reservation.UserID,
                Type = "ReservationCreated",
                Title = "Uspješna rezervacija",
                Message = $"Uspješno ste rezervisali nekretninu '{property?.Title ?? "ID: " + reservation.PropertyID}' od {reservation.StartDate:d} do {reservation.EndDate:d}.",
                IsRead = false,
                CreatedAt = DateTime.UtcNow,
                RelatedReservationId = reservation.ReservationID
            };

            await _notificationService.InsertAsync(notificationDto);

            return reservation;
        }

        public async Task<List<ReservationUserDto>> GetMyReservations(int userId)
        {
            var reservations = await _context.Reservations
                .Include(r => r.Property)
                    .ThenInclude(p => p.Images)
                .Include(r => r.Property)
                    .ThenInclude(p => p.Agent)
                .Where(r => r.UserID == userId)
                .OrderByDescending(r => r.StartDate)
                .ToListAsync();

            var result = reservations.Select(r => new ReservationUserDto
            {
                ReservationID = r.ReservationID,
                PropertyID = r.PropertyID,
                UserID = r.UserID,
                StartDate = r.StartDate,
                EndDate = r.EndDate,
                Status = r.Status,
                PropertyTitle = r.Property?.Title,
                PropertyCity = r.Property?.City,
                PropertyPrice = r.Property?.Price ?? 0,
                PropertyDescription = r.Property?.Description,
                PropertyImageUrls = r.Property?.Images?.Select(i => i.ImageUrl).ToList() ?? new List<string>(),
                PropertyAgentName = r.Property?.Agent?.Username,
                PropertyAgentPhone = r.Property?.Agent?.Phone
            }).ToList();

            return result;
        }

        public async Task<List<ReservationAdminDetailDto>> GetAllDetailedAsync(ReservationSearchObject search)
        {
 
            var q = _context.Reservations
                .Include(r => r.Property).ThenInclude(p => p.Images)
                .Include(r => r.Property).ThenInclude(p => p.Agent)
                .Include(r => r.User)
                .AsQueryable();

            q = q.OrderByDescending(r => r.StartDate);
            var totalCount = await q.CountAsync();


            var list = await q.ToListAsync();

            var result = list.Select(r => new ReservationAdminDetailDto
            {
                ReservationID = r.ReservationID,
                PropertyID = r.PropertyID,

                UserID = r.UserID,
                Username = r.User?.Username,
                Email = r.User?.Email,

                StartDate = r.StartDate,
                EndDate = r.EndDate,
                Status = r.Status,

                Title = r.Property?.Title,
                City = r.Property?.City,
                Price = r.Property?.Price ?? 0,
                Description = r.Property?.Description,
                ImageUrls = r.Property?.Images?.Select(i => i.ImageUrl).ToList() ?? new List<string>(),

                AgentFullName = r.Property?.Agent?.Username,
                AgentPhoneNumber = r.Property?.Agent?.Phone,
            }).ToList();

            return result;
        }
    }
}
