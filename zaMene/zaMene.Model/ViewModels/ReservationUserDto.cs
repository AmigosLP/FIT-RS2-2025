using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model.Enums;

namespace zaMene.Model.ViewModel
{
    public class ReservationUserDto
    {
        public int ReservationID { get; set; }
        public int PropertyID { get; set; }
        public int UserID { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public ReservationStatus Status { get; set; }

        public string PropertyTitle { get; set; }
        public string PropertyCity { get; set; }
        public decimal PropertyPrice { get; set; }
        public string PropertyDescription { get; set; }
        public List<string> PropertyImageUrls { get; set; }
        public string PropertyAgentName { get; set; }
        public string PropertyAgentPhone { get; set; }
    }
}
