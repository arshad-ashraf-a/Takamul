/*************************************************************************************************/
/* Class Name           : TicketServices.cs                                                        */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 02:0 PM                                                     */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage ticket operations                                                 */
/*************************************************************************************************/

using System.Collections.Generic;
using System.Data.Entity;
using Data.Core;
using Takamul.Models;
using Takamul.Models.ViewModel;
using System.Data.Common;
using System.Data;

namespace Takamul.Services
{
    public class TicketServices : EntityService<Lookup>, ITicketServices
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;

        #endregion

        #region Properties

        #endregion

        #region :: Constructor ::
        public TicketServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<TicketViewModel> :: IlGetAllActiveTickets
        /// <summary>
        /// Get all active tickets
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nTicketID"></param>
        /// <param name="nUserID"></param>
        /// <returns></returns>
        public List<TicketViewModel> IlGetAllActiveTickets(int nApplicationID, int nTicketID, int nUserID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nUserID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketViewModel> lstTickets = this.ExecuteStoredProcedureList<TicketViewModel>("GetAllActiveTickets", arrParameters.ToArray());
            return lstTickets;
            #endregion
        }
        #endregion

        #region Method :: TicketViewModel :: oGetTicketDetails
        /// <summary>
        /// Get ticket details by ticket id
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        public TicketViewModel oGetTicketDetails(int nTicketID)
        {
            TicketViewModel oTicketViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, -99, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketViewModel> lstTickets = this.ExecuteStoredProcedureList<TicketViewModel>("GetAllActiveTickets", arrParameters.ToArray());
            if (lstTickets.Count > 0)
            {
                return lstTickets[0];
            }
            return oTicketViewModel;
            #endregion
        }
        #endregion

        #region Method :: List<TicketChatViewModel> :: IlGetTicketChats
        /// <summary>
        /// Get all ticket chats
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        public List<TicketChatViewModel> IlGetTicketChats(int nTicketID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketChatViewModel> lstTickets = this.ExecuteStoredProcedureList<TicketChatViewModel>("GetAllActiveTickets", arrParameters.ToArray());
            return lstTickets;
            #endregion
        }
        #endregion

        #endregion
    }
}
