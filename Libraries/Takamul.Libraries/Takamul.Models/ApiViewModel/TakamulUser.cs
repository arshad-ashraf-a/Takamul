/****************************************************************************************************/
/* Class Name           : TakamulUser.cs                                                            */
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

namespace Takamul.Models.ApiViewModel
{
    public class TakamulUser
    {
        public int UserID { get; set; }
        public int ApplicationID { get; set; }
        public string PhoneNumber { get; set; }
        public string Email { get; set; }
        public string FullName { get; set; }
        public string CivilID { get; set; }
        public string Addresss { get; set; }
        public string AreaName { get; set; }
        public string WilayatName { get; set; }
        public string VillageName { get; set; }
        public int AreaID { get; set; }
        public int WilayatID { get; set; }
        public int VillageID { get; set; }
        public bool IsUserBlocked { get; set; }
        public string BlockedRemarks { get; set; }
        public bool IsActive { get; set; }
        public bool IsOTPVerified { get; set; }
        public bool IsSmsSent { get; set; }
        public bool IsTicketSubmissionRestricted { get; set; }
        public int TicketSubmissionIntervalDays { get; set; }

        #region :: Constructor ::
        public TakamulUser()
        {
            this.UserID = -99;
            this.ApplicationID = -99;
            this.PhoneNumber = string.Empty;
            this.Email = string.Empty;
            this.FullName = string.Empty;
            this.AreaName = string.Empty;
            this.WilayatName = string.Empty;
            this.VillageName = string.Empty;
            this.CivilID = string.Empty;
            this.Addresss = string.Empty;
            this.AreaID = -99;
            this.WilayatID = -99;
            this.VillageID = -99;
            this.IsUserBlocked = false;
            this.BlockedRemarks = string.Empty;
            this.IsActive = false;
            this.IsOTPVerified = false;
            this.IsSmsSent = false;
            this.IsTicketSubmissionRestricted = false;
            this.TicketSubmissionIntervalDays = 0;
        } 
        #endregion
    }
}
