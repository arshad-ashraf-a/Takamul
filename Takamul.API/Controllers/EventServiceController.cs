﻿/*************************************************************************************************/
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
using System.IO;
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
            var lstEvents = this.oIEventsServices.IlGetAllActiveEvents(nApplicationID, nLanguageID);
            if (lstEvents.Count() > 0)
            {
                lstTakamulEvents = new List<TakamulEvents>();
                foreach (var oEvent in lstEvents)
                {
                    string sRemoteFilePath = string.Empty;
                    if (!string.IsNullOrEmpty(oEvent.EVENT_IMG_FILE_PATH))
                    {
                        sRemoteFilePath = Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.RemoteFileServerPath), oEvent.EVENT_IMG_FILE_PATH);
                    }

                    TakamulEvents oTakamulEvents = new TakamulEvents()
                    {
                        EventID = oEvent.ID,
                        APPLICATIONID = oEvent.APPLICATION_ID,
                        EVENTDESCRIPTION = oEvent.EVENT_DESCRIPTION,
                        EVENTNAME = oEvent.EVENT_NAME,
                        EVENTDATE = string.Format("{0} {1}", oEvent.EVENT_DATE.ToShortDateString(), oEvent.EVENT_DATE.ToShortTimeString()),
                        Latitude = oEvent.EVENT_LATITUDE,
                        Longitude = oEvent.EVENT_LONGITUDE,
                        RemoteFilePath = sRemoteFilePath,
                        EventLocation = oEvent.EVENT_LOCATION_NAME
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
                string sRemoteFilePath = string.Empty;
                if (!string.IsNullOrEmpty(oEventsViewModel.EVENT_IMG_FILE_PATH))
                {
                    sRemoteFilePath = Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.RemoteFileServerPath), oEventsViewModel.EVENT_IMG_FILE_PATH);
                }

                oTakamulEvents = new TakamulEvents()
                {
                    EventID = oEventsViewModel.ID,
                    APPLICATIONID = oEventsViewModel.APPLICATION_ID,
                    EVENTDESCRIPTION = oEventsViewModel.EVENT_DESCRIPTION,
                    EVENTNAME = oEventsViewModel.EVENT_NAME,
                    EVENTDATE = string.Format("{0} {1}", oEventsViewModel.EVENT_DATE.ToShortDateString(), oEventsViewModel.EVENT_DATE.ToShortTimeString()),
                    Latitude = oEventsViewModel.EVENT_LATITUDE,
                    Longitude = oEventsViewModel.EVENT_LONGITUDE,
                    RemoteFilePath = sRemoteFilePath,
                    EventLocation = oEventsViewModel.EVENT_LOCATION_NAME
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
                foreach (var oEvent in lstEvents)
                {
                    string sRemoteFilePath = string.Empty;
                    if (!string.IsNullOrEmpty(oEvent.EVENT_IMG_FILE_PATH))
                    {
                        sRemoteFilePath = Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.RemoteFileServerPath), oEvent.EVENT_IMG_FILE_PATH);
                    }

                    TakamulEvents oTakamulEvents = new TakamulEvents()
                    {
                        EventID = oEvent.ID,
                        APPLICATIONID = oEvent.APPLICATION_ID,
                        EVENTDESCRIPTION = oEvent.EVENT_DESCRIPTION,
                        EVENTNAME = oEvent.EVENT_NAME,
                        EVENTDATE = string.Format("{0} {1}", oEvent.EVENT_DATE.ToShortDateString(), oEvent.EVENT_DATE.ToShortTimeString()),
                        Latitude = oEvent.EVENT_LATITUDE,
                        Longitude = oEvent.EVENT_LONGITUDE,
                        RemoteFilePath = sRemoteFilePath,
                        EventLocation = oEvent.EVENT_LOCATION_NAME
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
