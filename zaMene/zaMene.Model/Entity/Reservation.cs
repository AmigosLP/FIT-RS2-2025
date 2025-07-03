using System;
using System.ComponentModel.DataAnnotations.Schema;
using zaMene.Model.Enums;


namespace zaMene.Model.Entity
{
    public class Reservation
    {
        public int ReservationID { get; set; }

        [ForeignKey("User")]
        public int UserID { get; set; }
        public User User { get; set; }
        [ForeignKey("Property")]
        public int PropertyID { get; set; }
        public Property Property { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public decimal TotalPrice { get; set; }
        public ReservationStatus Status { get; set; } = ReservationStatus.Aktivno;
        public DateTime ReservationDate { get; set; } = DateTime.UtcNow;
    }
}
