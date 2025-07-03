using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using zaMene.Model;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModel;
using zaMene.Services.Interface;

namespace zaMene.Services.Service
{
    public class NotificationService : BaseCRUDService<
        Notification,
        NotificationSearchObject,
        Notification,
        NotificationDto,
        NotificationUpdateDto>, INotificationService
    {
        private readonly AppDbContext _context;

        public NotificationService(AppDbContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
        }

        public override IQueryable<Notification> AddFilter(NotificationSearchObject search, IQueryable<Notification> query)
        {
            if (search.UserId.HasValue)
                query = query.Where(n => n.UserId == search.UserId.Value);

            if (search.IsRead.HasValue)
                query = query.Where(n => n.IsRead == search.IsRead.Value);

            if (!string.IsNullOrWhiteSpace(search.Type))
                query = query.Where(n => n.Type.Contains(search.Type));


            return base.AddFilter(search, query);
        }
        public async Task<Notification> InsertAsync(NotificationDto request)
        {
            var entity = _mapper.Map<Notification>(request);
            await _context.Notification.AddAsync(entity);
            await _context.SaveChangesAsync();
            return entity;
        }

        public async Task<bool> MarkAsRead(int id)
        {
            var notification = await _context.Notification.FindAsync(id);

            if (notification == null)
                return false;

            notification.IsRead = true;
            await _context.SaveChangesAsync();
            return true;
        }

        public override void BeforeInsert(NotificationDto request, Notification entity)
        {
            entity.CreatedAt = DateTime.UtcNow;
            base.BeforeInsert(request, entity);
        }

        public override void BeforeUpdate(NotificationUpdateDto request, Notification entity)
        {
            entity.UpdatedAt = DateTime.UtcNow;
            base.BeforeUpdate(request, entity);
        }

        public async Task SendNotificationAsync(NotificationDto dto)
        {
            var entity = _mapper.Map<Notification>(dto);
            entity.CreatedAt = DateTime.UtcNow;
            entity.IsRead = false;

            _context.Notification.Add(entity);
            await _context.SaveChangesAsync();

        }

        public async Task<List<NotificationDto>> GetAllAsync()
        {
            var list = await _context.Notification
                .OrderByDescending(n => n.CreatedAt)
                .ToListAsync();

            var dtoList = list.Select(n => new NotificationDto
            {
                NotificationID = n.Id,
                Title = n.Title,
                Message = n.Message,
                Type = n.Type,
                UserId = n.UserId,
                IsRead = n.IsRead,
                CreatedAt = n.CreatedAt,
                UpdatedAt = n.UpdatedAt
            }).ToList();

            return dtoList;
        }

        public async Task<int> GetUnreadNotificationCount(int userId)
        {
            return await _context.Notification
                .CountAsync(n => n.UserId == userId && n.IsRead == false);
        }
    }
}
