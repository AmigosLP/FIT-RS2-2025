using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model
{
    public class UserRole
    {
        public int UserID { get; set; }
        public virtual User User { get; set; }

        public int RoleID { get; set; }
        public virtual Role Role { get; set; }
    }
}
