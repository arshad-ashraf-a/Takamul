/*************************************************************************************************/
/* Class Name           : ApplicationService.cs                                               */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 02:0 PM                                                     */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage application operation                                        */
/*************************************************************************************************/

using System.Collections.Generic;
using System.Data.Entity;
using Data.Core;
using Takamul.Models;
using Takamul.Models.ViewModel;
using System.Data.Common;
using System.Data;
using System.Linq;
using Infrastructure.Core;
using System;

namespace Takamul.Services
{
    public class ApplicationService : EntityService<APPLICATIONS>, IApplicationService
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;
        private IDbSet<APPLICATIONS> oApplicationsDBSet;// Represent DB Set Table For APPLICATIONS
        #endregion

        #region Properties
        #region Property :: ApplicationsDBSet
        /// <summary>
        ///  Get APPLICATIONS DBSet Object
        /// </summary>
        private IDbSet<APPLICATIONS> ApplicationsDBSet
        {
            get
            {
                if (oApplicationsDBSet == null)
                {
                    oApplicationsDBSet = oTakamulConnection.Set<APPLICATIONS>();
                }
                return oApplicationsDBSet;
            }
        }
        #endregion
        #endregion

        #region :: Constructor ::
        public ApplicationService(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<ApplicationViewModel> :: IlGetAllApplications
        /// <summary>
        ///  Get all applications
        /// </summary>
        /// <param name="nSearchByAppliationID"></param>
        /// <param name="sSearchByApplicationName"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public List<ApplicationViewModel> IlGetAllApplications(int nApplicationID, string sSearchByApplicationName, int nPageNumber, int nRowspPage)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationName", SqlDbType.VarChar, sSearchByApplicationName, 200, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, nPageNumber, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, nRowspPage, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<ApplicationViewModel> lstApplications = this.ExecuteStoredProcedureList<ApplicationViewModel>("GetAllApplications", arrParameters.ToArray());
            return lstApplications;
            #endregion
        }
        #endregion

        #region Method :: ApplicationViewModel :: oGetApplicationDetails
        /// <summary>
        ///  Get application details
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        public ApplicationViewModel oGetApplicationDetails(int nApplicationID)
        {
            ApplicationViewModel oApplicationViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<ApplicationViewModel> lstApplications = this.ExecuteStoredProcedureList<ApplicationViewModel>("GetApplicationDetails", arrParameters.ToArray());
            if (lstApplications.Count > 0)
            {
                return lstApplications[0];
            }
            return oApplicationViewModel;
            #endregion

        }
        #endregion

        #region Method :: ApplicationViewModel :: oGetApplicationStatistics
        /// <summary>
        ///  Get application details
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        public ApplicationViewModel oGetApplicationStatistics(int nApplicationID)
        {
            ApplicationViewModel oApplicationViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<ApplicationViewModel> lstApplications = this.ExecuteStoredProcedureList<ApplicationViewModel>("GetApplicationStatistics", arrParameters.ToArray());
            if (lstApplications.Count > 0)
            {
                oApplicationViewModel = lstApplications[0];
            }
            return oApplicationViewModel;
            #endregion

        }
        #endregion

        #region Method :: Response :: oInsertApplication
        /// <summary>
        ///  Insert Application
        /// </summary>
        /// <param name="oApplicationViewModel"></param>
        /// <returns></returns>
        public Response oInsertApplication(ApplicationViewModel oApplicationViewModel)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationName", SqlDbType.NVarChar, oApplicationViewModel.APPLICATION_NAME, 200, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_MemberUserID", SqlDbType.Int, oApplicationViewModel.MemberUserID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationLogoPath", SqlDbType.VarChar, oApplicationViewModel.APPLICATION_LOGO_PATH, 300, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationExpiryDate", SqlDbType.SmallDateTime, oApplicationViewModel.APPLICATION_EXPIRY_DATE, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_CreatedBy", SqlDbType.Int, oApplicationViewModel.CREATED_BY, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_ApplicationID", SqlDbType.Int, ParameterDirection.Output));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("InsertApplication", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[6].Value.ToString());
                if (oResponse.OperationResult == enumOperationResult.Success)
                {
                    //Inserted Application ID
                    oResponse.ResponseID = arrParameters[5].Value.ToString();
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

        #region Method :: Response :: oUpdateApplication
        /// <summary>
        ///  Update Application
        /// </summary>
        /// <param name="oApplicationViewModel"></param>
        /// <returns></returns>
        public Response oUpdateApplication(ApplicationViewModel oApplicationViewModel)
        {
            #region ": Update Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, oApplicationViewModel.ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationName", SqlDbType.NVarChar, oApplicationViewModel.APPLICATION_NAME, 200, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_MemberUserID", SqlDbType.Int, oApplicationViewModel.MemberUserID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationLogoPath", SqlDbType.VarChar, oApplicationViewModel.APPLICATION_LOGO_PATH, 300, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationExpiryDate", SqlDbType.SmallDateTime, oApplicationViewModel.APPLICATION_EXPIRY_DATE, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_IsActive", SqlDbType.Bit, oApplicationViewModel.IS_ACTIVE, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ModifiedBy", SqlDbType.Int, oApplicationViewModel.MODIFIED_BY, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("UpdateApplication", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[7].Value.ToString());
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

        #endregion
    }
}
