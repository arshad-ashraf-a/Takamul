/****************************************************************************************************/
/* Class Name           : UserInfoViewModel.cs                                                      */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of user data                                                */
/****************************************************************************************************/
using Infrastructure.Core;
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
        public int? APPLICATION_ID { get; set; }
        public int USER_TYPE_ID { get; set; }
        public int USER_ID { get; set; }
        public string USER_NAME { get; set; }
        public string PASSWORD { get; set; }
        public string FULL_NAME { get; set; }
        public string PHONE_NUMBER { get; set; }
        public string EMAIL { get; set; }
        public string CIVIL_ID { get; set; }
        public string ADDRESS { get; set; }
        public Nullable<int> AREA_ID { get; set; }
        public Nullable<int> WILAYAT_ID { get; set; }
        public Nullable<int> VILLAGE_ID { get; set; }
        public Nullable<int> OTP_NUMBER { get; set; }
        public Nullable<bool> IS_ACTIVE { get; set; }
        public Nullable<bool> IS_BLOCKED { get; set; }
        public Nullable<bool> SMS_SENT_STATUS { get; set; }
        public Nullable<bool> IS_OTP_VALIDATED { get; set; }
        public string BLOCKED_REMARKS { get; set; }
        public Nullable<bool> IS_TICKET_SUBMISSION_RESTRICTED { get; set; }
        public Nullable<int> TICKET_SUBMISSION_INTERVAL_DAYS { get; set; }
        public Nullable<DateTime> LAST_TICKET_SUBMISSION_DATE { get; set; }
        public string USER_TYPE_NAME { get; set; }
        public string AREA_DESC_ARB { get; set; }
        public string AREA_DESC_ENG { get; set; }
        public string WILAYAT_DESC_ARB { get; set; }
        public string WILAYAT_DESC_ENG { get; set; }
        public string VILLAGE_DESC_ARB { get; set; }
        public string VILLAGE_DESC_ENG { get; set; }
        public Nullable<int> CREATED_BY { get; set; }
        public Nullable<int> MODIFIED_BY { get; set; }
        public Nullable<DateTime> CREATED_DATE { get; set; }
        public Nullable<DateTime> MODIFIED_DATE { get; set; }
        public enumUserType UserType { get; set; }
        public string APPLICATION_NAME { get; set; }
        public string DEVICE_ID { get; set; }

        #region :: Constructor ::
        public UserInfoViewModel()
        {
            this.ID = -99;
            this.APPLICATION_ID = -99;
            this.USER_TYPE_ID = -99;
            this.USER_ID = -99;
            this.USER_NAME = string.Empty;
            this.PASSWORD = string.Empty;
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
            this.LAST_TICKET_SUBMISSION_DATE = DateTime.MinValue;
            this.USER_TYPE_NAME = string.Empty;
            this.AREA_DESC_ARB = string.Empty;
            this.AREA_DESC_ENG = string.Empty;
            this.WILAYAT_DESC_ARB = string.Empty;
            this.WILAYAT_DESC_ENG = string.Empty;
            this.VILLAGE_DESC_ARB = string.Empty;
            this.VILLAGE_DESC_ENG = string.Empty;
            this.CREATED_DATE = DateTime.MinValue;
            this.MODIFIED_DATE = DateTime.MinValue;
            this.CREATED_BY = -99;
            this.MODIFIED_BY = -99;
            this.UserType = enumUserType.Undefined;
            this.APPLICATION_NAME = string.Empty;
            this.DEVICE_ID = string.Empty;
        }
        #endregion
    }
}
