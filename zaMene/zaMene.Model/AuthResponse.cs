using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model
{
    public class AuthResponse
    {
        public string Token { get; set; }
        public string Email { get; set; }
        public List<string> Roles { get; set; }
    }

}
