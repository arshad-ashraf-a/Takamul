/****************************************************************************************************/
/* Class Name           : AreaInfo.cs                                                            */
/* Designed BY          : Samh Khalid                                                             */
/* Created BY           : Samh Khalid                                                             */
/* Creation Date        : 01.04.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : Purpose - Retrieve list of areas for registration purpose             */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Takamul.Models.ApiViewModel
{
  public  class AreaInfo
    {

        public String AREACODE { get; set; } 
        public string AREA_NAMEAR { get; set; }
        public string AREA_NAME { get; set; }


        #region :: Constructor ::
        public AreaInfo()
        {
            this.AREACODE = string.Empty;
            this.AREA_NAMEAR = string.Empty;
            this.AREA_NAME = string.Empty;
        }
        #endregion
    }
}
