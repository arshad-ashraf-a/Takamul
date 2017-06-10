/****************************************************************************************************/
/* Class Name           : TakamulTicketChatRepo.cs                                                  */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of ticket chat data                                         */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ApiViewModel
{
    public class TakamulTicketChatRepo
    {
        public List<TakamulTicketChat> TakamulTicketChatList { get; set; }
        public TakamulTicket TakamulTicket { get; set; }
        public string RejectReason { get; set; }

        #region :: Constructor ::
        public TakamulTicketChatRepo()
        {
            this.TakamulTicketChatList = new List<TakamulTicketChat>();
            this.TakamulTicket = new TakamulTicket();
            this.RejectReason = string.Empty;
        }
        #endregion
    }
}
