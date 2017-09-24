/*************************************************************************************************/
/* Class Name           : ApplicationSettingsService.cs                                          */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 22.09.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Application settings service                                           */
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

namespace Takamul.Services
{
    public class ApplicationSettingsService : EntityService<Lookup>, IApplicationSettingsService
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;
        private IDbSet<APPLICATION_SETTINGS> oApplicationSettingsDBSet;// Represent DB Set Table For APPLICATION_INFO

        #endregion

        #region Properties
        #region Property :: ApplicationSettingsDBSet
        /// <summary>
        ///  Get APPLICATION_SETTINGS DBSet Object
        /// </summary>
        private IDbSet<APPLICATION_SETTINGS> ApplicationSettingsDBSet
        {
            get
            {
                if (oApplicationSettingsDBSet == null)
                {
                    oApplicationSettingsDBSet = oTakamulConnection.Set<APPLICATION_SETTINGS>();
                }
                return oApplicationSettingsDBSet;
            }
        }
        #endregion
        #endregion

        #region :: Constructor ::
        public ApplicationSettingsService(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<ApplicationSettingsViewModel> :: IlGetAllApplicationSettings
        /// <summary>
        /// Get application settings
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public List<ApplicationSettingsViewModel> IlGetAllApplicationSettings(int nApplicationID, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<ApplicationSettingsViewModel> lstApplicationSettings = this.ExecuteStoredProcedureList<ApplicationSettingsViewModel>("GetApplicationSettings", arrParameters.ToArray());
            return lstApplicationSettings;
            #endregion
        }
        #endregion

        #region Method :: Response :: UpdateApplicationSettings
        /// <summary>
        /// Update application settings
        /// </summary>
        /// <param name="oApplicationSettingsViewModel"></param>
        /// <returns>Response</returns>
        public Response oUpdateApplicationSettings(ApplicationSettingsViewModel oApplicationSettingsViewModel)
        {
            #region ": Update Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationSettingsId", SqlDbType.Int, oApplicationSettingsViewModel.ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_SettingsValue", SqlDbType.VarChar, oApplicationSettingsViewModel.SETTINGS_VALUE, 500, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ModifiedBy", SqlDbType.Int, oApplicationSettingsViewModel.MODIFIED_BY, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("UpdateApplicationSettings", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[3].Value.ToString());
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
