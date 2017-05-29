﻿using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Models;
using Takamul.Models.ViewModel;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace Takamul.Portal.Controllers
{
    public class MemberController : DomainController
    {
        #region ::  State ::
        #region Private Members
        private IUserServices oIUserServicesService;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// UsersController Constructor 
        /// </summary>
        /// <param name="oIUserServicesInitializer"></param>
        public MemberController(IUserServices oIUserServicesInitializer)
        {
            this.oIUserServicesService = oIUserServicesInitializer;
        }
        #endregion 

        #region :: Behaviour ::

        #region View :: MembersList
        public ActionResult MembersList()
        {
            this.PageTitle = "Member List";
            this.TitleHead = "Member List";

            return View();
        }
        #endregion

        #region View :: MemberProfile
        public ActionResult MemberProfile(int nUserID)
        {
            UserInfoViewModel oUserInfoViewModel = this.oIUserServicesService.oGetUserDetails(nUserID);
            this.PageTitle = "User Profile";
            this.TitleHead = "User Profile";

            return View(oUserInfoViewModel);
        }
        #endregion

        #region View :: PartialAddMember
        /// <summary>
        /// Add User
        /// </summary>
        /// <returns></returns>
        public PartialViewResult PartialAddMember()
        {
            UserInfoViewModel oUserInfoViewModel = new UserInfoViewModel();
            return PartialView("AddMember", oUserInfoViewModel);
        }
        #endregion

        #region View :: PartialChangeMemberStatus
        /// <summary>
        /// Change user status 
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public PartialViewResult PartialChangeMemberStatus(UserInfoViewModel oUserInfoViewModel)
        {
            return PartialView("_ChangeUserStatus", oUserInfoViewModel);
        }
        #endregion



        #endregion

        #region ::  Methods ::

        #region Method :: JsonResult :: JGetApplicationUsers
        /// <summary>
        /// Get application users
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetApplicationUsers(int nUserTypeID, string sUserSearch, int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var lstUsers = this.oIUserServicesService.lGetApplicationUsers(this.CurrentApplicationID, nUserTypeID, sUserSearch, nPage, nRows);
            return Json(lstUsers, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: JGetApplicationUsers
        /// <summary>
        /// Get application users
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllApplicationUsers()
        {
            var lstUsers = this.oIUserServicesService.lGetApplicationUsers(this.CurrentApplicationID, -99, string.Empty, 1, 500);
            return Json(lstUsers, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Update profile information
        /// <summary>
        /// Update profile information
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JUpdateProfileInformation(UserInfoViewModel oUserInfoViewModel)
        {
            Response oResponseResult = null;

            oUserInfoViewModel.MODIFIED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIUserServicesService.oUpdateProfileInformation(oUserInfoViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case Infrastructure.Core.enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageEditSuccess;
                    break;
                case Infrastructure.Core.enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageEditFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Update user password
        /// <summary>
        /// Update user password
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JUpdateUserPassword(int nUserID, string sPassword)
        {
            Response oResponseResult = null;

            int nModifiedBy = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIUserServicesService.oUpdateUserPassowrd(nUserID, sPassword, nModifiedBy);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case Infrastructure.Core.enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageEditSuccess;
                    break;
                case Infrastructure.Core.enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageEditFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Insert User
        /// <summary>
        /// Insert user
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JInsertUser(UserInfoViewModel oUserInfoViewModel)
        {
            Response oResponseResult = null;

            oUserInfoViewModel.APPLICATION_ID = CurrentApplicationID;
            enumUserType oUserType = (enumUserType)Enum.Parse(typeof(enumUserType), oUserInfoViewModel.USER_TYPE_ID.ToString());
            if (oUserType == enumUserType.Staff)
            {
                oUserInfoViewModel.PASSWORD = CommonHelper.sGetConfigKeyValue(ConstantNames.DefaultUserAccountPassword);
            }
            oUserInfoViewModel.CREATED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIUserServicesService.oInsertUser(oUserInfoViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageEditSuccess;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageEditFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Update user status
        /// <summary>
        ///  Update user status
        /// </summary>
        /// <param name="nUserID"></param>
        /// <param name="bIsActive"></param>
        /// <param name="bIsBlocked"></param>
        /// <param name="bIsOTPVerified"></param>
        /// <param name="sBlockedRemarks"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JUpdateUserStatus(UserInfoViewModel oUserInfoViewModel)
        {
            Response oResponseResult = null;

            int nModifiedBy = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIUserServicesService.oUpdateUserStatus(oUserInfoViewModel.ID, (bool)oUserInfoViewModel.IS_ACTIVE, (bool)oUserInfoViewModel.IS_BLOCKED, (bool)oUserInfoViewModel.IS_OTP_VALIDATED, oUserInfoViewModel.BLOCKED_REMARKS, nModifiedBy);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageEditSuccess;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageEditFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: JGetAllMembers
        /// <summary>
        /// Get all members
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllMembers(string sUserSearch, int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var lstUsers = this.oIUserServicesService.lGetAllMembers(sUserSearch, nPage, nRows);
            return Json(lstUsers, JsonRequestBehavior.AllowGet);
        }
        #endregion
        #endregion

    }
}