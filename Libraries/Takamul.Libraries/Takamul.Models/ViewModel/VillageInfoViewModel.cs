/****************************************************************************************************/
/* Class Name           : AreaInfo.cs                                                            */
/* Designed BY          : Samh Khalid                                                             */
/* Created BY           : Samh Khalid                                                             */
/* Creation Date        : 01.04.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : Purpose - Retrieve list of villages for registration purpose             */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
   public class VillageInfoViewModel
    {

        public string VILLAGECODE { get; set; }
        public string VILLAGENAMEAR { get; set; }
        public string VILLAGENAME { get; set; }


        #region :: Constructor ::
        public VillageInfoViewModel()
        {
            this.VILLAGECODE = string.Empty;
            this.VILLAGENAMEAR = string.Empty;
            this.VILLAGENAME = string.Empty;
        }
        #endregion
    }
}
