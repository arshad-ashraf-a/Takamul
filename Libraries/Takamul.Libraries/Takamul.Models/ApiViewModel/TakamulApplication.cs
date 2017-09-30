/****************************************************************************************************/
/* Class Name           : TakamulApplication.cs                                                       */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of application data                                              */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ApiViewModel
{
    public class TakamulApplication
    {
        public int ApplicationID { get; set; }
        public string ApplicationName { get; set; }
        public string Base64ApplicationLogo { get; set; }
        public string ApplicationToken { get; set; }
        public string DefaultThemeColor { get; set; }
        public string RemoteFilePath { get; set; }
        public bool IsActive { get; set; }
        public bool IsApplicationExpired { get; set; }
        public string PlayStoreURL { get; set; }
        public string AppleStoreURL { get; set; }

        #region :: Constructor ::
        public TakamulApplication()
        {
            this.ApplicationID = -99;
            this.ApplicationName = string.Empty;
            this.Base64ApplicationLogo = string.Empty;
            this.ApplicationToken = string.Empty;
            this.DefaultThemeColor = string.Empty;
            this.IsActive = false;
            this.IsApplicationExpired = false;
            this.RemoteFilePath = string.Empty;
            this.PlayStoreURL = string.Empty;
            this.AppleStoreURL = string.Empty;

        }
        #endregion
    }
}
