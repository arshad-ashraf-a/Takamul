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

namespace Takamul.Models.ViewModel
{
    public class EventsViewModel
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
        public int MODIFIED_BY { get; set; }
        public DateTime MODIFIED_DATE { get; set; }


        #region :: Constructor ::
        public EventsViewModel()
        {
            this.ID = -99;
            this.APPLICATION_ID = -99;
            this.EVENT_NAME = string.Empty;
            this.EVENT_DESCRIPTION = string.Empty;
            this.EVENT_DATE = Convert.ToDateTime("1/1/1900");
            this.EVENT_LOCATION_NAME = string.Empty;
            this.EVENT_LATITUDE = string.Empty;
            this.EVENT_LONGITUDE = string.Empty;
            this.CREATED_BY = -99;
            this.CREATED_DATE = Convert.ToDateTime("1/1/1900");
            this.MODIFIED_BY = -99;
            this.MODIFIED_DATE = Convert.ToDateTime("1/1/1900"); ;
        }
        #endregion
    }
}
