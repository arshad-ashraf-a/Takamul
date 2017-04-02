/****************************************************************************************************/
/* Class Name           : TicketChatViewModel.cs                                                          */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of ticket chat data                                                */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
    public class TicketChatViewModel
    {
        public int ID { get; set; }
        public int TICKET_ID { get; set; }
        public string REPLY_MESSAGE { get; set; }
        public DateTime REPLIED_DATE { get; set; }
        public string REPLY_FILE_PATH { get; set; }
        public int TICKET_PARTICIPANT_ID { get; set; }
        public int TICKET_CHAT_TYPE_ID { get; set; }
        public string CHAT_TYPE { get; set; }
        public string PARTICIPANT_FULL_NAME { get; set; }

        #region :: Constructor ::
        public TicketChatViewModel()
        {
            this.ID = -99;
            this.TICKET_ID = -99;
            this.TICKET_PARTICIPANT_ID = -99;
            this.REPLY_MESSAGE = string.Empty;
            this.REPLIED_DATE = DateTime.MinValue;
            this.REPLY_FILE_PATH = string.Empty;
            this.TICKET_CHAT_TYPE_ID = -99;
            this.CHAT_TYPE = string.Empty;
            this.PARTICIPANT_FULL_NAME = string.Empty;
        } 
        #endregion
    }
}
