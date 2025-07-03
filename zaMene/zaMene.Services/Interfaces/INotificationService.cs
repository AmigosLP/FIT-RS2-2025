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
    public interface INotificationService : ICRUDService<Notification, NotificationSearchObject,NotificationDto, NotificationUpdateDto>
    {
        Task<bool> MarkAsRead(int id);
        Task SendNotificationAsync(NotificationDto notification);
        Task<Notification> InsertAsync(NotificationDto request);

        Task<List<NotificationDto>> GetAllAsync();
        Task<int> GetUnreadNotificationCount(int userId);

    }
}
