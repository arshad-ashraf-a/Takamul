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
using Takamul.Portal.Resources.Portal.ApplicationSettings;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class ApplicationSettingsController : DomainController
    {
        #region ::   State   ::
        #region Private Members
        private IApplicationSettingsService oIIApplicationSettingsService;
        #endregion
        #endregion

        #region :: Constructor ::
        public ApplicationSettingsController(IApplicationSettingsService IApplicationSettingsServiceInitializer)
        {
            oIIApplicationSettingsService = IApplicationSettingsServiceInitializer;
        }
        #endregion

        #region :: Behaviors ::

        #region View :: ApplicationSettingsList
        /// <summary>
        /// List of application settings
        /// </summary>
        /// <returns></returns>
        public ActionResult ApplicationSettingsList()
        {
            this.CurrentPage = ApplicationSettingsResx.ApplicationSettings;
            this.TitleHead = ApplicationSettingsResx.ApplicationSettings;

            return View();
        }
        #endregion

        #region View :: PartialEditApplicationSettings
        /// <summary>
        ///  Edit application Settings
        /// </summary>
        /// <param name="oApplicationSettingsViewModel"></param>
        /// <returns></returns>
        public PartialViewResult PartialEditApplicationSettings(ApplicationSettingsViewModel oApplicationSettingsViewModel)
        {
            oApplicationSettingsViewModel.APPLICATION_ID = CurrentApplicationID;
            return PartialView("_EditApplicationSettings", oApplicationSettingsViewModel);
        }
        #endregion

        #endregion

        #region :: Methods ::

        #region Method :: JsonResult :: GetAllApplicationInfo
        /// <summary>
        /// Get all application info
        /// </summary>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllApplicationSettings(int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var list = oIIApplicationSettingsService.IlGetAllApplicationSettings(this.CurrentApplicationID, nPage, nRows, sColumnName, sColumnOrder);
            return Json(list, JsonRequestBehavior.AllowGet);
        }
        #endregion


        #region Method :: JsonResult :: Edit application settings
        /// <summary>
        /// Edit application settings
        /// </summary>
        /// <param name="oApplicationSettingsViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JEditApplicationSettings(ApplicationSettingsViewModel oApplicationSettingsViewModel)
        {
            Response oResponseResult = null;

            oApplicationSettingsViewModel.MODIFIED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIIApplicationSettingsService.oUpdateApplicationSettings(oApplicationSettingsViewModel);
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

        #endregion
    }
}