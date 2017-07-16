/****************************************************************************************************/
/* Class Name           : TicketParticipantViewModel.cs                                             */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 01.07.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : Purpose - Retrieve list of ticket participants                            */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
   public class TicketParticipantViewModel
    {
        public int ID { get; set; }
        public int TICKET_ID { get; set; }
        public int USER_ID { get; set; }
        public string FULL_NAME { get; set; }
        public int TotalCount { get; set; }
        public DateTime CREATED_DATE { get; set; }

        #region :: Constructor ::
        public TicketParticipantViewModel()
        {
            this.ID = -99;
            this.TICKET_ID = -99;
            this.USER_ID = -99;
            this.FULL_NAME = string.Empty;
            this.TotalCount = 0;
            this.CREATED_DATE = DateTime.MinValue;
        }
        #endregion
    }
}
