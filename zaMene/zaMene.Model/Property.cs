using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;


namespace zaMene.Model
{
    public class Property
    {
        [Key]
        public int PropertyID { get; set; }

        [Required, MaxLength(255)]
        public string Title { get; set; }

        public string Description { get; set; }

        [Required]
        public decimal Price { get; set; }

        public decimal Address {  get; set; }

        public string City { get; set; }

        public string Country { get; set; }
      

        [ForeignKey("Agent")]
        public int AgentID { get; set; }
        public User Agent { get; set; }
        public int RoomCount {  get; set; }
        public decimal Area {  get; set; }
        public DateTime PublisheDate { get; set; } = DateTime.UtcNow;

        public List<Reservation> Reservations { get; set; } = new List<Reservation>();
        public List<Review> Reviews { get; set; } = new List<Review>();
    }
}
