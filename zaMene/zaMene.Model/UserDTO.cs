using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace zaMene.Model
{
    public class UserDTO
    {
        public int UserID { get; set; }       
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }

        [Required]
        [RegularExpression("Muško|Žensko", ErrorMessage = "Izaberite muški ili ženski spol.")]
        public string Gender { get; set; }
        public string Password { get; set; }
    }
}
