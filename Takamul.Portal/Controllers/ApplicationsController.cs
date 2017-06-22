using Data.Core;
using ImageMagick;
using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Models;
using Takamul.Models.ViewModel;
using Takamul.Portal.Resources.Common;
using Takamul.Portal.Resources.Portal.Applications;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class ApplicationsController : BaseController
    {
        #region ::  State ::
        #region Private Members
        private IApplicationService oIApplicationService;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// ApplicationsController Constructor 
        /// </summary>
        /// <param name="oIApplicationServiceInitializer"></param>
        public ApplicationsController(IApplicationService oIApplicationServiceInitializer)
        {
            this.oIApplicationService = oIApplicationServiceInitializer;
        }
        #endregion

        #region :: Behaviour ::

        #region View :: ApplicationsList
        public ActionResult ApplicationsList()
        {
            if (BaseController.CurrentUser.UserType == enumUserType.Admin)
            {
                this.PageTitle = ApplicationResx.ApplicationsList;
                this.TitleHead = ApplicationResx.ApplicationsList;

                return View();
            }
            else
            {
                return RedirectToAction("Index", "AccessDenied");
            }
        }
        #endregion

        #region View :: PartialAddApplication
        /// <summary>
        ///  Add application
        /// </summary>
        /// <returns></returns>
        public PartialViewResult PartialAddApplication()
        {
            ApplicationViewModel oApplicationViewModel = new ApplicationViewModel();
            oApplicationViewModel.APPLICATION_EXPIRY_DATE = DateTime.Now;
            return PartialView("_AddApplication", oApplicationViewModel);
        }
        #endregion

        #region View :: PartialEditApplication
        /// <summary>
        ///  Edit application
        /// </summary>
        /// <returns></returns>
        public PartialViewResult PartialEditApplication(ApplicationViewModel oApplicationViewModel)
        {
            return PartialView("_EditApplication", oApplicationViewModel);
        }
        #endregion

        #endregion

        #region ::  Methods ::

        #region JsonResult :: Bind Grid All Applications
        /// <summary>
        /// Bind Training License Data
        /// </summary>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public JsonResult JBindAllApplications(int nSearchByApplicationID, string sSearchByApplicationName, int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var lstApplications = this.oIApplicationService.IlGetAllApplications(nSearchByApplicationID, sSearchByApplicationName, nPage, nRows);
            return Json(lstApplications, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region JsonResult :: JSetCurrentApplicationID
        /// <summary>
        /// Set Current Application ID In Current User Object
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JSetCurrentApplicationID(int nApplicationID)
        {
            this.OperationResult = enumOperationResult.Faild;
            this.OperationResultMessages = CommonResx.GeneralError;
            if (CurrentUser != null)
            {
                this.CurrentApplicationID = nApplicationID;
                this.OperationResult = enumOperationResult.Success;
                this.OperationResultMessages = CommonResx.MessageAddSuccess;
            }
            return Json(new
            {
                nResult = this.OperationResult,
                sResultMessages = this.OperationResultMessages
            }, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: Save Application Logo To Temp
        /// <summary>
        /// Save Application Logo To Temp
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JSaveApplicationLogoToTemp()
        {
            Response oResponseResult = new Response();
            string sRealFileName = string.Empty;
            string sModifiedFileName = string.Empty;
            string sFullFilePath = string.Empty;

            if (System.Web.HttpContext.Current.Request.Files.AllKeys.Any())
            {
                var oFile = System.Web.HttpContext.Current.Request.Files["ApplicationLogoFile"];
                HttpPostedFileBase filebase = new HttpPostedFileWrapper(oFile);

                sRealFileName = filebase.FileName;
                sModifiedFileName = CommonHelper.AppendTimeStamp(filebase.FileName);
                FileAccessHandler oFileAccessHandler = new FileAccessHandler();

                //DirectoryPath = TempUploadFolder from web.config 
                string sDirectoryPath = string.Concat(CommonHelper.sGetConfigKeyValue(ConstantNames.TempUploadFolder));
                sFullFilePath = Path.Combine(sDirectoryPath, sModifiedFileName);
                oFileAccessHandler.CreateDirectory(sDirectoryPath);
                if (oFileAccessHandler.OperationResult == 1)
                {
                    oFileAccessHandler.WirteFile(sFullFilePath, filebase.InputStream);
                    if (oFileAccessHandler.OperationResult == 1)
                    {
                        this.OperationResult = enumOperationResult.Success;
                    }
                    else
                    {
                        this.OperationResult = enumOperationResult.Faild;
                    }
                }
                else
                {
                    this.OperationResult = enumOperationResult.Faild;
                }
            }

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageAddSuccess;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageAddFailed;
                    break;
                case enumOperationResult.AlreadyExistRecordFaild:
                    this.OperationResultMessages = CommonResx.AlreadyExistRecordFaild;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages,
                    sFileName = (this.OperationResult == enumOperationResult.Success) ? sModifiedFileName : string.Empty,
                    sFullFilePath = (this.OperationResult == enumOperationResult.Success) ? sFullFilePath.Replace('\\', '/') : string.Empty
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Save Application
        /// <summary>
        /// Insert Application
        /// </summary>
        /// <param name="oTicketViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JSaveApplication(ApplicationViewModel oApplicationViewModel)
        {
            Response oResponseResult = null;

            var oFile = System.Web.HttpContext.Current.Request.Files["ApplicationLogoFile"];
            HttpPostedFileBase filebase = new HttpPostedFileWrapper(oFile);

            string sRealFileName = filebase.FileName;
            string sModifiedFileName = CommonHelper.AppendTimeStamp(filebase.FileName);

            oApplicationViewModel.APPLICATION_EXPIRY_DATE = DateTime.ParseExact(oApplicationViewModel.FORMATTED_EXPIRY_DATE, "dd/MM/yyyy", CultureInfo.InvariantCulture);
            oApplicationViewModel.APPLICATION_LOGO_PATH = sModifiedFileName;
            oApplicationViewModel.CREATED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIApplicationService.oInsertApplication(oApplicationViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    {
                        this.OperationResultMessages = CommonResx.MessageAddSuccess;
                        FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));

                        //DirectoryPath = Saved Application ID
                        string sDirectoryPath = oResponseResult.ResponseID;
                        string sFullFilePath = Path.Combine(sDirectoryPath, sModifiedFileName);
                        oFileAccessService.CreateDirectory(sDirectoryPath);
                        byte[] fileData = null;
                        using (var binaryReader = new BinaryReader(filebase.InputStream))
                        {
                            fileData = binaryReader.ReadBytes(filebase.ContentLength);
                        }
                        oFileAccessService.WirteFileByte(sFullFilePath, fileData);
                        this.OperationResult = enumOperationResult.Success;
                    }
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

        #region Method :: JsonResult :: Edit Application
        /// <summary>
        /// Edit Application
        /// </summary>
        /// <param name="oTicketViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JEditApplication(ApplicationViewModel oApplicationViewModel)
        {
            Response oResponseResult = null;
            string sRealFileName = string.Empty;
            string sModifiedFileName = string.Empty;
            HttpPostedFileBase filebase = null;
            var oFile = System.Web.HttpContext.Current.Request.Files["ApplicationLogoFile"];
            if (oFile != null)
            {
                filebase = new HttpPostedFileWrapper(oFile);
                if (filebase.ContentLength > 0)
                {
                    sRealFileName = filebase.FileName;
                    sModifiedFileName = CommonHelper.AppendTimeStamp(filebase.FileName);
                }
            }
            oApplicationViewModel.APPLICATION_EXPIRY_DATE = DateTime.ParseExact(oApplicationViewModel.FORMATTED_EXPIRY_DATE, "d/M/yyyy", CultureInfo.InvariantCulture);
            oApplicationViewModel.APPLICATION_LOGO_PATH = sModifiedFileName;
            oApplicationViewModel.MODIFIED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oIApplicationService.oUpdateApplication(oApplicationViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    {
                        this.OperationResultMessages = CommonResx.MessageAddSuccess;
                        if (oFile != null)
                        {
                            byte[] fileData = null;
                            using (var binaryReader = new BinaryReader(filebase.InputStream))
                            {
                                fileData = binaryReader.ReadBytes(filebase.ContentLength);
                            }

                            //MagickImage oMagickImage = new MagickImage(filebase.InputStream);
                            //oMagickImage.Format = MagickFormat.Icon;
                            //oMagickImage.Resize(72, 0);


                            FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));

                            //DirectoryPath = Saved Application ID
                            string sDirectoryPath = oApplicationViewModel.ID.ToString();
                            string sFullFilePath = Path.Combine(sDirectoryPath, sModifiedFileName);
                            oFileAccessService.CreateDirectory(sDirectoryPath);
                            
                            oFileAccessService.WirteFileByte(sFullFilePath, fileData);
                        }
                        this.OperationResult = enumOperationResult.Success;
                    }
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

        #endregion
    }
}