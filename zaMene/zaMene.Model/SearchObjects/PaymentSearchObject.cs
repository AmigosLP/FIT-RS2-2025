using System;

namespace zaMene.Model.SearchObjects
{
    public class PaymentSearchObject : BaseSearchObject
    {
        public int? ReservationID { get; set; }
        public string? Status { get; set; }
        public string? PaymentMethod { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }     
        public decimal? MinAmount { get; set; }
        public decimal? MaxAmount { get; set; }
    }
}
