using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
   public class SMSViewModel
    {
        public int Language { get; set; }
        public string Message { get; set; }
        public string Recipient { get; set; }
        public int RecipientType { get; set; }
        private class ArrayOfString : System.Collections.Generic.List<string>
        {
        }
    }
}
