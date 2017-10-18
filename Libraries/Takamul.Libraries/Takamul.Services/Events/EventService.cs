/*************************************************************************************************/
/* Class Name           : EventsService.cs                                                       */
/* Designed BY          : Samh Khalid
/* Created BY           : samh Khalid
/* Creation Date        : 31.03.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Events service                                                           */
/*************************************************************************************************/

using System.Collections.Generic;
using System.Data.Entity;
using Data.Core;
using Takamul.Models;
using Takamul.Models.ViewModel;
using System.Data.Common;
using System.Data;
using System.Linq;
using System;
using Infrastructure.Core;
using Infrastructure.Utilities;

namespace Takamul.Services
{
    public class EventService : EntityService<Lookup>, IEventService
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;
        private IDbSet<EVENTS> oEventsDBSet;// Represent DB Set Table For EVENTS
        #endregion

        #region Properties
        #region Property :: EventsDBSet
        /// <summary>
        ///  Get EVENTS DBSet Object
        /// </summary>
        private IDbSet<EVENTS> EventsDBSet
        {
            get
            {
                if (oEventsDBSet == null)
                {
                    oEventsDBSet = oTakamulConnection.Set<EVENTS>();
                }
                return oEventsDBSet;
            }
        }
        #endregion
        #endregion

