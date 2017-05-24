using Infrastructure.Core;
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

namespace LDC.eServices.Portal.Controllers
{
    public class UsersController : DomainController
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
        public UsersController(IUserServices oIUserServicesInitializer)
        {
            this.oIUserServicesService = oIUserServicesInitializer;
        }
        #endregion

        #region :: Behaviour ::

        #region View :: UsersList
        public ActionResult UsersList()
        {
            this.PageTitle = "Users List";
            this.TitleHead = "Users List";

            return View();
        }
        #endregion

        #region View :: UserProfile
        public ActionResult UserProfile(int nUserID)
        {
            UserInfoViewModel oUserInfoViewModel = this.oIUserServicesService.oGetUserDetails(nUserID);
            this.PageTitle = "User Profile";
            this.TitleHead = "User Profile";

            return View(oUserInfoViewModel);
        }
        #endregion

        #region View :: PartialAddUser
        /// <summary>
        /// Add User
        /// </summary>
        /// <returns></returns>
        public PartialViewResult PartialAddUser()
        {
            UserInfoViewModel oUserInfoViewModel = new UserInfoViewModel();
            return PartialView("_AddApplicationUser", oUserInfoViewModel);
        }
        #endregion

        #region View :: PartialChangeUserStatus
        /// <summary>
        /// Change user status 
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public PartialViewResult PartialChangeUserStatus(UserInfoViewModel oUserInfoViewModel)
        {
            return PartialView("_ChangeUserStatus", oUserInfoViewModel);
        }
        #endregion

        #region View :: MembersList
        public ActionResult MembersList()
        {
            if (BaseController.CurrentUser.UserType == enumUserType.Admin)
            {
                this.PageTitle = "Members List";
                this.TitleHead = "Members List";

                return View();
            }
            else
            {
                return RedirectToAction("Index", "AccessDenied");
            }
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

        #region JsonResult :: Bind Grid All Memebers
        /// <summary>
        /// Bind All Members
        /// </summary>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public JsonResult JBindAllMembers(int nSearchByMemberID, string sSearchByMemberName, int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var lstMembers = this.oIUserServicesService.IlGetAllMembers(nSearchByMemberID, sSearchByMemberName, nPage, nRows);
            return Json(lstMembers, JsonRequestBehavior.AllowGet);
        }
        #endregion
        #endregion
    }
}