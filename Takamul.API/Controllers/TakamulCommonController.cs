﻿/*************************************************************************************************/
/* Class Name           : TakamulCommonController.cs                                             */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:01 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage common services                                                */
/*************************************************************************************************/

using Infrastructure.Core;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Takamul.Models;
using Takamul.Models.ApiViewModel;
using Takamul.Models.ViewModel;
using Takamul.Services;

namespace Takamul.API.Controllers
{
    public class TakamulCommonController : ApiController
    {
        #region ::   State   ::
        #region Private Members
        private readonly ICommonServices oICommonServices;
        private readonly IApplicationService oIApplicationService;
        #endregion
        #endregion

        #region :: Constructor ::
        public TakamulCommonController(
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
        [HttpGet]
        public HttpResponseMessage GetApplicationDetails(int nApplicationID)
        {
            TakamulApplication oTakamulApplication = null;
            ApplicationViewModel oApplicationViewModel = this.oIApplicationService.oGetApplicationDetails(nApplicationID);
            if (oApplicationViewModel != null)
            {
                 oTakamulApplication = new TakamulApplication()
                {
                    ApplicationID = oApplicationViewModel.ID,
                    ApplicationName = oApplicationViewModel.APPLICATION_NAME,
                    Base64ApplicationLogo = oApplicationViewModel.APPLICATION_LOGO_PATH,
                    ApplicationToken = oApplicationViewModel.APPLICATION_TOKEN,
                    DefaultThemeColor = oApplicationViewModel.DEFAULT_THEME_COLOR,
                    IsActive = oApplicationViewModel.IS_ACTIVE
                };
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulApplication);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetMemberInfo
        // GET: api/TakamulCommon/GetMemberInfo
        [HttpGet]
        public HttpResponseMessage GetMemberInfo(int nApplicationID)
        {
            TakamulMembeInfo oTakamulMembeInfo = null;
            MemberInfoViewModel oNewsViewModel = this.oICommonServices.oGetMemberInfo(nApplicationID);
            if (oNewsViewModel != null)
            {
                oTakamulMembeInfo = new TakamulMembeInfo()
                {
                    ApplicationID = oNewsViewModel.APPLICATION_ID,
                    MemberInfoTitle = oNewsViewModel.MEMBER_INFO_TITLE,
                    MemberInfoDesc = oNewsViewModel.MEMBER_INFO_DESCRIPTION
                };
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulMembeInfo);
        }
        #endregion 

        #endregion
    }
}