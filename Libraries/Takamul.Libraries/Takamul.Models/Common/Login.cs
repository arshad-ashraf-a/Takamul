/*************************************************************************************************/
/* Class Name       : Login.cs                                                                  */
/* Designed BY      : Arshad Ashraf                                                              */
/* Created BY       : Arshad Ashraf                                                              */
/* Creation Date    : 02.01.2017 10:00 PM                                                        */
/* Document ID      : N/A                                                                        */
/* Description      : Login Model                                                                */
/*************************************************************************************************/
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models
{
    public class Login 
    {
        [Required(ErrorMessage = "Username is required")] // make the field required
        [Display(Name = "Username")]  // Set the display name of the field
        public string username { get; set; }
        [Required(ErrorMessage = "Password is required")]
        [Display(Name = "Password")]
        public string password { get; set; }
    }
}
