using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using zaMene.Model;
using zaMene.Model.Enums;
using zaMene.Model.SearchObjects;

namespace zaMene.Services
{
    public class ReservationService : BaseCRUDService<Model.Reservation, ReservationSearchObject, Reservation ,ReservationDto, ReservationUpdateDto>, IReservationService
    {
        private readonly AppDbContext _context;
        private readonly IMapper _mapper;

        public ReservationService(AppDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<bool> IsPropertyAvailable(int propertyId, DateTime startDate, DateTime endDate)
        {
            return !await _context.Reservations.AnyAsync(r =>
                r.PropertyID == propertyId &&
                r.Status == ReservationStatus.Aktivno &&
                ((startDate >= r.StartDate && startDate < r.EndDate) ||
                 (endDate > r.StartDate && endDate <= r.EndDate) ||
                 (startDate <= r.StartDate && endDate >= r.EndDate))
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
            return reservation;
        }
    }
}
