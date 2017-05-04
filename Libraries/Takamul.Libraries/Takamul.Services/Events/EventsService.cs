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
using System;

namespace Takamul.Services.Events
{
   public class EventsService : EntityService<Lookup>, IEventsService
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;

        #endregion

        #region Properties

        #endregion

        #region :: Constructor ::
        public EventsService(DbContext oDataBaseContextIntialization) :
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
        /// <returns>List of Events</returns>
        public List<EventsViewModel> IlGetAllActiveEvents(int nApplicationID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_EventsId", SqlDbType.Int, -99, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<EventsViewModel> lstEvents = this.ExecuteStoredProcedureList<EventsViewModel>("GetAllActiveEvents", arrParameters.ToArray());
            return lstEvents;
            #endregion
        }
        #endregion 

        #region Method :: EventViewModel :: oGetEventsDetails
        /// <summary>
        /// Get events details by event id
        /// </summary>
        /// <param name="nEventID"></param>
        /// <returns>List of Events</returns>
        public EventsViewModel oGetEventDetails(int nEventID)
        {
            EventsViewModel oEventsViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_EventId", SqlDbType.Int, nEventID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<EventsViewModel> lstEvents = this.ExecuteStoredProcedureList<EventsViewModel>("GetAllActiveEvents", arrParameters.ToArray());
            if (lstEvents.Count > 0)
            {
                return lstEvents[0];
            }
            return oEventsViewModel;
            #endregion
        }
        #endregion 

        #region Method :: EventViewModel :: oGetEventsDetails
        /// <summary>
        /// Get events details by event id
        /// </summary>
        /// <param name="dEventDate"></param><param name="nApplicationID"></param>
        /// <returns>List of Events</returns>
        public List<EventsViewModel> oGetEventsbyDate(DateTime dEventDate,int nApplicationID)
        {
            EventsViewModel oEventsViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Eventdate", SqlDbType.Date, dEventDate, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<EventsViewModel> lstEvents = new List<EventsViewModel>();
            lstEvents = this.ExecuteStoredProcedureList<EventsViewModel>("GetEventsByDate", arrParameters.ToArray());
            
            return lstEvents;
            #endregion
        }
        #endregion 

        #endregion

    }
}
