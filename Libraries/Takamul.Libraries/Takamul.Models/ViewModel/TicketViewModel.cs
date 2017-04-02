/****************************************************************************************************/
/* Class Name           : TicketViewModel.cs                                                          */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of ticket data                                                */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
    public class TicketViewModel
    {
        public int ID { get; set; }
        public int APPLICATION_ID { get; set; }
        public string TICKET_NAME { get; set; }
        public string TICKET_DESCRIPTION { get; set; }
        public string DEFAULT_IMAGE { get; set; }
        public int TICKET_STATUS_ID { get; set; }
        public string TICKET_STATUS_NAME { get; set; }
        public string TICKET_STATUS_REMARK { get; set; }
        public bool IS_ACTIVE { get; set; }
        public bool IS_NOTIFY_USER { get; set; }

        #region :: Constructor ::
        public TicketViewModel()
        {
            this.ID = -99;
            this.APPLICATION_ID = -99;
            this.TICKET_STATUS_ID = -99;
            this.TICKET_NAME = string.Empty;
            this.TICKET_DESCRIPTION = string.Empty;
            this.DEFAULT_IMAGE = string.Empty;
            this.TICKET_STATUS_NAME = string.Empty;
            this.TICKET_STATUS_REMARK = string.Empty;
            this.IS_ACTIVE = false;
            this.IS_NOTIFY_USER = false;
        } 
        #endregion
    }
}
