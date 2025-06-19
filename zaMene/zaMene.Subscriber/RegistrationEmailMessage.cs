using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Subscriber
{
    public class RegistrationEmailMessage
    {
        public string Email { get; set; }
        public string Message { get; set; }
        public string? Subject { get; set; }
    }
}
