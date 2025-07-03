using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.ViewModel
{
    public class PropertyStatisticsDto
    {
        public int PropertyID { get; set; }
        public string Title { get; set; }
        public string City { get; set; }
        public int TotalReservation { get; set; }
        public double AverageRating { get; set; }
        public int ViewCount { get; set; }
        public bool IsTopProperty { get; set; }
    }
}
