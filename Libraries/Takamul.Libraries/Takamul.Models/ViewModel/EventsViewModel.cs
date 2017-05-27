/****************************************************************************************************/
/* Class Name           : EventsViewModel.cs                                                          */
/* Designed BY          : Samh Khalid                                                             */
/* Created BY           : Samh Khalid                                                              */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : Purpose - Hold events data protected mode internally                                              */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models
{
    public class EventViewModel
    {
        public int ID { get; set; }
        public int APPLICATION_ID { get; set; }
        public string EVENT_NAME { get; set; }  
        public string EVENT_DESCRIPTION { get; set; }
        public DateTime EVENT_DATE { get; set; }
        public string EVENT_LOCATION_NAME { get; set; }
        public string EVENT_LATITUDE { get; set; }
        public string EVENT_LONGITUDE { get; set; }
        public int CREATED_BY { get; set; }
        public DateTime CREATED_DATE { get; set; }
        public Nullable<int> MODIFIED_BY { get; set; }
        public Nullable<DateTime> MODIFIED_DATE { get; set; }
        public bool IS_ACTIVE { get; set; }
        public int TotalCount { get; set; }
        public string EVENT_IMG_FILE_PATH { get; set; }
        public float Latitude { get; set; }
        public float Longitude { get; set; }
        public string BASE64EVENTIMG { set; get; }


        #region :: Constructor ::
        public EventViewModel()
        {
            this.ID = -99;
            this.APPLICATION_ID = -99;
            this.EVENT_NAME = string.Empty;
            this.EVENT_DESCRIPTION = string.Empty;
            this.EVENT_DATE = DateTime.MinValue;
            this.EVENT_LOCATION_NAME = string.Empty;
            this.EVENT_LATITUDE = string.Empty;
            this.EVENT_LONGITUDE = string.Empty;
            this.CREATED_BY = -99;
            this.CREATED_DATE = DateTime.MinValue;
            this.MODIFIED_BY = -99;
            this.MODIFIED_DATE = DateTime.MinValue;
            this.IS_ACTIVE = false;
            this.TotalCount = 0;
            this.EVENT_IMG_FILE_PATH = string.Empty;
        }
        #endregion
    }
}
