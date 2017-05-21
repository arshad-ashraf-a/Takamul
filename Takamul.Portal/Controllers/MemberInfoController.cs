using Infrastructure.Core;
using Infrastructure.Utilities;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Xml.Linq;
using Takamul.Models;
using Takamul.Models.ViewModel;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class MemberInfoController : DomainController
    {
        #region ::   State   ::
        #region Private Members
        private IMemberInfoService oIMemberInfoService;
        #endregion
        #endregion

        #region :: Constructor ::
        public MemberInfoController(IMemberInfoService IMemberInfoServiceInitializer)
        {
            oIMemberInfoService = IMemberInfoServiceInitializer;
        }
        #endregion

        #region :: Behaviors ::

        #region View :: MemberInfoList
        /// <summary>
        /// List of member info
        /// </summary>
        /// <returns></returns>
        public ActionResult MemberInfoList()
        {
            this.ParentNode = "Incident Management";
            this.CurrentPage = "Member Info";
            this.TitleHead = "Member Info";

            return View();
        }
        #endregion

        #region View :: PartialAddMemberInfo
        /// <summary>
        /// Add member info
        /// </summary>
        /// <returns></returns>
        public PartialViewResult PartialAddMemberInfo()
        {
            MemberInfoViewModel oMemberInfoViewModel = new MemberInfoViewModel();
            oMemberInfoViewModel.APPLICATION_ID = CurrentApplicationID;
            return PartialView("~/Views/MemberInfo/_AddMemberInfo.cshtml", oMemberInfoViewModel);
        }
        #endregion

        #region View :: PartialEditAreaMaster
        /// <summary>
        ///  Edit member info
        /// </summary>
        /// <param name="oMemberInfoViewModel"></param>
        /// <returns></returns>
        public PartialViewResult PartialEditMemberInfo(MemberInfoViewModel oMemberInfoViewModel)
        {
            oMemberInfoViewModel.APPLICATION_ID = CurrentApplicationID;
            return PartialView("~/Views/MemberInfo/_EditMemberInfo.cshtml", oMemberInfoViewModel);
        }
        #endregion

        #endregion

        #region :: Methods ::

        #region Method :: JsonResult :: JGetAllMemberInfo
        /// <summary>
        /// Get all member info
        /// </summary>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <param name="sSearchByAreaName"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllMemberInfo(int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var list = oIMemberInfoService.IlGetAllMemberInfo(this.CurrentApplicationID,nPage, nRows, sColumnName, sColumnOrder);

            return Json(list, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Save member info
        /// <summary>
        /// Save member info
        /// </summary>
        /// <param name="oMemberInfoViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JSaveMemberInfo(MemberInfoViewModel oMemberInfoViewModel)
        {
            Response oResponseResult = null;

            oMemberInfoViewModel.CREATED_BY = Convert.ToInt32(CurrentUser.nUserID);
           
            oResponseResult = this.oIMemberInfoService.oInsertMemberInfo(oMemberInfoViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageAddSuccess;
                    break;
                case enumOperationResult.RelatedRecordFaild:
                    this.OperationResultMessages = "You have already added maximum number of list.";
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageAddFailed;
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

        #region Method :: JsonResult :: Edit member info
        /// <summary>
        /// Edit area master
        /// </summary>
        /// <param name="oMemberInfoViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JEditMemberInfo(MemberInfoViewModel oMemberInfoViewModel)
        {
            Response oResponseResult = null;

            oMemberInfoViewModel.MODIFIED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIMemberInfoService.oUpdateMemberInfo(oMemberInfoViewModel);
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

        #region Method :: JsonResult :: Delete Member Info
        /// <summary>
        ///  Delete member info
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JDeleteMemberInfo(string ID)
        {
            Response oResponseResult = null;

            oResponseResult = this.oIMemberInfoService.oDeleteMemberInfo(Convert.ToInt32(ID));
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageDeleteSuccess;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageDeleteFailed;
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

        #endregion



    }
}