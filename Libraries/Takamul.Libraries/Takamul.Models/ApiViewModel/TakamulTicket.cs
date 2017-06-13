/****************************************************************************************************/
/* Class Name           : TakamulTicket.cs                                                            */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of ticket data                                                */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ApiViewModel
{
    public class TakamulTicket
    {
        public int TicketID { get; set; }
        [Required]
        public int ApplicationID { get; set; }
        [Required]
        public string TicketName { get; set; }
        public string TicketCode { get; set; }
        public string TicketDescription { get; set; }
        public string Base64DefaultImage { get; set; }
        public int DefaultImageType { get; set; }
        public int TicketStatusID { get; set; }
        public string TicketStatusName { get; set; }
        public string TicketStatusRemark { get; set; }
        public string RemoteFilePath { get; set; }
        public string CreatedDate { get; set; }

        #region :: Constructor ::
        public TakamulTicket()
        {
            this.TicketID = -99;
            this.ApplicationID = -99;
            this.TicketStatusID = -99;
            this.TicketName = string.Empty;
            this.TicketCode = string.Empty;
            this.TicketDescription = string.Empty;
            this.Base64DefaultImage = string.Empty;
            this.TicketStatusName = string.Empty;
            this.TicketStatusRemark = string.Empty;
            this.RemoteFilePath = string.Empty;
            this.CreatedDate = string.Empty;
        }
        #endregion
    }
}