        #region :: Constructor ::
        public EventService(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);
        }
        #endregion

        #region :: Methods ::

        #region Method :: List<EventsViewModel> :: IlGetAllActiveEvents
        /// <summary>
        /// Get all active Events
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nLanguageID"></param>
        /// <returns>List of Events</returns>
        public List<EventViewModel> IlGetAllActiveEvents(int nApplicationID, int nLanguageID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLanguageID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_EventsId", SqlDbType.Int, -99, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<EventViewModel> lstEvents = this.ExecuteStoredProcedureList<EventViewModel>("GetAllActiveEvents", arrParameters.ToArray());
            return lstEvents;
            #endregion
        }
        #endregion

        #region Method :: IPagedList<EventViewModel> :: IlGetAllEvents
        /// <summary>
        /// Get all events
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="sSearchByEventName"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public IPagedList<EventViewModel> IlGetAllEvents(int nApplicationID, string sSearchByEventName, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder, int nLanguageID)
        {
            #region Build Left Join Query And Keep All Query Source As IQueryable To Avoid Any Immediate Execution DataBase
            var lstEvents = (from c in this.EventsDBSet
                             where sSearchByEventName == null || c.EVENT_NAME.Contains(sSearchByEventName)
                             where c.APPLICATION_ID == (int)nApplicationID
                             where c.LANGUAGE_ID == nLanguageID
                             orderby c.ID descending
                             select new
                             {
                                 ID = c.ID,
                                 EVENT_NAME = c.EVENT_NAME,
                                 EVENT_DESCRIPTION = c.EVENT_DESCRIPTION,
                                 EVENT_DATE = c.EVENT_DATE,
                                 EVENT_LOCATION_NAME = c.EVENT_LOCATION_NAME,
                                 EVENT_LATITUDE = c.EVENT_LATITUDE,
                                 EVENT_LONGITUDE = c.EVENT_LONGITUDE,
                                 EVENT_IMG_FILE_PATH = c.EVENT_IMG_FILE_PATH,
                                 IS_ACTIVE = c.IS_ACTIVE,
                                 IS_NOTIFY_USER = c.IS_NOTIFY_USER,
                                 CREATED_DATE = c.CREATED_DATE,

                             });
            #endregion

            #region Execute The Query And Return Page Result
            var oTempEventPagedResult = new PagedList<dynamic>(lstEvents, nPageIndex - 1, nPageSize, sColumnName, sColumnOrder);
            int nTotal = oTempEventPagedResult.TotalCount;
            PagedList<EventViewModel> plstApplicaiton = new PagedList<EventViewModel>(oTempEventPagedResult.Select(oEventPagedResult => new EventViewModel
            {
                ID = oEventPagedResult.ID,
                EVENT_NAME = oEventPagedResult.EVENT_NAME,
                EVENT_DESCRIPTION = oEventPagedResult.EVENT_DESCRIPTION,
                EVENT_DATE = oEventPagedResult.EVENT_DATE,
                EVENT_LOCATION_NAME = oEventPagedResult.EVENT_LOCATION_NAME,
                EVENT_LATITUDE = oEventPagedResult.EVENT_LATITUDE,
                EVENT_LONGITUDE = oEventPagedResult.EVENT_LONGITUDE,
                EVENT_IMG_FILE_PATH = oEventPagedResult.EVENT_IMG_FILE_PATH,
                IS_ACTIVE = oEventPagedResult.IS_ACTIVE,
                IS_NOTIFY_USER = oEventPagedResult.IS_NOTIFY_USER,
                CREATED_DATE = oEventPagedResult.CREATED_DATE,

            }), oTempEventPagedResult.PageIndex, oTempEventPagedResult.PageSize, oTempEventPagedResult.TotalCount);

            if (plstApplicaiton.Count > 0)
            {
                plstApplicaiton[0].TotalCount = nTotal;
            }

            return plstApplicaiton;
            #endregion
        }
        #endregion

        #region Method :: EventViewModel :: oGetEventsDetails
        /// <summary>
        /// Get events details by event id
        /// </summary>
        /// <param name="nEventID"></param>
        /// <returns>List of Events</returns>
        public EventViewModel oGetEventDetails(int nEventID)
        {
            EventViewModel oEventsViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_EventId", SqlDbType.Int, nEventID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<EventViewModel> lstEvents = this.ExecuteStoredProcedureList<EventViewModel>("GetEventDetails", arrParameters.ToArray());
            if (lstEvents.Count > 0)
            {
                return lstEvents[0];
            }
            return oEventsViewModel;
            #endregion
        }
        #endregion one

        #region Method :: Response :: InsertEvent
        /// <summary>
        ///  Insert event
        /// </summary>
        /// <param name="oEventViewModel"></param>
        /// <returns>Response</returns>
        public Response oInsertEvent(EventViewModel oEventViewModel)
        {
            #region ": Insert :"

            Response oResponse = new Response();

            try
            {
                if (oEventViewModel != null)
                {
                    EVENTS oEvent = new EVENTS()
                    {
                        APPLICATION_ID = oEventViewModel.APPLICATION_ID,
                        EVENT_NAME = oEventViewModel.EVENT_NAME,
                        EVENT_DESCRIPTION = oEventViewModel.EVENT_DESCRIPTION,
                        EVENT_DATE = oEventViewModel.EVENT_DATE,
                        EVENT_LOCATION_NAME = oEventViewModel.EVENT_LOCATION_NAME,
                        EVENT_LATITUDE = oEventViewModel.EVENT_LATITUDE,
                        EVENT_LONGITUDE = oEventViewModel.EVENT_LONGITUDE,
                        IS_ACTIVE = oEventViewModel.IS_ACTIVE,
                        IS_NOTIFY_USER = oEventViewModel.IS_NOTIFY_USER,
                        LANGUAGE_ID = oEventViewModel.LANGUAGE_ID,
                        CREATED_BY = oEventViewModel.CREATED_BY,
                        CREATED_DATE = DateTime.Now
                    };
                    if (!oEventViewModel.EVENT_IMG_FILE_PATH.Equals(string.Empty))
                    {
                        oEvent.EVENT_IMG_FILE_PATH = oEventViewModel.EVENT_IMG_FILE_PATH;
                    }

                    this.oTakamulConnection.EVENTS.Add(oEvent);

                    if (this.intCommit() > 0)
                    {
                        oResponse.OperationResult = enumOperationResult.Success;
                        oResponse.ResponseCode = Convert.ToString(oEvent.ID);
                    }
                    else
                    {
                        oResponse.OperationResult = enumOperationResult.Faild;
                        oResponse.ResponseCode = "";
                    }
                }
            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = enumOperationResult.Faild;
                //TODO : Log Error Message
                oResponse.OperationResultMessage = Ex.Message.ToString();

            }

            return oResponse;
            #endregion
        }
        #endregion

        #region Method :: Response :: UpdateEvent
        /// <summary>
        /// Update event
        /// </summary>
        /// <param name="oEventViewModel"></param>
        /// <returns>Response</returns>
        public Response oUpdateEvent(EventViewModel oEventViewModel)
        {
            Response oResponse = new Response();

            #region Try Block

            try
            {
                // Start try

                #region Check oEventViewModel Value
                EVENTS oEvent = new EVENTS();
                oEvent = this.oTakamulConnection.EVENTS.Find(oEventViewModel.ID);

                if (oEvent == null)
                {
                    throw new ArgumentNullException("oEvent Entity Is Null");
                }

                #endregion

                #region Update Default EVENTS

                oEvent.APPLICATION_ID = oEventViewModel.APPLICATION_ID;
                oEvent.EVENT_NAME = oEventViewModel.EVENT_NAME;
                oEvent.EVENT_DESCRIPTION = oEventViewModel.EVENT_DESCRIPTION;
                oEvent.EVENT_DATE = oEventViewModel.EVENT_DATE;
                oEvent.EVENT_LOCATION_NAME = oEventViewModel.EVENT_LOCATION_NAME;
                oEvent.EVENT_LATITUDE = oEventViewModel.EVENT_LATITUDE;
                oEvent.EVENT_LONGITUDE = oEventViewModel.EVENT_LONGITUDE;
                oEvent.IS_ACTIVE = oEventViewModel.IS_ACTIVE;
                oEvent.IS_NOTIFY_USER = oEventViewModel.IS_NOTIFY_USER;
                if (!oEventViewModel.EVENT_IMG_FILE_PATH.Equals(string.Empty))
                {
                    oEvent.EVENT_IMG_FILE_PATH = oEventViewModel.EVENT_IMG_FILE_PATH;
                }
                oEvent.MODIFIED_BY = oEventViewModel.CREATED_BY;
                oEvent.MODIFIED_DATE = DateTime.Now;
                this.EventsDBSet.Attach(oEvent);
                this.oTakamulConnection.Entry(oEvent).State = EntityState.Modified;

                if (this.intCommit() > 0)
                {
                    oResponse.OperationResult = enumOperationResult.Success;
                }
                else
                {
                    oResponse.OperationResult = enumOperationResult.Faild;
                }
                #endregion

            }// End try 
            #endregion

            #region Catch Block
            catch (Exception Ex)
            {// Start Catch
                oResponse.OperationResult = enumOperationResult.Faild;
                //TODO : Log Error Message
                oResponse.OperationResultMessage = Ex.Message.ToString();
            }//End Catch 
            #endregion

            return oResponse;
        }
        #endregion

        #region Method :: Response :: DeleteEvent
        /// <summary>
        /// Delete event
        /// </summary>
        /// <param name="nEventID"></param>
        /// <returns></returns>
        public Response oDeleteEvent(int nEventID)
        {
            #region ": Delete :"

            Response oResponse = new Response();
            try
            {
                this.oTakamulConnection.EVENTS.RemoveRange(this.oTakamulConnection.EVENTS.Where(x => x.ID == nEventID));
                if (this.intCommit() > 0)
                {
                    oResponse.OperationResult = enumOperationResult.Success;
                }
                else
                {
                    oResponse.OperationResult = enumOperationResult.Faild;
                }
            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = enumOperationResult.Faild;
                //TODO : Log Error Message
                oResponse.OperationResultMessage = Ex.Message.ToString();

            }

            return oResponse;
            #endregion
        }
        #endregion

        #region Method :: EventViewModel :: oGetEventsDetails
        /// <summary>
        /// Get events details by event id
        /// </summary>
        /// <param name="dEventDate"></param><param name="nApplicationID"></param>
        /// <returns>List of Events</returns>
        public List<EventViewModel> oGetEventsbyDate(DateTime dEventDate, int nApplicationID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Eventdate", SqlDbType.Date, dEventDate, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<EventViewModel> lstEvents = new List<EventViewModel>();
            lstEvents = this.ExecuteStoredProcedureList<EventViewModel>("GetEventsByDate", arrParameters.ToArray());

            return lstEvents;
            #endregion
        }
        #endregion 

        #endregion

    }
}
