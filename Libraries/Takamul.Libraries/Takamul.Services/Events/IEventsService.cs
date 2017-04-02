/*************************************************************************************************/
/* Class Name           : IEventsService.cs                                                       */
/* Designed BY          : Samh Khalid
/* Created BY           : samh Khalid
/* Creation Date        : 31.03.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Events service                                                           */
/*************************************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Takamul.Models.ViewModel;

namespace Takamul.Services.Events
{
  public  interface IEventsService
    {
        #region Method :: List<EventsViewModel> :: IlGetAllActiveEvents
        /// <summary>
        /// Get all active events
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns>List of Events</returns>
        List<EventsViewModel> IlGetAllActiveEvents(int nApplicationID);
        #endregion

        #region Method ::EventsViewModel :: oGetEventsDetails
        /// <summary>
        /// Get events details by eventid
        /// </summary>
        /// <param name="nEventID"></param>
        /// <returns>List of Event</returns>
        EventsViewModel oGetEventDetails(int nEventID);
        #endregion
    }
}
