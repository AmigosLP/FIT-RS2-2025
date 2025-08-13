using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model.Entity
{
    public class Favorite
    {
        public int FavoriteID { get; set; }

        [ForeignKey("User")]
        public int UserID { get; set; }
        public User User { get; set; }

        [ForeignKey("Property")]
        public int PropertyID { get; set; }
        public Property Property { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
