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
        public int EVENTID { get; set; }
        public int APPLID { get; set; }
        public string EVENTNAME { get; set; }
        public string EVENTDESCRIPTION { get; set; }
        public DateTime EVENTDATE { get; set; }
        public string LOCATIONNAME { get; set; }
        public string LATITUDE { get; set; }
        public string LONGITUDE { get; set; }
        public int CREATEDBY { get; set; }
        public DateTime CRETEDDATE { get; set; }
        public int MODIFIEDBY { get; set; }
        public DateTime MODIFIEDDATE { get; set; }


        #region :: Constructor ::
        public EventsViewModel()
        {
            this.EVENTID = -99;
            this.APPLID = -99;
            this.EVENTNAME = string.Empty;
            this.EVENTDESCRIPTION = string.Empty;
            this.EVENTDATE = Convert.ToDateTime("1/1/1900");
            this.LOCATIONNAME = string.Empty;
            this.LATITUDE = string.Empty;
            this.LONGITUDE = string.Empty;
            this.CREATEDBY = -99;
            this.CRETEDDATE = Convert.ToDateTime("1/1/1900");
            this.MODIFIEDBY = -99;
            this.MODIFIEDDATE = Convert.ToDateTime("1/1/1900"); ;
        }
        #endregion
    }
}
