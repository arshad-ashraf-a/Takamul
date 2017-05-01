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

        #region Method :: IPagedList<AREA_MASTER> :: IlGetAllAreaMasters
        /// <summary>
        /// Get all area masters
        /// </summary>
        /// <param name="sSearchByAreaName"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public IPagedList<ApplicationViewModel> IlGetAllAreaMasters(string sSearchByAreaName, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder)
        {
            #region Build Left Join Query And Keep All Query Source As IQueryable To Avoid Any Immediate Execution DataBase
            var lstAreaMasters = (from c in this.ApplicationsDBSet
                                  where sSearchByAreaName == null || c.AREA_NAME.Contains(sSearchByAreaName)
                                  orderby c.AREA_ID descending
                                  select new
                                  {
                                      AREA_ID = c.AREA_ID,
                                      AREA_NAME = c.AREA_NAME,
                                      AREA_DESCRIPTION = c.AREA_DESCRIPTION

                                  });
            #endregion

            #region Execute The Query And Return Page Result
            var oTempAreaMastersPagedResult = new PagedList<dynamic>(lstAreaMasters, nPageIndex - 1, nPageSize, sColumnName, sColumnOrder);
            int nTotal = oTempAreaMastersPagedResult.TotalCount;
            PagedList<ApplicationViewModel> plstAreaMaster = new PagedList<APPLICATIONS>(oTempAreaMastersPagedResult.Select(oAreaMasterPagedResult => new ApplicationViewModel
            {
                AREA_ID = oAreaMasterPagedResult.AREA_ID,
                AREA_NAME = oAreaMasterPagedResult.AREA_NAME,
                AREA_DESCRIPTION = oAreaMasterPagedResult.AREA_DESCRIPTION


            }), oTempAreaMastersPagedResult.PageIndex, oTempAreaMastersPagedResult.PageSize, oTempAreaMastersPagedResult.TotalCount);

            //if (plstAreaMaster.Count > 0)
            //{
            //    plstAreaMaster[0].TotalCount = nTotal;
            //}

            return plstAreaMaster;
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
