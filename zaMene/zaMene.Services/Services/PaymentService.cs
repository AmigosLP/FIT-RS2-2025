using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using zaMene.Model;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Services.Interfaces;

namespace zaMene.Services.Service
{
    public class PaymentService : BaseCRUDService<Payment, PaymentSearchObject, Payment, PaymentDto, UpdatePaymentDto>, IPaymentService
    {
        public PaymentService(AppDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Payment> AddFilter(PaymentSearchObject search, IQueryable<Payment> query)
        {
            if (search == null)
                return base.AddFilter(search, query);

            if (search.ReservationID.HasValue)
                query = query.Where(p => p.ReservationID == search.ReservationID.Value);

            if (!string.IsNullOrWhiteSpace(search.Status))
                query = query.Where(p => p.Status.ToLower().Contains(search.Status.ToLower()));

            if (!string.IsNullOrWhiteSpace(search.PaymentMethod))
                query = query.Where(p => p.PaymentMethod.ToLower().Contains(search.PaymentMethod.ToLower()));

            if (search.FromDate.HasValue)
                query = query.Where(p => p.PaymentDate >= search.FromDate.Value);

            if (search.ToDate.HasValue)
                query = query.Where(p => p.PaymentDate <= search.ToDate.Value);

            if (search.MinAmount.HasValue)
                query = query.Where(p => p.Amount >= search.MinAmount.Value);

            if (search.MaxAmount.HasValue)
                query = query.Where(p => p.Amount <= search.MaxAmount.Value);

            return base.AddFilter(search, query);
        }

        public override void BeforeInsert(PaymentDto request, Payment entity)
        {
            entity.PaymentDate = request.PaymentDate;
            entity.Status = string.IsNullOrWhiteSpace(request.Status) ? "Pending" : request.Status!;
            entity.PaymentMethod = string.IsNullOrWhiteSpace(request.PaymentMethod) ? "Unknown" : request.PaymentMethod!;
            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(UpdatePaymentDto request, Payment entity)
        {
            if (request.PaymentDate.HasValue)
                entity.PaymentDate = request.PaymentDate.Value;

            if (request.Status != null && !string.IsNullOrWhiteSpace(request.Status))
                entity.Status = request.Status;

            if (request.PaymentMethod != null && !string.IsNullOrWhiteSpace(request.PaymentMethod))
                entity.PaymentMethod = request.PaymentMethod;

            base.BeforeUpdate(request, entity);
        }
    }
}
