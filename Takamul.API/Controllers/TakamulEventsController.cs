/*************************************************************************************************/
/* Class Name           : TakamulEventsController.cs                                               */
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
    public class TakamulEventsController : ApiController
    {
        #region ::   State   ::
        #region Private Members
        private readonly IEventsService oIEventsServices;
        #endregion
        #endregion

        #region :: Constructor ::
        public TakamulEventsController(IEventsService IEventsServicesInitializer)
        {
            oIEventsServices = IEventsServicesInitializer;
        }
        #endregion

        #region :: Methods::

        #region Method :: HttpResponseMessage :: GetAllEvents
        // GET: api/TakamulEvents/GetAllEvents
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
                        EventID = Events.EVENTID,
                        APPLICATIONID = Events.APPLID,
                        EVENTDESCRIPTION = Events.EVENTDESCRIPTION,
                        EVENTNAME = Events.EVENTNAME
                    };
                    lstTakamulEvents.Add(oTakamulEvents);
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK, lstTakamulEvents);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetEventDetails
        // GET: api/TakamulEvents/GetEventDetails
        [HttpGet]
        public HttpResponseMessage GetEventDetails(int nEventsID)
        {
            TakamulEvents oTakamulEvents = null;
            EventsViewModel oEventsViewModel = this.oIEventsServices.oGetEventDetails(nEventsID);
            if (oEventsViewModel != null)
            {
                 oTakamulEvents = new TakamulEvents()
                {
                    EventID = oEventsViewModel.EVENTID,
                    APPLICATIONID = oEventsViewModel.APPLID,
                    EVENTDESCRIPTION = oEventsViewModel.EVENTDESCRIPTION,
                    EVENTNAME = oEventsViewModel.EVENTNAME
                };
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulEvents);
        }
        #endregion 

        #endregion
    }
}
