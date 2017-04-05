/*************************************************************************************************/
/* Class Name           : TakamulNewsController.cs                                               */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:01 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage news operations                                                 */
/*************************************************************************************************/

using Infrastructure.Utilities;
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Http.Cors;
using Takamul.Models.ApiViewModel;
using Takamul.Models.ViewModel;
using Takamul.Services;

namespace Takamul.API.Controllers
{
    public class TakamulNewsController : ApiController
    {
        #region ::   State   ::
        #region Private Members
        private readonly INewsServices oINewsServices;
        #endregion
        #endregion

        #region :: Constructor ::
        public TakamulNewsController(
                                        INewsServices INewsServicesInitializer
                                    )
        {
            oINewsServices = INewsServicesInitializer;
        }
        #endregion

        #region :: Methods::

        #region Method :: HttpResponseMessage :: GetAllNews
        // GET: api/TakamulNews/GetAllNews
        [HttpGet]
        public HttpResponseMessage GetAllNews(int nApplicationID)
        {
            List<TakamulNews> lstTakamulNews = null;
            var lstNews = this.oINewsServices.IlGetAllActiveNews(nApplicationID);
            if (lstNews.Count() > 0)
            {
                lstTakamulNews = new List<TakamulNews>();
                foreach (var news in lstNews)
                {
                    TakamulNews oTakamulNews = new TakamulNews()
                    {
                        NewsID = news.ID,
                        ApplicationID = news.APPLICATION_ID,
                        NewsContent = news.NEWS_CONTENT,
                        NewsTitle = news.NEWS_TITLE
                    };
                    lstTakamulNews.Add(oTakamulNews);
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK, lstTakamulNews);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetNewsDetails
        // GET: api/TakamulNews/GetNewsDetails
        [HttpGet]
        public HttpResponseMessage GetNewsDetails(int nNewsID)
        {
            TakamulNews oTakamulNews = null;
            NewsViewModel oNewsViewModel = this.oINewsServices.oGetNewsDetails(nNewsID);
            if (oNewsViewModel != null)
            {
                oTakamulNews = new TakamulNews()
                {
                    NewsID = oNewsViewModel.ID,
                    ApplicationID = oNewsViewModel.APPLICATION_ID,
                    NewsContent = oNewsViewModel.NEWS_CONTENT,
                    NewsTitle = oNewsViewModel.NEWS_TITLE
                };
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulNews);
        }
        #endregion 

        #endregion
    }
}
