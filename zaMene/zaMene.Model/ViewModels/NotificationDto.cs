using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.ViewModel
{
    public class NotificationDto
    {
        public int NotificationID { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public string Type { get; set; }
        public string Content { get; set; }
        public bool IsRead { get; set; }
        public int? RelatedReservationId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

    }
}
