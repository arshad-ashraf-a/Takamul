/****************************************************************************************************/
/* Class Name           : NotificationLogViewModel.cs                                               */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of notificatin log data                                     */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
    public class NotificationLogViewModel
    {
        public int ID { get; set; }
        public int APPLICATION_ID { get; set; }
        public string NOTIFICATION_TYPE { get; set; }
        public string REQUEST_JSON { get; set; }
        public string RESPONSE_MESSAGE { get; set; }
        public string MOBILE_NUMBERS { get; set; }
        public bool IS_SENT_NOTIFICATION { get; set; }
        public DateTime CREATED_DATE { get; set; }
        public int TotalCount { get; set; }

        #region :: Constructor ::
        public NotificationLogViewModel()
        {
            this.ID = -99;
            this.APPLICATION_ID = -99;
            this.NOTIFICATION_TYPE = string.Empty;
            this.REQUEST_JSON = string.Empty;
            this.RESPONSE_MESSAGE = string.Empty;
            this.MOBILE_NUMBERS = string.Empty;
            this.IS_SENT_NOTIFICATION = false;
            this.TotalCount = 0;
        } 
        #endregion
    }
}
