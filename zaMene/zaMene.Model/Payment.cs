using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace zaMene.Model
{
    public class Payment
    {
        [Key]
        public int PaymentID { get; set; }
        [ForeignKey("Reservation")]
        public int ReservationID { get; set; }
        public Reservation Reservation { get; set; }
        public decimal Amount { get; set; }
        public DateTime PaymentDate { get; set; } = DateTime.UtcNow;
        public string PaymentMethod {  get; set; } //npr Paypal u mom slucaju
        public string Status {  get; set; } //npr uspjesno, pending, neuspjesno
        
    }
}
