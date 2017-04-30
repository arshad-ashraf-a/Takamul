/*************************************************************************************************/
/* Class Name           : EventServiceController.cs                                               */
/* Designed BY          : Samh                                                         */
/* Created BY           : Samh                                                         */
/* Creation Date        : 31.03.2017 03:01 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage Events operations                                                 */
/*************************************************************************************************/

using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Http.Cors;
using Takamul.Models.ApiViewModel;
using Takamul.Models.ViewModel;
using Takamul.Services;
using Takamul.Services.Events;

namespace Takamul.API.Controllers
{
    /// <summary>
    /// Event Service
    /// </summary>
    public class EventServiceController : ApiController
    {
        #region ::   State   ::
        #region Private Members
        private readonly IEventsService oIEventsServices;
        #endregion
        #endregion

        #region :: Constructor ::
        public EventServiceController(IEventsService IEventsServicesInitializer)
        {
            oIEventsServices = IEventsServicesInitializer;
        }
        #endregion

        #region :: Methods::

        #region Method :: HttpResponseMessage :: GetAllEvents
        // GET: api/TakamulEvents/GetAllEvents
        /// <summary>
        /// Get all events
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetAllEvents(int nApplicationID)
        {
            List<TakamulEvents> lstTakamulEvents = null;
            var lstEvents = this.oIEventsServices.IlGetAllActiveEvents(nApplicationID);
            if (lstEvents.Count() > 0)
            {
                lstTakamulEvents = new List<TakamulEvents>();
                foreach (var Events in lstEvents)
                {
                    TakamulEvents oTakamulEvents = new TakamulEvents()
                    {
                        EventID = Events.ID,
                        APPLICATIONID = Events.APPLICATION_ID,
                        EVENTDESCRIPTION = Events.EVENT_DESCRIPTION,
                        EVENTNAME = Events.EVENT_NAME
                    };
                    lstTakamulEvents.Add(oTakamulEvents);
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK, lstTakamulEvents);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetEventDetails
        // GET: api/TakamulEvents/GetEventDetails
        /// <summary>
        /// Get event by event id
        /// </summary>
        /// <param name="nEventsID"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetEventDetails(int nEventsID)
        {
            TakamulEvents oTakamulEvents = null;
            EventsViewModel oEventsViewModel = this.oIEventsServices.oGetEventDetails(nEventsID);
            if (oEventsViewModel != null)
            {
                 oTakamulEvents = new TakamulEvents()
                {
                    EventID = oEventsViewModel.ID,
                    APPLICATIONID = oEventsViewModel.APPLICATION_ID,
                    EVENTDESCRIPTION = oEventsViewModel.EVENT_DESCRIPTION,
                    EVENTNAME = oEventsViewModel.EVENT_NAME
                };
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulEvents);
        }
        #endregion 

        #endregion
    }
}
