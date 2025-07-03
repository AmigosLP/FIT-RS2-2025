using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.ViewModel
{
    public class NotificationUpdateDto : NotificationDto
    {
        public string Content { get; set; }
        public bool IsRead { get; set; }

    }
}
