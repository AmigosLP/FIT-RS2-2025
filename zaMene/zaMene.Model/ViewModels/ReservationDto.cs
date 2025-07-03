using System;
using System.Collections.Generic;
using zaMene.Model.Enums;

namespace zaMene.Model.ViewModel
{
    public class ReservationDto
    {
        public int PropertyID { get; set; }
        public int UserID { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public ReservationStatus Status { get; set; }
    }
}
