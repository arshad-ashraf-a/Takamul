/****************************************************************************************************/
/* Class Name           : MemberInfoViewModel.cs                                                    */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of news data                                                */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
    public class MemberInfoViewModel
    {
        public int ID { get; set; }
        public int APPLICATION_ID { get; set; }
        public int USER_ID { get; set; }
        public string MEMBER_INFO_TITLE { get; set; }
        public string MEMBER_INFO_DESCRIPTION { get; set; }

        #region :: Constructor ::
        public MemberInfoViewModel()
        {
            this.ID = -99;
            this.APPLICATION_ID = -99;
            this.USER_ID = -99;
            this.MEMBER_INFO_TITLE = string.Empty;
            this.MEMBER_INFO_DESCRIPTION = string.Empty;
        } 
        #endregion
    }
}
