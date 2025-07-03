using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.ViewModel
{
    public class PropertyDto
    {
        public int PropertyID { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }
        public string City { get; set; }
        public string Country { get; set; }
        public string Address { get; set; }
        public int AgentID { get; set; }
        public string AgentFullName { get; set; }
        public string? AgentProfileImageUrl { get; set; }
        public string? AgentPhoneNumber { get; set; }
        public int RoomCount { get; set; }
        public decimal Area { get; set; }
        public double AverageRating { get; set; }
        public List<string> ImageUrls { get; set; }
    }
}
