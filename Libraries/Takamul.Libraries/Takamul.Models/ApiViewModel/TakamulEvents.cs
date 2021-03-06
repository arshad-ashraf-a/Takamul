﻿/****************************************************************************************************/
/* Class Name           : TakamulEvents.cs                                                            */
/* Designed BY          : Samh Khalid                                                             */
/* Created BY           : Samh Khalid                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : Purpose - Hold events data globally to expose to outside.                                                */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ApiViewModel
{
    public class TakamulEvents
    {
        public int EventID { get; set; }
        public int APPLICATIONID { get; set; }
        public string EVENTNAME { get; set; }
        public string EVENTDESCRIPTION { get; set; }
        public string BASE64EVENTIMG { get; set; }
        public string EVENTDATE { get; set; }
        public string Latitude { get; set; }
        public string Longitude { get; set; }
        public string RemoteFilePath { get; set; }
        public string EventLocation { get; set; }

        #region :: Constructor ::
        public TakamulEvents()
        {
            this.EventID = -99;
            this.APPLICATIONID = -99;
            this.EVENTNAME = string.Empty;
            this.EVENTDESCRIPTION = string.Empty;
            this.BASE64EVENTIMG = string.Empty;
            this.EVENTDATE = string.Empty;
            this.Latitude = string.Empty;
            this.Longitude = string.Empty;
            this.RemoteFilePath = string.Empty;
            this.EventLocation = string.Empty;
        } 
        #endregion
    }
}
