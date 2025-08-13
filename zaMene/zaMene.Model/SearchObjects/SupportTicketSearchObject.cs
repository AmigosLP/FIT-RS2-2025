using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.SearchObjects
{
    public class SupportTicketSearchObject : BaseSearchObject
    {
        public int? UserID { get; set; }
        public bool? IsResolved { get; set; }
        public string? Subject { get; set; }
    }
}
