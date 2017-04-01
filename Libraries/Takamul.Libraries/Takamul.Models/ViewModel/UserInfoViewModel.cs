/****************************************************************************************************/
/* Class Name           : UserInfoViewModel.cs                                                      */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of user data                                                */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
    public class UserInfoViewModel
    {
        public int ID { get; set; }
        public int APPLICATION_ID { get; set; }
        public int USER_TYPE_ID { get; set; }
        public int USER_ID { get; set; }
        public string FULL_NAME { get; set; }
        public string PHONE_NUMBER { get; set; }
        public string EMAIL { get; set; }
        public string CIVIL_ID { get; set; }
        public string ADDRESS { get; set; }
        public int AREA_ID { get; set; }
        public int WILAYAT_ID { get; set; }
        public int VILLAGE_ID { get; set; }
        public int OTP_NUMBER { get; set; }
        public bool IS_ACTIVE { get; set; }
        public bool IS_BLOCKED { get; set; }
        public bool SMS_SENT_STATUS { get; set; }
        public bool IS_OTP_VALIDATED { get; set; }
        public string BLOCKED_REMARKS { get; set; }
        public bool IS_TICKET_SUBMISSION_RESTRICTED { get; set; }
        public int TICKET_SUBMISSION_INTERVAL_DAYS { get; set; }

        #region :: Constructor ::
        public UserInfoViewModel()
        {
            this.ID = -99;
            this.APPLICATION_ID = -99;
            this.USER_TYPE_ID = -99;
            this.USER_ID = -99;
            this.FULL_NAME = string.Empty;
            this.PHONE_NUMBER = string.Empty;
            this.EMAIL = string.Empty;
            this.CIVIL_ID = string.Empty;
            this.ADDRESS = string.Empty;
            this.AREA_ID = -99;
            this.WILAYAT_ID = -99;
            this.VILLAGE_ID = -99;
            this.OTP_NUMBER = -99;
            this.IS_BLOCKED = false;
            this.IS_ACTIVE = false;
            this.SMS_SENT_STATUS = false;
            this.IS_OTP_VALIDATED = false;
            this.BLOCKED_REMARKS = string.Empty;
            this.IS_TICKET_SUBMISSION_RESTRICTED = false;
            this.TICKET_SUBMISSION_INTERVAL_DAYS = 0;
        } 
        #endregion
    }
}
