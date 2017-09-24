/*************************************************************************************************/
/* Class Name           : ApplicationInfoService.cs                                                   */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 22.09.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Application Infor service                                                   */
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
    public class ApplicationInfoService : EntityService<Lookup>, IApplicationInfoService
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;
        private IDbSet<APPLICATION_INFO> oApplicationInfoDBSet;// Represent DB Set Table For APPLICATION_INFO

        #endregion

        #region Properties
        #region Property :: ApplicationInfoDBSet
        /// <summary>
        ///  Get APPLICATION_INFO DBSet Object
        /// </summary>
        private IDbSet<APPLICATION_INFO> ApplicationInfoDBSet
        {
            get
            {
                if (oApplicationInfoDBSet == null)
                {
                    oApplicationInfoDBSet = oTakamulConnection.Set<APPLICATION_INFO>();
                }
                return oApplicationInfoDBSet;
            }
        }
        #endregion
        #endregion

        #region :: Constructor ::
        public ApplicationInfoService(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<ApplicationInfoViewModel> :: lGetAllApplicationInfo
        /// <summary>
        /// Get all application info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        public List<ApplicationInfoViewModel> lGetAllApplicationInfo(int nApplicationID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<ApplicationInfoViewModel> lstApplicationInfo = this.ExecuteStoredProcedureList<ApplicationInfoViewModel>("GetApplicationInfo", arrParameters.ToArray());
            return lstApplicationInfo;
            #endregion
        }
        #endregion

        #region Method :: IPagedList<ApplicationInfoViewModel> :: IlGetAllApplicationInfo
        /// <summary>
        /// Get application info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public IPagedList<ApplicationInfoViewModel> IlGetAllApplicationInfo(int nApplicationID, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder)
        {
            #region Build Left Join Query And Keep All Query Source As IQueryable To Avoid Any Immediate Execution DataBase
            var lstApplicationInfo = (from c in this.ApplicationInfoDBSet
                             where c.APPLICATION_ID == (int)nApplicationID
                             orderby c.ID descending
                             select new
                             {
                                 ID = c.ID,
                                 APPLICATION_ID = c.APPLICATION_ID,
                                 TITLE = c.TITLE,
                                 DESCRIPTION = c.DESCRIPTION
                             });
            #endregion

            #region Execute The Query And Return Page Result
            var oTempApplicationInfoPagedResult = new PagedList<dynamic>(lstApplicationInfo, nPageIndex - 1, nPageSize, sColumnName, sColumnOrder);
            int nTotal = oTempApplicationInfoPagedResult.TotalCount;
            PagedList<ApplicationInfoViewModel> plstApplicationInfo = new PagedList<ApplicationInfoViewModel>(oTempApplicationInfoPagedResult.Select(oApplicationInfoPagedResult => new ApplicationInfoViewModel
            {
                ID = oApplicationInfoPagedResult.ID,
                APPLICATION_ID = oApplicationInfoPagedResult.APPLICATION_ID,
                TITLE = oApplicationInfoPagedResult.TITLE,
                DESCRIPTION = oApplicationInfoPagedResult.DESCRIPTION

            }), oTempApplicationInfoPagedResult.PageIndex, oTempApplicationInfoPagedResult.PageSize, oTempApplicationInfoPagedResult.TotalCount);

            if (plstApplicationInfo.Count > 0)
            {
                plstApplicationInfo[0].TotalCount = nTotal;
            }

            return plstApplicationInfo;
            #endregion
        }
        #endregion

        #region Method :: Response :: InsertApplicationInfo
        /// <summary>
        ///  Insert application info
        /// </summary>
        /// <param name="oApplicationInfoViewModel"></param>
        /// <returns>Response</returns>
        public Response oInsertApplicationInfo(ApplicationInfoViewModel oApplicationInfoViewModel)
        {
            #region ": Insert :"

            Response oResponse = new Response();

            try
            {
                if (oApplicationInfoViewModel != null)
                {
                    var lstMemberInfo = (from c in this.ApplicationInfoDBSet
                                         where c.APPLICATION_ID == oApplicationInfoViewModel.APPLICATION_ID
                                         orderby c.ID descending
                                         select new
                                         {
                                             ID = c.ID,
                                             APPLICATION_ID = c.APPLICATION_ID,
                                             MEMBER_INFO_TITLE = c.TITLE,
                                             DESCRIPTION = c.DESCRIPTION
                                         });
                    if (lstMemberInfo.Count() >= 5 )
                    {
                        oResponse.OperationResult = enumOperationResult.RelatedRecordFaild;
                        return oResponse;
                    }

                    APPLICATION_INFO oAPPLICATION_INFO = new APPLICATION_INFO()
                    {
                        APPLICATION_ID = oApplicationInfoViewModel.APPLICATION_ID,
                        TITLE = oApplicationInfoViewModel.TITLE,
                        DESCRIPTION = oApplicationInfoViewModel.DESCRIPTION,
                        CREATED_BY = oApplicationInfoViewModel.CREATED_BY,
                        CREATED_DATE = DateTime.Now
                    };
                    this.oTakamulConnection.APPLICATION_INFO.Add(oAPPLICATION_INFO);
                    if (this.intCommit() > 0)
                    {
                        oResponse.OperationResult = enumOperationResult.Success;
                    }
                    else
                    {
                        oResponse.OperationResult = enumOperationResult.Faild;
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

        #region Method :: Response :: UpdateApplicationInfo
        /// <summary>
        /// Update member info
        /// </summary>
        /// <param name="oApplicationInfoViewModel"></param>
        /// <returns>Response</returns>
        public Response oUpdateApplicationInfo(ApplicationInfoViewModel oApplicationInfoViewModel)
        {
            Response oResponse = new Response();

            #region Try Block

            try
            {
                // Start try

                #region Check oEventViewModel Value
                APPLICATION_INFO oAPPLICATION_INFO = new APPLICATION_INFO();
                oAPPLICATION_INFO = this.oTakamulConnection.APPLICATION_INFO.Find(oApplicationInfoViewModel.ID);

                if (oAPPLICATION_INFO == null)
                {
                    throw new ArgumentNullException("oAPPLICATION_INFO Entity Is Null");
                }

                #endregion

                #region Update Default APPLICATION_INFO

                oAPPLICATION_INFO.APPLICATION_ID = oApplicationInfoViewModel.APPLICATION_ID;
                oAPPLICATION_INFO.TITLE = oApplicationInfoViewModel.TITLE;
                oAPPLICATION_INFO.DESCRIPTION = oApplicationInfoViewModel.DESCRIPTION;
                oAPPLICATION_INFO.MODIFIED_BY = oApplicationInfoViewModel.CREATED_BY;
                oAPPLICATION_INFO.MODIFIED_DATE = DateTime.Now;
                this.ApplicationInfoDBSet.Attach(oAPPLICATION_INFO);
                this.oTakamulConnection.Entry(oAPPLICATION_INFO).State = EntityState.Modified;

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

        #region Method :: Response :: DeleteApplicationInfo
        /// <summary>
        /// Delete event
        /// </summary>
        /// <param name="nApplicationInoID"></param>
        /// <returns></returns>
        public Response oDeleteApplicationInfo(int nApplicationInoID)
        {
            #region ": Delete :"

            Response oResponse = new Response();
            try
            {
                this.oTakamulConnection.APPLICATION_INFO.RemoveRange(this.oTakamulConnection.APPLICATION_INFO.Where(x => x.ID == nApplicationInoID));
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

        #endregion
    }
}
