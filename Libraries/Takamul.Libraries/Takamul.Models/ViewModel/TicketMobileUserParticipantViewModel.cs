using Data.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
   public class TicketMobileUserParticipantViewModel
    {
        public int TICKET_ID { get; set; }
        public int USER_ID { get; set; }
        public int PREFERED_LANGUAGE_ID { get; set; }
       
        public string FULL_NAME { get; set; }
        public string TICKET_NAME { get; set; }
        public string DEVICE_ID { get; set; }

        public Languages PreferedLanguage
        {
            get
            {
                Languages oLanguages = PREFERED_LANGUAGE_ID == 2 ? Languages.English : Languages.Arabic;
                return oLanguages;
            }
        }


        public TicketMobileUserParticipantViewModel()
        {
            this.TICKET_ID = -99;
            this.USER_ID = -99;
            this.DEVICE_ID = string.Empty;
            this.FULL_NAME = string.Empty;
            this.TICKET_NAME = string.Empty;
            
        }
    }
}
