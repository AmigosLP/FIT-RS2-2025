using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text;

namespace zaMene.Model
{
    public class Review
    {
        [Key]
        public int ReviewID { get; set; }

        [ForeignKey("User")]
        public int UserID { get; set; }
        public User User { get; set; }
        [ForeignKey("Property")]
        public int PropertyID { get; set; }
        public Property Property { get; set; }

        [Range(1,5)]
        public int Rating { get; set; }
        public string Comment {  get; set; }
        public DateTime ReviewDate {  get; set; } = DateTime.UtcNow;
    }
}
