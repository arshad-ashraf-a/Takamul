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
        public string APPLICATION_TOKEN { get; set; }
        public bool IS_ACTIVE { get; set; }

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
        } 
        #endregion
    }
}
