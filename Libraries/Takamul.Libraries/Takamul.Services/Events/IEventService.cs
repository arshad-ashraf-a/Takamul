/*************************************************************************************************/
/* Class Name           : IEventService.cs                                                       */
/* Designed BY          : Samh Khalid
/* Created BY           : samh Khalid
/* Creation Date        : 31.03.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Events service                                                           */
/*************************************************************************************************/

using Data.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Takamul.Models;
using Takamul.Models.ViewModel;

namespace Takamul.Services
{
    public interface IEventService
    {
        #region Method :: List<EventsViewModel> :: IlGetAllActiveEvents
        /// <summary>
        /// Get all active events
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns>List of Events</returns>
        List<EventViewModel> IlGetAllActiveEvents(int nApplicationID);
        #endregion

        #region Method :: IPagedList<EventViewModel> :: IlGetAllEvents
        /// <summary>
        /// Get all events
        /// </summary>
        /// <param name="sSearchByEventName"></param>
        /// <param name="nApplicationID"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        IPagedList<EventViewModel> IlGetAllEvents(int nApplicationID, string sSearchByEventName, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder);

        #endregion

        #region Method ::EventsViewModel :: oGetEventsDetails
        /// <summary>
        /// Get events details by eventid
        /// </summary>
        /// <param name="nEventID"></param>
        /// <returns>List of Event</returns>
        EventViewModel oGetEventDetails(int nEventID);
        #endregion

        #region Method :: Response :: InsertEvent
        /// <summary>
        ///  Insert event
        /// </summary>
        /// <param name="oEventViewModel"></param>
        /// <returns>Response</returns>
        Response oInsertEvent(EventViewModel oEventViewModel);
        #endregion

        #region Method :: Response :: UpdateEvent
        /// <summary>
        ///  Update event
        /// </summary>
        /// <param name="oEventViewModel"></param>
        /// <returns>Response</returns>
        Response oUpdateEvent(EventViewModel oEventViewModel);
        #endregion

        #region Method :: Response :: DeleteEvent
        /// <summary>
        /// Delete event
        /// </summary>
        /// <param name="nEventID"></param>
        /// <returns></returns>
        Response oDeleteEvent(int nEventID);
        #endregion

        #region Method ::EventsViewModel :: oGetEventsbyDate
        /// <summary>
        /// Get events details by dEventDate
        /// </summary>
        /// <param name="dEventDate"></param>
        /// <returns>List of Event</returns>
       List<EventViewModel> oGetEventsbyDate(DateTime dEventDate,int nApplicationID);
        #endregion

    }
}
