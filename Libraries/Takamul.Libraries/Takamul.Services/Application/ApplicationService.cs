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

        #region Method :: IPagedList<ApplicationViewModel> :: IlGetAllApplications
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
        public IPagedList<ApplicationViewModel> IlGetAllApplications(int nSearchByAppliationID,string sSearchByApplicationName, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder)
        {
            #region Build Left Join Query And Keep All Query Source As IQueryable To Avoid Any Immediate Execution DataBase
            var lstApplications = (from c in this.ApplicationsDBSet
                                  where sSearchByApplicationName == null || c.APPLICATION_NAME.Contains(sSearchByApplicationName)
                                  where nSearchByAppliationID == -99 || c.ID == nSearchByAppliationID
                                  orderby c.ID descending
                                  select new
                                  {
                                      ID = c.ID,
                                      APPLICATION_NAME = c.APPLICATION_NAME,
                                      APPLICATION_EXPIRY_DATE = c.APPLICATION_EXPIRY_DATE,
                                      APPLICATION_LOGO_PATH = c.APPLICATION_LOGO_PATH,
                                      DEFAULT_THEME_COLOR = c.DEFAULT_THEME_COLOR,
                                      IS_ACTIVE = c.IS_ACTIVE,
                                      CREATED_DATE = c.CREATED_DATE,

                                  });
            #endregion

            #region Execute The Query And Return Page Result
            var oTempApplicationPagedResult = new PagedList<dynamic>(lstApplications, nPageIndex - 1, nPageSize, sColumnName, sColumnOrder);
            int nTotal = oTempApplicationPagedResult.TotalCount;
            PagedList<ApplicationViewModel> plstApplicaiton = new PagedList<ApplicationViewModel>(oTempApplicationPagedResult.Select(oApplicationPagedResult => new ApplicationViewModel
            {
                ID = oApplicationPagedResult.ID,
                APPLICATION_NAME = oApplicationPagedResult.APPLICATION_NAME,
                APPLICATION_EXPIRY_DATE = oApplicationPagedResult.APPLICATION_EXPIRY_DATE,
                APPLICATION_LOGO_PATH = oApplicationPagedResult.APPLICATION_LOGO_PATH,
                DEFAULT_THEME_COLOR = oApplicationPagedResult.DEFAULT_THEME_COLOR,
                IS_ACTIVE = oApplicationPagedResult.IS_ACTIVE,
                CREATED_DATE = oApplicationPagedResult.CREATED_DATE,
                
            }), oTempApplicationPagedResult.PageIndex, oTempApplicationPagedResult.PageSize, oTempApplicationPagedResult.TotalCount);

            if (plstApplicaiton.Count > 0)
            {
                plstApplicaiton[0].TotalCount = nTotal;
            }

            return plstApplicaiton;
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


        #endregion
    }
}
