﻿/*************************************************************************************************/
/* Class Name           : CommonServiceController.cs                                             */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:01 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage common services                                                */
/*************************************************************************************************/

using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Takamul.Models;
using Takamul.Models.ApiViewModel;
using Takamul.Models.ViewModel;
using Takamul.Services;
using System.Linq;

namespace Takamul.API.Controllers
{
    /// <summary>
    /// Common Service
    /// </summary>
    public class CommonServiceController : ApiController
    {
        #region ::   State   ::
        #region Private Members
        private readonly ICommonServices oICommonServices;
        private readonly IApplicationService oIApplicationService;
        private readonly ITicketServices oITicketServices;
        private readonly INewsServices oINewsServices;
        private readonly IEventService oIEventsServices;
        #endregion
        #endregion

        #region :: Constructor ::
        public CommonServiceController(
                                        ICommonServices ICommonServicesInitializer,
                                        IApplicationService IApplicationServiceInitializer,
                                         ITicketServices ITicketServicesInitializer,
                                         INewsServices INewsServicesInitializer,
                                         IEventService IEventsServicesInitializer
                                    )
        {
            oICommonServices = ICommonServicesInitializer;
            oIApplicationService = IApplicationServiceInitializer;
            oITicketServices = ITicketServicesInitializer;
            oINewsServices = INewsServicesInitializer;
            oIEventsServices = IEventsServicesInitializer;
        }
        #endregion

        #region :: Methods::

