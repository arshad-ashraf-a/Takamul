/*************************************************************************************************/
/* Class Name           : NewsServices.cs                                                        */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 02:0 PM                                                     */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage news operations                                                 */
/*************************************************************************************************/

using System.Collections.Generic;
using System.Data.Entity;
using Data.Core;
using Takamul.Models;
using Takamul.Models.ViewModel;
using System.Data.Common;
using System.Data;
using Infrastructure.Core;
using System;

namespace Takamul.Services
{
    public class CommonServices : EntityService<Lookup>, ICommonServices
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;

        #endregion

        #region Properties

        #endregion

        #region :: Constructor ::
        public CommonServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<MemberInfoViewModel> :: oGetMemberInfo
        /// <summary>
        /// Get member info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nLaguageID"></param>
        /// <returns>List of News</returns>
        public List<MemberInfoViewModel> oGetMemberInfo(int nApplicationID,int nLaguageID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLaguageID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<MemberInfoViewModel> lstMemberInfo = this.ExecuteStoredProcedureList<MemberInfoViewModel>("GetMemberInfo", arrParameters.ToArray());
            return lstMemberInfo;
            #endregion
        }
        #endregion

        #region Method :: AreaInfo :: oGetAllAreas
        /// <summary>
        /// Get all areas
        /// </summary>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        public List<AreaInfoViewModel> oGetAllAreas(int nLanguageID)
        {

            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLanguageID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<AreaInfoViewModel> lstAreaDetails = this.ExecuteStoredProcedureList<AreaInfoViewModel>("GetAllAreas", arrParameters.ToArray());
            return lstAreaDetails;

            #endregion

        }
        #endregion

        #region Method :: WilayatInfoViewModel :: oGetAllWilayats
        /// <summary>
        ///   Get all wilayat
        /// </summary>
        /// <param name="sAreaCode"></param>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        public List<WilayatInfoViewModel> oGetAllWilayats(string sAreaCode, int nLanguageID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_AreaCode", SqlDbType.VarChar, sAreaCode, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLanguageID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<WilayatInfoViewModel> lstWilayatDetails = this.ExecuteStoredProcedureList<WilayatInfoViewModel>("GetAllWilayats", arrParameters.ToArray());
            return lstWilayatDetails;

            #endregion

        }
        #endregion

        #region Method :: VillageInfoViewModel :: oGetAllVillages
        /// <summary>
        /// Get all villages
        /// </summary>
        /// <param name="sAreaCode"></param>
        /// <param name="sWilayatCode"></param>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        public List<VillageInfoViewModel> oGetAllVillages(string sAreaCode,string sWilayatCode, int nLanguageID)
        {

            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_AreaCode", SqlDbType.VarChar, sAreaCode, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_WilayatCode", SqlDbType.VarChar, sWilayatCode, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLanguageID, ParameterDirection.Input));

            #endregion

            #region ":Get Sp Result:"
            List<VillageInfoViewModel> lstVillage = this.ExecuteStoredProcedureList<VillageInfoViewModel>("GetAllVillages", arrParameters.ToArray());
            return lstVillage;

            #endregion

        }
        #endregion

        #region Method :: Response :: oInsertNotificationLog
        /// <summary>
        ///  Insert Notification Log
        /// </summary>
        /// <param name="oNotificationLogViewModel"></param>
        /// <returns></returns>
        public Response oInsertNotificationLog(NotificationLogViewModel oNotificationLogViewModel)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationID", SqlDbType.Int, oNotificationLogViewModel.APPLICATION_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_NotificationType", SqlDbType.VarChar, oNotificationLogViewModel.NOTIFICATION_TYPE, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RequestJSON", SqlDbType.NVarChar, oNotificationLogViewModel.REQUEST_JSON, 4000, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ResponseMessage", SqlDbType.VarChar, oNotificationLogViewModel.RESPONSE_MESSAGE, 5000, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_MobileNumbers", SqlDbType.VarChar, oNotificationLogViewModel.MOBILE_NUMBERS, 5000, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_IsSentNotification", SqlDbType.Bit, oNotificationLogViewModel.IS_SENT_NOTIFICATION, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("InsertNotificationLog", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[5].Value.ToString());
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

        #region Method :: List<MemberInfoViewModel> :: oGetPushNotificationLogs
        /// <summary>
        /// Get push notification logs
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns>List of Logs</returns>
        public List<NotificationLogViewModel> oGetPushNotificationLogs(int nApplicationID,int nPageNumber,int nRowspPage)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, nPageNumber, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, nRowspPage, ParameterDirection.Input));

            #endregion

            #region ":Get Sp Result:"
            List<NotificationLogViewModel> lstNotificationLogViewModel = this.ExecuteStoredProcedureList<NotificationLogViewModel>("GetPushNotificationLogs", arrParameters.ToArray());
            return lstNotificationLogViewModel;
            #endregion
        }
        #endregion


        #endregion
    }
}
