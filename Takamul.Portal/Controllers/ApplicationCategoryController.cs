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
using Takamul.Portal.Resources.Portal.ApplicationCategory;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class ApplicationCategoryController : DomainController
    {
        #region ::   State   ::
        #region Private Members
        private IApplicationCategoryServices oIApplicationCategoryServices;
        #endregion
        #endregion

        #region :: Constructor ::
        public ApplicationCategoryController(IApplicationCategoryServices IApplicationCategoryServicesInitializer)
        {
            oIApplicationCategoryServices = IApplicationCategoryServicesInitializer;
        }
        #endregion

        #region :: Behaviors ::

        #region View :: ApplicationCatgoryList
        /// <summary>
        /// List of application categories
        /// </summary>
        /// <returns></returns>
        public ActionResult ApplicationCatgoryList()
        {
            return View();
        }
        #endregion

        #region View :: PartialAddApplicationCatgory
        /// <summary>
        /// Add application category
        /// </summary>
        /// <returns></returns>
        public PartialViewResult PartialAddApplicationCatgory()
        {
            ApplicationCategoryViewModel oApplicationCategoryViewModel = new ApplicationCategoryViewModel();
            oApplicationCategoryViewModel.APPLICATION_ID = CurrentApplicationID;
            return PartialView("_AddApplicationCatgory", oApplicationCategoryViewModel);
        }
        #endregion

        #region View :: PartialEditApplicationCatgory
        /// <summary>
        ///  Edit application category
        /// </summary>
        /// <param name="oApplicationCategoryViewModel"></param>
        /// <returns></returns>
        public PartialViewResult PartialEditApplicationCatgory(ApplicationCategoryViewModel oApplicationCategoryViewModel)
        {
            oApplicationCategoryViewModel.APPLICATION_ID = CurrentApplicationID;
            return PartialView("_EditApplicationCatgory", oApplicationCategoryViewModel);
        }
        #endregion

        #endregion

        #region :: Methods ::

        #region Method :: JsonResult :: JGetAllApplicationCatgory
        /// <summary>
        /// Get all application category
        /// </summary>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllApplicationCatgory(int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var list = oIApplicationCategoryServices.IlGetAllApplicationCategories(this.CurrentApplicationID, nPage, nRows, sColumnName, sColumnOrder, Convert.ToInt32(this.CurrentApplicationLanguage));
            return Json(list, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Save application category
        /// <summary>
        /// Save application category
        /// </summary>
        /// <param name="oApplicationCategoryViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JSaveApplicationCatgory(ApplicationCategoryViewModel oApplicationCategoryViewModel)
        {
            Response oResponseResult = null;

            oApplicationCategoryViewModel.CREATED_BY = Convert.ToInt32(CurrentUser.nUserID);
            oApplicationCategoryViewModel.LANGUAGE_ID = Convert.ToInt32(this.CurrentApplicationLanguage);

            oResponseResult = this.oIApplicationCategoryServices.oInsertApplicationCategory(oApplicationCategoryViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageAddSuccess;
                    break;
                case enumOperationResult.AlreadyExistRecordFaild:
                    this.OperationResultMessages = CommonResx.AlreadyExistRecordFaild;
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

        #region Method :: JsonResult :: Edit ApplicationCatgory
        /// <summary>
        /// Edit ApplicationCatgory
        /// </summary>
        /// <param name="oApplicationCategoryViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JEditApplicationCatgory(ApplicationCategoryViewModel oApplicationCategoryViewModel)
        {
            Response oResponseResult = null;

            oApplicationCategoryViewModel.MODIFIED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIApplicationCategoryServices.oUpdateApplicationCategory(oApplicationCategoryViewModel);
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

        #region Method :: JsonResult :: Delete ApplicationCatgory
        /// <summary>
        ///  Delete ApplicationCatgory
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JDelteApplicationCatgory(string ID)
        {
            Response oResponseResult = null;

            oResponseResult = this.oIApplicationCategoryServices.oDeleteApplicationCategory(Convert.ToInt32(ID));
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