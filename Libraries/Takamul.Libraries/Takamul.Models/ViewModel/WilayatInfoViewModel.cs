/****************************************************************************************************/
/* Class Name           : AreaInfo.cs                                                            */
/* Designed BY          : Samh Khalid                                                             */
/* Created BY           : Samh Khalid                                                             */
/* Creation Date        : 01.04.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : Purpose - Retrieve list of wilayats for registration purpose             */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Takamul.Models.ViewModel
{
  public  class WilayatInfoViewModel
    {


        public string WILAYATCODE { get; set; }
        public string WILLAYATNAMEAR { get; set; }
        public string WILLAYATNAME { get; set; }


        #region :: Constructor ::
        public WilayatInfoViewModel()
        {
            this.WILAYATCODE = string.Empty;
            this.WILLAYATNAMEAR = string.Empty;
            this.WILLAYATNAME = string.Empty;
        }
        #endregion

    }
}
