/*************************************************************************************************/
/* Class Name           : ApplicationCategoryServices.cs                                         */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 05.04.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : application category service                                           */
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
    public class ApplicationCategoryServices : EntityService<Lookup>, IApplicationCategoryServices
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;
        private IDbSet<APPLICATION_CATEGORIES> oApplicationCategoryDBSet;// Represent DB Set Table For APPLICATION_CATEGORIES

        #endregion

        #region Properties
        #region Property :: ApplicationCategoryDBSet
        /// <summary>
        ///  Get APPLICATION_CATEGORIES DBSet Object
        /// </summary>
        private IDbSet<APPLICATION_CATEGORIES> ApplicationCategoryDBSet
        {
            get
            {
                if (oApplicationCategoryDBSet == null)
                {
                    oApplicationCategoryDBSet = oTakamulConnection.Set<APPLICATION_CATEGORIES>();
                }
                return oApplicationCategoryDBSet;
            }
        }
        #endregion
        #endregion

        #region :: Constructor ::
        public ApplicationCategoryServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<ApplicationCategoryViewModel> :: lGetAllApplicationCategories
        /// <summary>
        /// Get all application category
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nLanguageID"></param>
        /// <returns>List of Events</returns>
        public List<ApplicationCategoryViewModel> lGetAllApplicationCategories(int nApplicationID, int nLanguageID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLanguageID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<ApplicationCategoryViewModel> lstApplicationCategory = this.ExecuteStoredProcedureList<ApplicationCategoryViewModel>("GetApplicationCategories", arrParameters.ToArray());
            return lstApplicationCategory;
            #endregion
        }
        #endregion

        #region Method :: IPagedList<ApplicationCategoryViewModel> :: IlGetAllApplicationCategories
        /// <summary>
        /// Get all application category
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="sSearchByEventName"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        public IPagedList<ApplicationCategoryViewModel> IlGetAllApplicationCategories(int nApplicationID, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder, int nLanguageID)
        {
            #region Build Left Join Query And Keep All Query Source As IQueryable To Avoid Any Immediate Execution DataBase
            var lstAppCategories = (from c in this.ApplicationCategoryDBSet
                                 where c.APPLICATION_ID == (int)nApplicationID
                                 where nLanguageID == -99 || c.LANGUAGE_ID == nLanguageID
                                 orderby c.ID descending
                                 select new
                                 {
                                     ID = c.ID,
                                     APPLICATION_ID = c.APPLICATION_ID,
                                     CATEGORY_NAME = c.CATEGORY_NAME
                                 });
            #endregion

            #region Execute The Query And Return Page Result
            var oTempApplicationCategoryPagedResult = new PagedList<dynamic>(lstAppCategories, nPageIndex - 1, nPageSize, sColumnName, sColumnOrder);
            int nTotal = oTempApplicationCategoryPagedResult.TotalCount;
            PagedList<ApplicationCategoryViewModel> plstApplicaiton = new PagedList<ApplicationCategoryViewModel>(oTempApplicationCategoryPagedResult.Select(oApplicationCategoryPagedResult => new ApplicationCategoryViewModel
            {
                ID = oApplicationCategoryPagedResult.ID,
                APPLICATION_ID = oApplicationCategoryPagedResult.APPLICATION_ID,
                CATEGORY_NAME = oApplicationCategoryPagedResult.CATEGORY_NAME

            }), oTempApplicationCategoryPagedResult.PageIndex, oTempApplicationCategoryPagedResult.PageSize, oTempApplicationCategoryPagedResult.TotalCount);

            if (plstApplicaiton.Count > 0)
            {
                plstApplicaiton[0].TotalCount = nTotal;
            }

            return plstApplicaiton;
            #endregion
        }
        #endregion

        #region Method :: Response :: InsertApplicationCategory
        /// <summary>
        ///  Insert application category
        /// </summary>
        /// <param name="oApplicationCategoryViewModel"></param>
        /// <returns>Response</returns>
        public Response oInsertApplicationCategory(ApplicationCategoryViewModel oApplicationCategoryViewModel)
        {
            #region ": Insert :"

            Response oResponse = new Response();

            try
            {
                if (oApplicationCategoryViewModel != null)
                {
                    var lstApplicationCategory = (from c in this.ApplicationCategoryDBSet
                                                  where c.APPLICATION_ID == oApplicationCategoryViewModel.APPLICATION_ID
                                                  where c.LANGUAGE_ID == oApplicationCategoryViewModel.LANGUAGE_ID
                                                  where c.CATEGORY_NAME == oApplicationCategoryViewModel.CATEGORY_NAME
                                                  orderby c.ID descending
                                                  select new
                                                  {
                                                      ID = c.ID,
                                                      APPLICATION_ID = c.APPLICATION_ID,
                                                      CATEGORY_NAME = c.CATEGORY_NAME
                                                  });
                    if (lstApplicationCategory.Count() > 0)
                    {
                        oResponse.OperationResult = enumOperationResult.AlreadyExistRecordFaild;
                        return oResponse;
                    }

                    APPLICATION_CATEGORIES oAPPLICATION_CATEGORIES = new APPLICATION_CATEGORIES()
                    {
                        APPLICATION_ID = oApplicationCategoryViewModel.APPLICATION_ID,
                        LANGUAGE_ID = oApplicationCategoryViewModel.LANGUAGE_ID,
                        CATEGORY_NAME = oApplicationCategoryViewModel.CATEGORY_NAME,
                        CREATED_BY = oApplicationCategoryViewModel.CREATED_BY,
                        CREATED_DATE = DateTime.Now
                    };
                    this.oTakamulConnection.APPLICATION_CATEGORIES.Add(oAPPLICATION_CATEGORIES);
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

        #region Method :: Response :: UpdateApplicationCategory
        /// <summary>
        /// Update application category
        /// </summary>
        /// <param name="oApplicationCategoryViewModel"></param>
        /// <returns>Response</returns>
        public Response oUpdateApplicationCategory(ApplicationCategoryViewModel oApplicationCategoryViewModel)
        {
            Response oResponse = new Response();

            #region Try Block

            try
            {
                // Start try

                #region Check oApplicationCategoryViewModel Value
                APPLICATION_CATEGORIES oAPPLICATION_CATEGORIES = new APPLICATION_CATEGORIES();
                oAPPLICATION_CATEGORIES = this.oTakamulConnection.APPLICATION_CATEGORIES.Find(oApplicationCategoryViewModel.ID);

                if (oAPPLICATION_CATEGORIES == null)
                {
                    throw new ArgumentNullException("APPLICATION_CATEGORIES Entity Is Null");
                }

                #endregion

                #region Update Default APPLICATION_CATEGORIES

                oAPPLICATION_CATEGORIES.APPLICATION_ID = oApplicationCategoryViewModel.APPLICATION_ID;
                oAPPLICATION_CATEGORIES.CATEGORY_NAME = oApplicationCategoryViewModel.CATEGORY_NAME;
                oAPPLICATION_CATEGORIES.MODIFIED_BY = oApplicationCategoryViewModel.CREATED_BY;
                oAPPLICATION_CATEGORIES.MODIFIED_DATE = DateTime.Now;
                this.ApplicationCategoryDBSet.Attach(oAPPLICATION_CATEGORIES);
                this.oTakamulConnection.Entry(oAPPLICATION_CATEGORIES).State = EntityState.Modified;

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

        #region Method :: Response :: DeleteApplicationCategory
        /// <summary>
        /// Delete application category
        /// </summary>
        /// <param name="nApplicationCategoryID"></param>
        /// <returns></returns>
        public Response oDeleteApplicationCategory(int nApplicationCategoryID)
        {
            #region ": Delete :"

            Response oResponse = new Response();
            try
            {
                this.oTakamulConnection.APPLICATION_CATEGORIES.RemoveRange(this.oTakamulConnection.APPLICATION_CATEGORIES.Where(x => x.ID == nApplicationCategoryID));
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
