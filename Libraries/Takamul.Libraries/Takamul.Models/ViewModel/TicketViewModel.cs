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
        public string TICKET_CODE { get; set; }
        public string TICKET_DESCRIPTION { get; set; }
        public string DEFAULT_IMAGE { get; set; }
        public int TICKET_STATUS_ID { get; set; }
        public string TICKET_STATUS_NAME { get; set; }
        public string TICKET_STATUS_REMARK { get; set; }
        public bool IS_ACTIVE { get; set; }
        public bool IS_NOTIFY_USER { get; set; }
        public int CREATED_BY { get; set; }
        public DateTime CREATED_DATE { get; set; }
        public Nullable<int> MODIFIED_BY { get; set; }
        public Nullable<DateTime> MODIFIED_DATE { get; set; }
        public string MobileParticipantName { get; set; }
        public int MobileParticipantId { get; set; }
        public int TotalCount { get; set; }

        public String LastTicketChatMessage { get; set; }
        public Nullable<DateTime> LastTicketChatCreatedDate { get; set; }

        public int? TICKET_OWNER_USER_ID { get; set; }
        public string TicketOwnerUserFullName { get; set; }
        public Nullable<int> TICKET_CREATED_PLATFORM { get; set; }
        public int TicketParticipantNos { get; set; }
        public int TICKET_CATEGORY_ID { get; set; }
        public string CATEGORY_NAME { get; set; }

        #region :: Constructor ::
        public TicketViewModel()
        {
            this.ID = -99;
            this.APPLICATION_ID = -99;
            this.TICKET_STATUS_ID = -99;
            this.TICKET_NAME = string.Empty;
            this.TICKET_CODE = string.Empty;
            this.TICKET_DESCRIPTION = string.Empty;
            this.DEFAULT_IMAGE = string.Empty;
            this.TICKET_STATUS_NAME = string.Empty;
            this.TICKET_STATUS_REMARK = string.Empty;
            this.IS_ACTIVE = false;
            this.IS_NOTIFY_USER = false;
            this.TotalCount = 0;
            this.CREATED_BY = -99;
            this.CREATED_DATE = DateTime.MinValue;
            this.MODIFIED_BY = -99;
            this.MODIFIED_DATE = DateTime.MinValue;
            this.LastTicketChatMessage = string.Empty;
            this.MobileParticipantName = string.Empty;
            this.LastTicketChatCreatedDate = DateTime.MinValue;

            this.TICKET_OWNER_USER_ID = -99;
            this.TicketOwnerUserFullName = string.Empty;
            this.TICKET_CREATED_PLATFORM = -99;
            this.TicketParticipantNos = 0;
            this.TICKET_CATEGORY_ID = -99;
            this.CATEGORY_NAME = string.Empty;
        } 
        #endregion
    }
}
