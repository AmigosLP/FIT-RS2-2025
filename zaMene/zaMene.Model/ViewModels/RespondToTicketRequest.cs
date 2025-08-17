using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.ViewModels
{
    public class RespondToTicketRequest
    {
        public string Response { get; set; } = string.Empty;
        public bool MarkResolved { get; set; } = true;
    }
}
