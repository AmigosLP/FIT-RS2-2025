using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model.Enums;

namespace zaMene.Model.ViewModels
{
    public class ReservationAdminDetailDto
    {
        public int ReservationID { get; set; }
        public int PropertyID { get; set; }
        public int UserID { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }

        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public ReservationStatus Status { get; set; }

        public string Title { get; set; }
        public string City { get; set; }
        public decimal Price { get; set; }
        public string Description { get; set; }
        public List<string> ImageUrls { get; set; } = new();

        public string AgentFullName { get; set; }
        public string AgentPhoneNumber { get; set; }
    }
}
