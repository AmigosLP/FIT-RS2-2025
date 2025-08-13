using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.ViewModels
{
    public class SupportTicketUpdateDto
    {
        public string? Response { get; set; }
        public bool IsResolved { get; set; }
        public DateTime? ResolvedAt { get; set; } = DateTime.Now;
    }

}
