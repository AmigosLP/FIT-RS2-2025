using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.ViewModel
{
    public class ReviewCreateDto
    {
        public int UserID { get; set; }
        public int PropertyID { get; set; }
        public int Rating { get; set; }
        public string Comment { get; set; }

    }
}
