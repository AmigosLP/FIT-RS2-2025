using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Model
{
   public class PropertyImage
    {
        [Key]
        public int PropertyImageID { get; set; }

        [Required]
        public string ImageUrl { get; set; }

        [ForeignKey("Property")]
        public int PropertyID { get; set; }
        public Property Property { get; set; }


   }
  
}

