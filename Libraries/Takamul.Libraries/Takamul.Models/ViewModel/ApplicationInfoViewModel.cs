/****************************************************************************************************/
/* Class Name           : ApplicationInfoViewModel.cs                                               */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 22.09.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of applicaiton info                                         */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
    public class ApplicationInfoViewModel
    {
        public int ID { get; set; }
        public int APPLICATION_ID { get; set; }
        public string TITLE { get; set; }
        public string DESCRIPTION { get; set; }
        public int CREATED_BY { get; set; }
        public DateTime CREATED_DATE { get; set; }
        public Nullable<int> MODIFIED_BY { get; set; }
        public Nullable<DateTime> MODIFIED_DATE { get; set; }

        public int TotalCount { get; set; }

        #region :: Constructor ::
        public ApplicationInfoViewModel()
        {
            this.ID = -99;
            this.APPLICATION_ID = -99;
            this.TITLE = string.Empty;
            this.DESCRIPTION = string.Empty;
            this.TotalCount = 0;
            this.CREATED_BY = -99;
            this.CREATED_DATE = DateTime.MinValue;
            this.MODIFIED_BY = -99;
            this.MODIFIED_DATE = DateTime.MinValue;
        } 
        #endregion
    }
}
