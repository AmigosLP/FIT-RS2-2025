using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModel;

namespace zaMene.Services.Interface
{
    public interface IReservationService: ICRUDService<Reservation, ReservationSearchObject, ReservationDto, ReservationUpdateDto>
    {
        Task<bool> IsPropertyAvailable(int propertyId, DateTime startDate, DateTime endDate);
        Task<IEnumerable<Reservation>> GetActiveReservationsByPropertyId(int propertyId);
        Task<Reservation> CreateReservation(Reservation reservation);
        Task<List<ReservationUserDto>> GetMyReservations(int userId);

    }
}
