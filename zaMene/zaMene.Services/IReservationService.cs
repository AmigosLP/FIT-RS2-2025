using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model;
using zaMene.Model.SearchObjects;

namespace zaMene.Services
{
    public interface IReservationService: ICRUDService<Reservation, ReservationSearchObject, ReservationDto, ReservationUpdateDto>
    {
        Task<bool> IsPropertyAvailable(int propertyId, DateTime startDate, DateTime endDate);
        Task<IEnumerable<Reservation>> GetActiveReservationsByPropertyId(int propertyId);
        Task<Reservation> CreateReservation(Reservation reservation);
    }
}
