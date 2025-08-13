using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Services.Interface;

namespace zaMene.Services.Interfaces
{
    public interface ISupportTicketService : ICRUDService<SupportTicket, SupportTicketSearchObject, SupportTicketDto, SupportTicketUpdateDto>
    {
        Task<SupportTicket> RespondAsync(int ticketId, string response, bool resolve);
        Task<IEnumerable<SupportTicket>> GetMineAsync(int userId, bool? resolved);
        Task<SupportTicket> ResolveAsync(int ticketId, bool resolved);
    }
}
