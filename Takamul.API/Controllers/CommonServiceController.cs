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
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Takamul.Models;
using Takamul.Models.ApiViewModel;
using Takamul.Models.ViewModel;
using Takamul.Services;

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
        #endregion
        #endregion

        #region :: Constructor ::
        public CommonServiceController(
                                        ICommonServices ICommonServicesInitializer,
                                        IApplicationService IApplicationServiceInitializer
                                    )
        {
            oICommonServices = ICommonServicesInitializer;
            oIApplicationService = IApplicationServiceInitializer;
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
        public HttpResponseMessage GetMemberInfo(int nApplicationID,int nLanguageID)
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

        #endregion
    }
}
