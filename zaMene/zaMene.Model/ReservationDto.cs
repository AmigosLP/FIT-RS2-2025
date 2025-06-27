using System;
using zaMene.Model.Enums;

public class ReservationDto
{
    public int PropertyID { get; set; }
    public int UserID { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public decimal TotalPrice { get; set; }
    public ReservationStatus Status { get; set; }
}
