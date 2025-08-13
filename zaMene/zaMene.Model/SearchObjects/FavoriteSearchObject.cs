using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.SearchObjects
{
    public class FavoriteSearchObject : BaseSearchObject
    {
        public int? UserID { get; set; }
        public int? PropertyID { get; set; }
    }
}
