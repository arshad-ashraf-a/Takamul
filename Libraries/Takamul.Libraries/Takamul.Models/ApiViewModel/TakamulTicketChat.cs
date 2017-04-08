/****************************************************************************************************/
/* Class Name           : TakamulTicketChat.cs                                                            */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of ticket chats data                                                */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ApiViewModel
{
    public class TakamulTicketChat
    {
        public int ApplicationID { get; set; }
        public int TicketID { get; set; }
        public int TicketChatID { get; set; }
        public string ReplyMessage { get; set; }
        public DateTime ReplyDate{ get; set; }
        public string Base64ReplyImage { get; set; }
        public int UserID { get; set; }
        public int TicketChatTypeID { get; set; }
        public string TicketChatTypeName { get; set; }
        public string UserFullName { get; set; }

        #region :: Constructor ::
        public TakamulTicketChat()
        {
            this.ApplicationID = -99;
            this.TicketID = -99;
            this.TicketChatID = -99;
            this.TicketChatTypeID = -99;
            this.UserID = -99;
            this.ReplyMessage = string.Empty;
            this.ReplyDate = DateTime.MinValue;
            this.Base64ReplyImage = string.Empty;
            this.TicketChatTypeName = string.Empty;
            this.UserFullName = string.Empty;
        } 
        #endregion
    }
}
