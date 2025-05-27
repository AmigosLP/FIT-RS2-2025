using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace zaMene.Model
{
    public class PropertyCreateRequest
    {
        [Required]
        public string Title { get; set; }

        public string Description { get; set; }

        [Required]
        public decimal Price { get; set; }

        public string Address { get; set; }
        public string City { get; set; }
        public string Country { get; set; }

        [Required]
        public int AgentID { get; set; }

        public int RoomCount { get; set; }
        public decimal Area { get; set; }

        // Za upload slika
        public List<IFormFile> Images { get; set; }
    }
}
