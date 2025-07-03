using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.Entity
{
    public class Notification
    {
        public int Id { get; set; }
        public string Title { get; set; }

        public int UserId { get; set; } 

        public string Type { get; set; } 

        public string Message { get; set; }

        public bool IsRead { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        public int? RelatedReservationId { get; set; }

        public DateTime? ReminderDate { get; set; }
    }

}