        #region Method :: HttpResponseMessage :: GetApplicationDetails
        // GET: api/TakamulCommon/GetApplicationDetails
        /// <summary>
        /// Application detailed information
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetApplicationDetails(int nApplicationID)
        {
            TakamulApplication oTakamulApplication = null;
            ApplicationViewModel oApplicationViewModel = this.oIApplicationService.oGetApplicationDetails(nApplicationID);
            if (oApplicationViewModel != null)
            {
                string sBase64AppLogo = string.Empty;
                if (oApplicationViewModel.APPLICATION_LOGO_PATH != null)
                {
                    FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                    byte[] oByteFile = oFileAccessService.ReadFile(oApplicationViewModel.APPLICATION_LOGO_PATH);
                    if (oByteFile.Length > 0)
                    {
                        sBase64AppLogo = Convert.ToBase64String(oByteFile);
                    }
                }

                oTakamulApplication = new TakamulApplication()
                {
                    ApplicationID = oApplicationViewModel.ID,
                    ApplicationName = oApplicationViewModel.APPLICATION_NAME,
                    Base64ApplicationLogo = sBase64AppLogo,
                    ApplicationToken = oApplicationViewModel.APPLICATION_TOKEN,
                    DefaultThemeColor = oApplicationViewModel.DEFAULT_THEME_COLOR,
                    IsActive = oApplicationViewModel.IS_ACTIVE,
                    IsApplicationExpired = oApplicationViewModel.APPLICATION_EXPIRY_DATE < DateTime.Now
                };
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulApplication);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetMemberInfo
        // GET: api/TakamulCommon/GetMemberInfo
        /// <summary>
        /// Member information
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetMemberInfo(int nApplicationID, int nLanguageID)
        {
            TakamulMembeInfo oTakamulMembeInfo = null;
            List<TakamulMembeInfo> lstTakamulMembeInfo = null;
            List<MemberInfoViewModel> lstMemberInfoViewModel = this.oICommonServices.oGetMemberInfo(nApplicationID, nLanguageID);
            if (lstMemberInfoViewModel.Count > 0)
            {
                lstTakamulMembeInfo = new List<TakamulMembeInfo>();
                foreach (var oMemberInfoViewModel in lstMemberInfoViewModel)
                {
                    oTakamulMembeInfo = new TakamulMembeInfo()
                    {
                        ApplicationID = oMemberInfoViewModel.APPLICATION_ID,
                        MemberInfoTitle = oMemberInfoViewModel.MEMBER_INFO_TITLE,
                        MemberInfoDesc = oMemberInfoViewModel.MEMBER_INFO_DESCRIPTION
                    };
                    lstTakamulMembeInfo.Add(oTakamulMembeInfo);
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK, lstTakamulMembeInfo);
        }
        #endregion

        #region Method :: HttpResponseMessage :: GetAllAreas
        // GET: CommonService/GetAllAreas
        /// <summary>
        /// Get list of areas
        /// </summary>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetAllArea(int nLanguageID)
        {
            List<AreaInfo> oAreaInfolsts = new List<AreaInfo>();

            List<AreaInfoViewModel> oAreaListViewModellsts = this.oICommonServices.oGetAllAreas(nLanguageID);

            foreach (AreaInfoViewModel item in oAreaListViewModellsts)
            {
                var oAreaInfo = new AreaInfo()
                {
                    AREACODE = item.AREACODE,
                    AREA_NAME = item.AREA_NAME
                };
                oAreaInfolsts.Add(oAreaInfo);

            }
            return Request.CreateResponse(HttpStatusCode.OK, oAreaInfolsts);
        }
        #endregion

        #region Method :: HttpResponseMessage :: GetAllWilayats
        // GET: CommonService/GetAllWilayats
        /// <summary>
        /// Get list of Wilayats
        /// </summary>
        /// <param name="sAreaCode"></param>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        /// 
        [HttpGet]
        public HttpResponseMessage GetAllWilayats(string sAreaCode, int nLanguageID)
        {
            List<WilayatInfo> oWilayatList = new List<WilayatInfo>();
            List<WilayatInfoViewModel> oWilayatViewModellsts = this.oICommonServices.oGetAllWilayats(sAreaCode, nLanguageID);

            foreach (WilayatInfoViewModel item in oWilayatViewModellsts)
            {
                var WilayatInfo = new WilayatInfo
                {
                    WILAYATCODE = item.WILAYATCODE,
                    WILLAYATNAME = item.WILLAYATNAME
                };
                oWilayatList.Add(WilayatInfo);
            }

            return Request.CreateResponse(HttpStatusCode.OK, oWilayatList);
        }
        #endregion

        #region Method :: HttpResponseMessage :: GetAllVillages
        // GET: CommonService/OGetVillageList
        /// <summary>
        /// Get village detailed infomations
        /// </summary>
        /// <param name="sAreaCode"></param>
        /// <param name="sWilayatCode"></param>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetAllVillages(string sAreaCode, string sWilayatCode, int nLanguageID)
        {
            List<VillageInfo> oVillageList = new List<VillageInfo>();
            List<VillageInfoViewModel> oVillageViewModellsts = this.oICommonServices.oGetAllVillages(sAreaCode, sWilayatCode, nLanguageID);

            foreach (VillageInfoViewModel item in oVillageViewModellsts)
            {
                var oVillage = new VillageInfo()
                {
                    VILLAGECODE = item.VILLAGECODE,
                    VILLAGENAME = item.VILLAGENAME
                };
                oVillageList.Add(oVillage);
            }
            return Request.CreateResponse(HttpStatusCode.OK, oVillageList);
        }
        #endregion

        #region Method :: HttpResponseMessage :: GetHomePageData
        // GET: CommonService/GetHomePageData
        /// <summary>
        /// Get Home Page Data
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nUserID"></param>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetHomePageData(int nApplicationID, int nUserID, int nLanguageID)
        {
            HomePageRepo oHomePageRepo = new HomePageRepo();
            List<TakamulTicket> lstTakamulTicket = null;
            if (nUserID != -99)
            {
                var lstTickets = this.oITicketServices.IlGetAllActiveTickets(nApplicationID, nUserID);
                if (lstTickets.Count > 0)
                {
                    lstTakamulTicket = new List<TakamulTicket>();
                    foreach (var ticket in lstTickets.OrderByDescending(x => x.ID).Take(5))
                    {
                        string sBase64DefaultImage = string.Empty;
                        string sRemoteFilePath = string.Empty;
                        if (!string.IsNullOrEmpty(ticket.DEFAULT_IMAGE))
                        {
                            try
                            {
                                FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                                byte[] oByteFile = oFileAccessService.ReadFile(ticket.DEFAULT_IMAGE);
                                if (oByteFile.Length > 0)
                                {
                                    sBase64DefaultImage = Convert.ToBase64String(oByteFile);
                                }

                                sRemoteFilePath = Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.RemoteFileServerPath), ticket.DEFAULT_IMAGE);
                            }
                            catch (Exception Ex)
                            {
                                sBase64DefaultImage = Ex.Message.ToString();
                            }
                        }

                        TakamulTicket oTakamulTicket = new TakamulTicket()
                        {
                            TicketID = ticket.ID,
                            TicketCode = ticket.TICKET_CODE,
                            ApplicationID = ticket.APPLICATION_ID,
                            Base64DefaultImage = sBase64DefaultImage,
                            TicketName = ticket.TICKET_NAME,
                            TicketDescription = ticket.TICKET_DESCRIPTION,
                            TicketStatusID = ticket.TICKET_STATUS_ID,
                            TicketStatusRemark = ticket.TICKET_STATUS_REMARK,
                            TicketStatusName = ticket.TICKET_STATUS_NAME,
                            RemoteFilePath = sRemoteFilePath,
                            CreatedDate = string.Format("{0} {1}", ticket.CREATED_DATE.ToShortDateString(), ticket.CREATED_DATE.ToShortTimeString())
                        };

                        lstTakamulTicket.Add(oTakamulTicket);
                    }

                    oHomePageRepo.TakamulTicketList = lstTakamulTicket;
                }
            }

            List<TakamulNews> lstTakamulNews = null;
            var lstNews = this.oINewsServices.IlGetAllActiveNews(nApplicationID, nLanguageID);
            if (lstNews.Count() > 0)
            {
                lstTakamulNews = new List<TakamulNews>();
                foreach (var news in lstNews.OrderByDescending(x => x.ID).Take(5))
                {
                    string sBase64DefaultImage = string.Empty;
                    if (!string.IsNullOrEmpty(news.NEWS_IMG_FILE_PATH))
                    {
                        FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                        byte[] oByteFile = oFileAccessService.ReadFile(news.NEWS_IMG_FILE_PATH);
                        if (oByteFile.Length > 0)
                        {
                            sBase64DefaultImage = Convert.ToBase64String(oByteFile);
                        }
                    }

                    TakamulNews oTakamulNews = new TakamulNews()
                    {
                        NewsID = news.ID,
                        ApplicationID = news.APPLICATION_ID,
                        NewsContent = news.NEWS_CONTENT,
                        NewsTitle = news.NEWS_TITLE,
                        PublishedDate = string.Format("{0} {1}", news.PUBLISHED_DATE.ToShortDateString(), news.PUBLISHED_DATE.ToShortTimeString()),
                        Base64NewsImage = sBase64DefaultImage

                    };
                    lstTakamulNews.Add(oTakamulNews);
                }
                oHomePageRepo.TakamulNewsList = lstTakamulNews;
            }

            List<TakamulEvents> lstTakamulEvents = null;
            var lstEvents = this.oIEventsServices.IlGetAllActiveEvents(nApplicationID, nLanguageID);
            if (lstEvents.Count() > 0)
            {
                lstTakamulEvents = new List<TakamulEvents>();
                foreach (var oEvent in lstEvents.OrderByDescending(x => x.ID).Take(5))
                {
                    string sBase64DefaultImage = string.Empty;
                    if (!string.IsNullOrEmpty(oEvent.EVENT_IMG_FILE_PATH))
                    {
                        FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                        byte[] oByteFile = oFileAccessService.ReadFile(oEvent.EVENT_IMG_FILE_PATH);
                        if (oByteFile.Length > 0)
                        {
                            sBase64DefaultImage = Convert.ToBase64String(oByteFile);
                        }
                    }

                    TakamulEvents oTakamulEvents = new TakamulEvents()
                    {
                        EventID = oEvent.ID,
                        APPLICATIONID = oEvent.APPLICATION_ID,
                        EVENTDESCRIPTION = oEvent.EVENT_DESCRIPTION,
                        EVENTNAME = oEvent.EVENT_NAME,
                        EVENTDATE = string.Format("{0} {1}", oEvent.EVENT_DATE.ToShortDateString(), oEvent.EVENT_DATE.ToShortTimeString()),
                        Latitude = oEvent.EVENT_LATITUDE,
                        Longitude = oEvent.EVENT_LONGITUDE,
                        BASE64EVENTIMG = sBase64DefaultImage
                    };
                    lstTakamulEvents.Add(oTakamulEvents);
                }
                oHomePageRepo.TakamulEventList= lstTakamulEvents;
            }
            
            return Request.CreateResponse(HttpStatusCode.OK, oHomePageRepo);
        }
        #endregion

        #endregion
    }
}
