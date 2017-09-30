/****************************************************************************************************/
/* Class Name           : ApplicationViewModel.cs                                                   */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of application data                                         */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
    public class ApplicationViewModel
    {
        public int ID { get; set; }
        public string APPLICATION_NAME { get; set; }
        public string APPLICATION_LOGO_PATH { get; set; }
        public string DEFAULT_THEME_COLOR { get; set; }
        public DateTime APPLICATION_EXPIRY_DATE { get; set; }
        public string FORMATTED_EXPIRY_DATE { get; set; }
        public string APPLICATION_TOKEN { get; set; }
        public bool IS_ACTIVE { get; set; }
        public int CREATED_BY { get; set; }
        public int? MODIFIED_BY { get; set; }
        public DateTime CREATED_DATE { get; set; }
        public int TotalCount { get; set; }

        public int TotalMobileUserCount { get; set; }
        public int TotalMobileBlockedUserCount { get; set; }
        public int TotalTicketCount { get; set; }
        public int TotalTicketOpenCount { get; set; }
        public int TotalTicketClosedCount { get; set; }
        public int TotalTicketChatCount { get; set; }
        public string MemberName { get; set; }
        public int? MemberUserID { get; set; }
        public string PlayStoreURL { get; set; }
        public string AppleStoreURL { get; set; }

        #region :: Constructor ::
        public ApplicationViewModel()
        {
            this.ID = -99;
            this.APPLICATION_NAME = string.Empty;
            this.APPLICATION_LOGO_PATH = string.Empty;
            this.APPLICATION_EXPIRY_DATE = DateTime.MinValue;
            this.APPLICATION_TOKEN = string.Empty;
            this.DEFAULT_THEME_COLOR = string.Empty;
            this.IS_ACTIVE = false;
            this.CREATED_DATE = DateTime.MinValue;
            this.TotalCount = 0;
            this.CREATED_BY = -99;
            this.FORMATTED_EXPIRY_DATE = string.Empty;
            this.MODIFIED_BY = -99;
            this.PlayStoreURL = string.Empty;
            this.AppleStoreURL = string.Empty;
        } 
        #endregion
    }
}
