/*************************************************************************************************/
/* Class Name           : EventServiceController.cs                                               */
/* Designed BY          : Samh                                                         */
/* Created BY           : Samh                                                         */
/* Creation Date        : 31.03.2017 03:01 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage Events operations                                                 */
/*************************************************************************************************/

using Infrastructure.Core;
using Infrastructure.Utilities;
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
using Takamul.Models;
using Takamul.Models.ApiViewModel;
using Takamul.Models.ViewModel;
using Takamul.Services;

namespace Takamul.API.Controllers
{
    /// <summary>
    /// Event Service
    /// </summary>
    public class EventServiceController : ApiController
    {
        #region ::   State   ::
        #region Private Members
        private readonly IEventService oIEventsServices;
        #endregion
        #endregion

        #region :: Constructor ::
        public EventServiceController(IEventService IEventsServicesInitializer)
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
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetAllEvents(int nApplicationID, int nLanguageID)
        {
            List<TakamulEvents> lstTakamulEvents = null;
            var lstEvents = this.oIEventsServices.IlGetAllActiveEvents(nApplicationID);
            if (lstEvents.Count() > 0)
            {
                lstTakamulEvents = new List<TakamulEvents>();
                foreach (var oEvent in lstEvents)
                {
                    string sBase64DefaultImage = string.Empty;
                    if (!string.IsNullOrEmpty(oEvent.EVENT_IMG_FILE_PATH))
                    {
                        FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                        byte[] oByteFile = oFileAccessService.ReadFile(oEvent.EVENT_IMG_FILE_PATH);
                        if (oByteFile.Length > 0)
                        {
                            sBase64DefaultImage = Convert.ToBase64String(oByteFile);
                        }
                    }

                    TakamulEvents oTakamulEvents = new TakamulEvents()
                    {
                        EventID = oEvent.ID,
                        APPLICATIONID = oEvent.APPLICATION_ID,
                        EVENTDESCRIPTION = oEvent.EVENT_DESCRIPTION,
                        EVENTNAME = oEvent.EVENT_NAME,
                        EVENTDATE = oEvent.EVENT_DATE,
                        Latitude = oEvent.EVENT_LATITUDE,
                        Longitude = oEvent.EVENT_LONGITUDE,
                        BASE64EVENTIMG = sBase64DefaultImage
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
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetEventDetails(int nEventsID, int nLanguageID)
        {
            TakamulEvents oTakamulEvents = null;
            EventViewModel oEventsViewModel = this.oIEventsServices.oGetEventDetails(nEventsID);
            if (oEventsViewModel != null)
            {
                string sBase64DefaultImage = string.Empty;
                if (!string.IsNullOrEmpty(oEventsViewModel.EVENT_IMG_FILE_PATH))
                {
                    FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                    byte[] oByteFile = oFileAccessService.ReadFile(oEventsViewModel.EVENT_IMG_FILE_PATH);
                    if (oByteFile.Length > 0)
                    {
                        sBase64DefaultImage = Convert.ToBase64String(oByteFile);
                    }
                }

                oTakamulEvents = new TakamulEvents()
                {
                    EventID = oEventsViewModel.ID,
                    APPLICATIONID = oEventsViewModel.APPLICATION_ID,
                    EVENTDESCRIPTION = oEventsViewModel.EVENT_DESCRIPTION,
                    EVENTNAME = oEventsViewModel.EVENT_NAME,
                    EVENTDATE = oEventsViewModel.EVENT_DATE,
                    Latitude = oEventsViewModel.EVENT_LATITUDE,
                    Longitude = oEventsViewModel.EVENT_LONGITUDE,
                    BASE64EVENTIMG = sBase64DefaultImage
                };
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulEvents);
        }
        #endregion

        #region Method :: HttpResponseMessage :: GetEventsByDate
        // GET: api/TakamulEvents/GetEventsByDate
        /// <summary>
        /// Get all events
        /// </summary>
        /// <param name="dEventDate"></param><param name="nApplicationID"></param>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetEventsByDate(DateTime dEventDate, int nApplicationID, int nLanguageID)
        {
            List<TakamulEvents> lstTakamulEvents = null;
            var lstEvents = this.oIEventsServices.oGetEventsbyDate(dEventDate, nApplicationID);
            if (lstEvents.Count() > 0)
            {
                lstTakamulEvents = new List<TakamulEvents>();
                foreach (var Events in lstEvents)
                {
                    string sBase64DefaultImage = string.Empty;
                    if (!string.IsNullOrEmpty(Events.EVENT_IMG_FILE_PATH))
                    {
                        FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                        byte[] oByteFile = oFileAccessService.ReadFile(Events.EVENT_IMG_FILE_PATH);
                        if (oByteFile.Length > 0)
                        {
                            sBase64DefaultImage = Convert.ToBase64String(oByteFile);
                        }
                    }

                    TakamulEvents oTakamulEvents = new TakamulEvents()
                    {
                        EventID = Events.ID,
                        APPLICATIONID = Events.APPLICATION_ID,
                        EVENTDESCRIPTION = Events.EVENT_DESCRIPTION,
                        EVENTNAME = Events.EVENT_NAME,
                        EVENTDATE = Events.EVENT_DATE,
                        Latitude = Events.EVENT_LATITUDE,
                        Longitude = Events.EVENT_LONGITUDE,
                        BASE64EVENTIMG = sBase64DefaultImage
                    };
                    lstTakamulEvents.Add(oTakamulEvents);
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK, lstTakamulEvents);
        }
        #endregion 

        #endregion
    }
}
