﻿/*************************************************************************************************/
/* Class Name           : NewsServiceController.cs                                               */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:01 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage news operations                                                 */
/*************************************************************************************************/

using Infrastructure.Core;
using Infrastructure.Utilities;
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web;
using System.Web.Http;
using System.Web.Http.Cors;
using Takamul.Models.ApiViewModel;
using Takamul.Models.ViewModel;
using Takamul.Services;

namespace Takamul.API.Controllers
{
    /// <summary>
    /// News Service
    /// </summary>
    public class NewsServiceController : ApiController
    {
        #region ::   State   ::
        #region Private Members
        private readonly INewsServices oINewsServices;
        #endregion
        #endregion

        #region :: Constructor ::
        public NewsServiceController(
                                        INewsServices INewsServicesInitializer
                                    )
        {
            oINewsServices = INewsServicesInitializer;
        }
        #endregion

        #region :: Methods::

        #region Method :: HttpResponseMessage :: GetAllNews
        // GET: api/TakamulNews/GetAllNews
        /// <summary>
        /// Get all news 
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetAllNews(int nApplicationID, int nLanguageID)
        {
            List<TakamulNews> lstTakamulNews = null;
            try
            {
                var lstNews = this.oINewsServices.IlGetAllActiveNews(nApplicationID, nLanguageID);

                if (lstNews.Count() > 0)
                {
                    lstTakamulNews = new List<TakamulNews>();
                    foreach (var news in lstNews)
                    {

                        string sRemoteFilePath = string.Empty;
                        if (!string.IsNullOrEmpty(news.NEWS_IMG_FILE_PATH))
                        {
                            sRemoteFilePath = Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.RemoteFileServerPath), news.NEWS_IMG_FILE_PATH);
                        }

                        TakamulNews oTakamulNews = new TakamulNews()
                        {
                            NewsID = news.ID,
                            ApplicationID = news.APPLICATION_ID,
                            NewsContent = news.NEWS_CONTENT,
                            NewsTitle = news.NEWS_TITLE,
                            PublishedDate = string.Format("{0} {1}", news.PUBLISHED_DATE.ToShortDateString(), news.PUBLISHED_DATE.ToShortTimeString()),
                            RemoteFilePath = sRemoteFilePath,
                            YoutubeLink = news.YOUTUBE_LINK

                        };
                        lstTakamulNews.Add(oTakamulNews);
                    }
                }
            }
            catch (Exception ex)
            {
                Elmah.ErrorLog.GetDefault(HttpContext.Current).Log(new Elmah.Error(ex));
            }
            return Request.CreateResponse(HttpStatusCode.OK, lstTakamulNews);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetNewsDetails
        // GET: api/TakamulNews/GetNewsDetails
        /// <summary>
        /// Get news details by news id 
        /// </summary>
        /// <param name="nNewsID"></param>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetNewsDetails(int nNewsID, int nLanguageID)
        {
            TakamulNews oTakamulNews = null;
            NewsViewModel oNewsViewModel = this.oINewsServices.oGetNewsDetails(nNewsID);
            if (oNewsViewModel != null)
            {
                string sRemoteFilePath = string.Empty;
                if (!string.IsNullOrEmpty(oNewsViewModel.NEWS_IMG_FILE_PATH))
                {
                    sRemoteFilePath = Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.RemoteFileServerPath), oNewsViewModel.NEWS_IMG_FILE_PATH);
                }

                oTakamulNews = new TakamulNews()
                {
                    NewsID = oNewsViewModel.ID,
                    ApplicationID = oNewsViewModel.APPLICATION_ID,
                    NewsContent = oNewsViewModel.NEWS_CONTENT,
                    NewsTitle = oNewsViewModel.NEWS_TITLE,
                    PublishedDate = string.Format("{0} {1}", oNewsViewModel.PUBLISHED_DATE.ToShortDateString(), oNewsViewModel.PUBLISHED_DATE.ToShortTimeString()),
                    RemoteFilePath = sRemoteFilePath,
                    YoutubeLink = oNewsViewModel.YOUTUBE_LINK
                };
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulNews);
        }
        #endregion 

        #endregion
    }
}
