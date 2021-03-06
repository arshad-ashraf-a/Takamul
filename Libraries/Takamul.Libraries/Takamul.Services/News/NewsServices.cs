﻿/*************************************************************************************************/
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
using System;
using System.Linq;
using Infrastructure.Core;
using System.IO;
using System.Net;
using System.Web;
using Infrastructure.Utilities;

namespace Takamul.Services
{
    public class NewsServices : EntityService<Lookup>, INewsServices
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;
        private IDbSet<NEWS> oNewsDBSet;// Represent DB Set Table For EVENTS
        private IDbSet<APPLICATION_CATEGORIES> oApplicationCategoryDBSet;// Represent DB Set Table For APPLICATION_CATEGORIES
        #endregion

        #region Properties

        #region Property :: EventsDBSet
        /// <summary>
        ///  Get NEWS DBSet Object
        /// </summary>
        private IDbSet<NEWS> NewsDBSet
        {
            get
            {
                if (oNewsDBSet == null)
                {
                    oNewsDBSet = oTakamulConnection.Set<NEWS>();
                }
                return oNewsDBSet;
            }
        }
        #endregion

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
        public NewsServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);
        }
        #endregion

        #region :: Methods ::

        #region Method :: List<NewsViewModel> :: IlGetAllActiveNews
        /// <summary>
        /// Get all active news
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nLaguageID"></param>
        /// <returns>List of News</returns>
        public List<NewsViewModel> IlGetAllActiveNews(int nApplicationID,int nLaguageID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LaguageId", SqlDbType.Int, nLaguageID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_NewsId", SqlDbType.Int, -99, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<NewsViewModel> lstNews = this.ExecuteStoredProcedureList<NewsViewModel>("GetAllActiveNews", arrParameters.ToArray());
            return lstNews;
            #endregion
        }
        #endregion 

        #region Method :: NewsViewModel :: oGetNewsDetails
        /// <summary>
        /// Get news details by news id
        /// </summary>
        /// <param name="nNewsID"></param>
        /// <returns>List of News</returns>
        public NewsViewModel oGetNewsDetails(int nNewsID)
        {
            NewsViewModel oNewsViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_NewsId", SqlDbType.Int, nNewsID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<NewsViewModel> lstNews = this.ExecuteStoredProcedureList<NewsViewModel>("GetNewsDetails", arrParameters.ToArray());
            if (lstNews.Count > 0)
            {
                return lstNews[0];
            }
            return oNewsViewModel;
            #endregion
        }
        #endregion

        #region Method :: IPagedList<NewsViewModel> :: IlGetAllNews
        /// <summary>
        /// Get all News
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="sSearchByNewsName"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        public IPagedList<NewsViewModel> IlGetAllNews(int nApplicationID,
            string sSearchByNewsName, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder, int nLanguageID)
        {
            #region Build Left Join Query And Keep All Query Source As IQueryable To Avoid Any Immediate Execution DataBase
            var lstNews = (from c in this.NewsDBSet
                           join p in this.ApplicationCategoryDBSet on c.NEWS_CATEGORY_ID equals p.ID into gj
                           from x in gj.DefaultIfEmpty()
                           where sSearchByNewsName == null || c.NEWS_TITLE.Contains(sSearchByNewsName)
                           where c.APPLICATION_ID == (int)nApplicationID
                           where c.LANGUAGE_ID == nLanguageID
                           orderby c.ID descending
                           select new
                           {
                               ID = c.ID,
                               NEWS_TITLE = c.NEWS_TITLE,
                               NEWS_CONTENT = c.NEWS_CONTENT,
                               PUBLISHED_DATE = c.PUBLISHED_DATE,
                               IS_NOTIFY_USER = c.IS_NOTIFY_USER,
                               NEWS_IMG_FILE_PATH = c.NEWS_IMG_FILE_PATH,
                               IS_ACTIVE = c.IS_ACTIVE,
                               CREATED_DATE = c.CREATED_DATE,
                               CATEGORY_NAME = x.CATEGORY_NAME
                           });
            #endregion

            #region Execute The Query And Return Page Result
            var oTempNewsPagedResult = new PagedList<dynamic>(lstNews, nPageIndex - 1, nPageSize, sColumnName, sColumnOrder);
            int nTotal = oTempNewsPagedResult.TotalCount;
            PagedList<NewsViewModel> plstNews = new PagedList<NewsViewModel>(oTempNewsPagedResult.Select(oNewsPagedResult => new NewsViewModel
            {
                ID = oNewsPagedResult.ID,
                NEWS_TITLE = oNewsPagedResult.NEWS_TITLE,
                NEWS_CONTENT = oNewsPagedResult.NEWS_CONTENT,
                PUBLISHED_DATE = oNewsPagedResult.PUBLISHED_DATE,
                IS_NOTIFY_USER = oNewsPagedResult.IS_NOTIFY_USER,
                NEWS_IMG_FILE_PATH = oNewsPagedResult.NEWS_IMG_FILE_PATH,
                IS_ACTIVE = oNewsPagedResult.IS_ACTIVE,
                CREATED_DATE = oNewsPagedResult.CREATED_DATE,
                CATEGORY_NAME = oNewsPagedResult.CATEGORY_NAME

            }), oTempNewsPagedResult.PageIndex, oTempNewsPagedResult.PageSize, oTempNewsPagedResult.TotalCount);

            if (plstNews.Count > 0)
            {
                plstNews[0].TotalCount = nTotal;
            }

            return plstNews;
            #endregion
        }
        #endregion

        #region Method :: Response :: InsertNews
        /// <summary>
        ///  Insert News
        /// </summary>
        /// <param name="oNewsViewModel"></param>
        /// <returns>Response</returns>
        public Response oInsertNews(NewsViewModel oNewsViewModel)
        {
            #region ": Insert :"

            Response oResponse = new Response();
            try
            {
                if (oNewsViewModel != null)
                {
                    NEWS oNews = new NEWS()
                    {
                        APPLICATION_ID = oNewsViewModel.APPLICATION_ID,
                        NEWS_TITLE = oNewsViewModel.NEWS_TITLE,
                        NEWS_CONTENT = oNewsViewModel.NEWS_CONTENT,
                        NEWS_IMG_FILE_PATH = oNewsViewModel.NEWS_IMG_FILE_PATH,
                        PUBLISHED_DATE = oNewsViewModel.PUBLISHED_DATE,
                        IS_ACTIVE = oNewsViewModel.IS_ACTIVE,
                        IS_NOTIFY_USER = oNewsViewModel.IS_NOTIFY_USER,
                        LANGUAGE_ID = oNewsViewModel.LANGUAGE_ID,
                        YOUTUBE_LINK = oNewsViewModel.YOUTUBE_LINK,
                        CREATED_BY = oNewsViewModel.CREATED_BY,
                        CREATED_DATE = DateTime.Now
                    };

                    if (oNewsViewModel.NEWS_CATEGORY_ID != -99)
                    {
                        oNews.NEWS_CATEGORY_ID = oNewsViewModel.NEWS_CATEGORY_ID;
                    }

                    this.oTakamulConnection.NEWS.Add(oNews);
                    
                    if (this.intCommit() > 0)
                    {
                        oResponse.OperationResult = enumOperationResult.Success;
                        oResponse.ResponseCode = Convert.ToString(oNews.ID);
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

        #region Method :: Response :: UpdateNews
        /// <summary>
        /// Update News
        /// </summary>
        /// <param name="oNewsViewModel"></param>
        /// <returns>Response</returns>
        public Response oUpdateNews(NewsViewModel oNewsViewModel, FileDetail newsFile = null)
        {
            Response oResponse = new Response();

            #region Try Block

            try
            {
                // Start try

                #region Check oNewsViewModel Value
                NEWS oNews = new NEWS();
                oNews = this.oTakamulConnection.NEWS.Find(oNewsViewModel.ID);

                if (oNews == null)
                {
                    throw new ArgumentNullException("oNews Entity Is Null");
                }

                #endregion

                #region Update Default NEWS

                oNews.NEWS_TITLE = oNewsViewModel.NEWS_TITLE;
                oNews.NEWS_CONTENT = oNewsViewModel.NEWS_CONTENT;
                oNews.PUBLISHED_DATE = oNewsViewModel.PUBLISHED_DATE;
                if (!oNewsViewModel.NEWS_IMG_FILE_PATH.Equals(string.Empty))
                {
                    oNews.NEWS_IMG_FILE_PATH = oNewsViewModel.NEWS_IMG_FILE_PATH;
                }
                oNews.IS_ACTIVE = oNewsViewModel.IS_ACTIVE;
                oNews.IS_NOTIFY_USER = oNewsViewModel.IS_NOTIFY_USER;
                oNews.YOUTUBE_LINK = oNewsViewModel.YOUTUBE_LINK;
                oNews.MODIFIED_BY = oNewsViewModel.MODIFIED_BY;
                oNews.MODIFIED_DATE = DateTime.Now;

                if (oNewsViewModel.NEWS_CATEGORY_ID != -99)
                {
                    oNews.NEWS_CATEGORY_ID = oNewsViewModel.NEWS_CATEGORY_ID;
                }
                else
                {
                    oNews.NEWS_CATEGORY_ID = null;
                }

                this.NewsDBSet.Attach(oNews);
                this.oTakamulConnection.Entry(oNews).State = EntityState.Modified;

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

        #region Method :: Response :: oDeleteFile
        /// <summary>
        /// Delete news image
        /// </summary>
        /// <param name="oGuid"></param>
        /// <returns></returns>
        public NEWS oDeleteFile(string oGuid)
        {
            Response oResponse = new Response();
            NEWS fileDetail = new NEWS();
            try
            {
                Guid guid = new Guid(oGuid);
                fileDetail = this.oTakamulConnection.NEWS.Find(guid);
                if (fileDetail == null)
                {
                    oResponse.OperationResult = enumOperationResult.Faild;
                    // return Json(new { Result = "Error" });
                }

                //Remove from database
                this.oTakamulConnection.NEWS.Remove(fileDetail);
                this.oTakamulConnection.SaveChanges();

            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = enumOperationResult.Faild;
                //TODO : Log Error Message
                oResponse.OperationResultMessage = Ex.Message.ToString();

            }

            return fileDetail;
        }
        #endregion

        #region Method :: Response :: DeleteNews
        /// <summary>
        /// Delete event
        /// </summary>
        /// <param name="nNewsID"></param>
        /// <returns></returns>
        public Response oDeleteNews(int nNewsID)
        {
            #region ": Delete :"

            Response oResponse = new Response();
            try
            {
                this.oTakamulConnection.NEWS.RemoveRange(this.oTakamulConnection.NEWS.Where(x => x.ID == nNewsID));
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

