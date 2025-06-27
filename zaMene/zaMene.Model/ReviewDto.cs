using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model
{
    public class ReviewDto
    {
        public int ReviewID { get; set; }
        public int UserID { get; set; }
        public int PropertyID { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }
        public string UserFullName { get; set; }
        public string? UserProfileImageUrl { get; set; }
        public DateTime ReviewDate { get; set; }
        public string PropertyName { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }
        public string Address { get; set; }
    }
}
