using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? PropertyID { get; set; }
        public int? UserID { get;set; }
    }
}
