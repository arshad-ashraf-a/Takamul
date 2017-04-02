/****************************************************************************************************/
/* Class Name           : TakamulMembeInfo.cs                                                       */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of member data                                              */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ApiViewModel
{
    public class TakamulMembeInfo
    {
        public int ApplicationID { get; set; }
        public string MemberInfoTitle { get; set; }
        public string MemberInfoDesc { get; set; }

        #region :: Constructor ::
        public TakamulMembeInfo()
        {
            this.ApplicationID = -99;
            this.MemberInfoTitle = string.Empty;
            this.MemberInfoDesc = string.Empty;
        } 
        #endregion
    }
}
