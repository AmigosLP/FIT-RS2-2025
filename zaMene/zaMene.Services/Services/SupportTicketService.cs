using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using zaMene.Model;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Services.Interfaces;

namespace zaMene.Services.Service
{
    public class SupportTicketService
        : BaseCRUDService<SupportTicket, SupportTicketSearchObject, SupportTicket, SupportTicketDto, SupportTicketUpdateDto>,
          ISupportTicketService
    {
        public SupportTicketService(AppDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<SupportTicket> AddFilter(SupportTicketSearchObject search, IQueryable<SupportTicket> query)
        {
            if (search.UserID.HasValue)
                query = query.Where(t => t.UserID == search.UserID);
            if (search.IsResolved.HasValue)
                query = query.Where(t => t.IsResolved == search.IsResolved);
            if (!string.IsNullOrWhiteSpace(search.Subject))
                query = query.Where(t => t.Subject.ToLower().Contains(search.Subject.ToLower()));

            return base.AddFilter(search, query);
        }

        public override void BeforeInsert(SupportTicketDto request, SupportTicket entity)
        {
            // Ako želiš forsirati UTC:
            entity.CreatedAt = DateTime.UtcNow;
            // Ako želiš da servis može “pregaziti” UserID iz DTO-a
            // (npr. u kontroleru ga postaviš iz tokena), ovdje ništa više ne treba.
            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(SupportTicketUpdateDto request, SupportTicket entity)
        {
            if (request.IsResolved is bool isResolved)
            {
                entity.IsResolved = isResolved;
                entity.ResolvedAt = isResolved ? DateTime.UtcNow : (DateTime?)null;
            }

            if (!string.IsNullOrWhiteSpace(request.Response))
            {
                entity.Response = request.Response;
            }

            base.BeforeUpdate(request, entity);
        }


        public async Task<SupportTicket> RespondAsync(int ticketId, string response, bool resolve)
        {
            var set = _context.Set<SupportTicket>();
            var entity = await set.FirstOrDefaultAsync(x => x.SupportTicketID == ticketId)
                         ?? throw new Exception("Ticket nije pronađen.");

            entity.Response = response;
            if (resolve)
            {
                entity.IsResolved = true;
                entity.ResolvedAt = DateTime.UtcNow;
            }

            _context.Notification.Add(new Notification
            {
                UserID = entity.UserID,
                Title = "Odgovor na vaš tiket",
                Message = response.Length > 200 ? response.Substring(0, 200) + "..." : response,
                Type = "support",
                CreatedAt = DateTime.UtcNow,
                // Ako dodaš polje u model/migraciji:
                // RelatedTicketId = entity.SupportTicketID
            });

            await _context.SaveChangesAsync();
            return entity;
        }

        public async Task<IEnumerable<SupportTicket>> GetMineAsync(int userId, bool? resolved)
        {
            var q = _context.SupportTicket.AsQueryable().Where(x => x.UserID == userId);
            if (resolved.HasValue) q = q.Where(x => x.IsResolved == resolved.Value);
            return await q.OrderByDescending(x => x.CreatedAt).ToListAsync();
        }

        public async Task<SupportTicket> ResolveAsync(int ticketId, bool resolved)
        {
            var set = _context.Set<SupportTicket>();
            var entity = await set.FirstOrDefaultAsync(x => x.SupportTicketID == ticketId)
                         ?? throw new Exception("Ticket nije pronađen.");

            entity.IsResolved = resolved;
            entity.ResolvedAt = resolved ? DateTime.UtcNow : null;
            await _context.SaveChangesAsync();
            return entity;
        }
    }
}
