using ImageMagick;
using Infrastructure.Core;
using Infrastructure.Utilities;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using System.Xml.Linq;
using Takamul.Models;
using Takamul.Models.ViewModel;
using Takamul.Portal.Resources.Common;
using Takamul.Portal.Resources.Portal.News;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class NewsController : DomainController
    {
        #region ::  State ::
        #region Private Members
        private INewsServices oINewsService;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// NewsesController Constructor 
        /// </summary>
        /// <param name="oINewsServiceInitializer"></param>
        public NewsController(INewsServices oINewsServiceInitializer)
        {
            this.oINewsService = oINewsServiceInitializer;
        }
        #endregion

        #region :: Behaviour ::

        #region View :: NewsList
        public ActionResult NewsList()
        {
            this.PageTitle = NewsResx.NewsList;
            this.TitleHead = NewsResx.NewsList;

            return View();
        }
        #endregion

        #region View :: PartialAddNews
        public ActionResult PartialAddNews()
        {
            this.PageTitle = NewsResx.AddNews;
            this.TitleHead = NewsResx.AddNews;

            NewsViewModel oNewsViewModel = new NewsViewModel();
            oNewsViewModel.PUBLISHED_DATE = DateTime.Now;
            return View("_AddNews", oNewsViewModel);
        }
        #endregion

        #region View :: PartialEditNews
        public ActionResult PartialEditNews(int nNewsID)
        {
            this.PageTitle = NewsResx.EditNews;
            this.TitleHead = NewsResx.EditNews;
            NewsViewModel oNewsViewModel = this.oINewsService.oGetNewsDetails(nNewsID);
            return View("_EditNews", oNewsViewModel);
        }
        #endregion

        #endregion

        #region ::  Methods ::

        #region JsonResult :: Bind Grid All News
        /// <summary>
        /// Bind all application News
        /// </summary>
        /// <param name="sSearchByNewsName"></param>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public JsonResult JBindAllNews(string sSearchByNewsName, int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var lstNews = this.oINewsService.IlGetAllNews(CurrentApplicationID, sSearchByNewsName, nPage, nRows, sColumnName, sColumnOrder, Convert.ToInt32(this.CurrentApplicationLanguage));
            return Json(lstNews, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Save news
        /// <summary>
        /// Save News
        /// </summary>
        /// <param name="oNewsViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JSaveNews(NewsViewModel oNewsViewModel)
        {
           
            Response oResponseResult = null;

            var oFile = System.Web.HttpContext.Current.Request.Files["NewsImage"];
            HttpPostedFileBase filebase = new HttpPostedFileWrapper(oFile);

            string sRealFileName = filebase.FileName;
            string sModifiedFileName = CommonHelper.AppendTimeStamp(filebase.FileName);
            oNewsViewModel.APPLICATION_ID = this.CurrentApplicationID;
            oNewsViewModel.LANGUAGE_ID = Convert.ToInt32(this.CurrentApplicationLanguage);
            oNewsViewModel.PUBLISHED_DATE = DateTime.ParseExact(string.Format("{0} {1}", oNewsViewModel.FORMATTED_PUBLISHED_DATE, oNewsViewModel.PUBLISHED_TIME), "dd/MM/yyyy HH:mm", CultureInfo.InvariantCulture);
            oNewsViewModel.NEWS_IMG_FILE_PATH = Path.Combine(CurrentApplicationID.ToString(), "News", sModifiedFileName).Replace('\\', '/');
            oNewsViewModel.CREATED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oINewsService.oInsertNews(oNewsViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    {
                        this.OperationResultMessages = CommonResx.MessageAddSuccess;

                        try
                        {
                            FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));

                            //DirectoryPath = Application ID + News Folder
                            string sDirectoryPath = Path.Combine(this.CurrentApplicationID.ToString(), "News");
                            string sFullFilePath = Path.Combine(sDirectoryPath, sModifiedFileName);
                            oFileAccessService.CreateDirectory(sDirectoryPath);

                            MagickImage oMagickImage = new MagickImage(filebase.InputStream);
                            oMagickImage.Format = MagickFormat.Jpg;
                            oMagickImage.Resize(Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.ImageWidth)), Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.ImageHeight)));

                            oFileAccessService.WirteFileByte(sFullFilePath, oMagickImage.ToByteArray());
                            this.OperationResult = enumOperationResult.Success;
                        }
                        catch (Exception ex)
                        {
                            this.OperationResultMessages = ex.Message.ToString();
                            //TODO :: Log this
                            Elmah.ErrorLog.GetDefault(System.Web.HttpContext.Current).Log(new Elmah.Error(ex));

                        }
                        if (oNewsViewModel.IS_NOTIFY_USER && oNewsViewModel.IS_ACTIVE)
                        {
                            string sNewsTitle = oNewsViewModel.NEWS_TITLE;
                            string sNewsDesc = oNewsViewModel.NEWS_CONTENT.Substring(0, Math.Min(oNewsViewModel.NEWS_CONTENT.Length, 150)) + "...";
                            bool bIsSendNotification = CommonHelper.SendPushNotificationNews(sNewsTitle, sNewsDesc, oResponseResult.ResponseCode, Convert.ToInt32(this.CurrentApplicationLanguage).ToString());
                            if (!bIsSendNotification)
                            {
                                Elmah.ErrorLog.GetDefault(System.Web.HttpContext.Current).Log(new Elmah.Error(new Exception("Could not send push notification.")));
                            }
                        }

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

        #region Method :: JsonResult :: Edit news
        /// <summary>
        /// Edit news
        /// </summary>
        /// <param name="oNewsViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JEditNews(NewsViewModel oNewsViewModel)
        {
            Response oResponseResult = null;
            string sRealFileName = string.Empty;
            string sModifiedFileName = string.Empty;
            HttpPostedFileBase filebase = null;
            var oFile = System.Web.HttpContext.Current.Request.Files["NewsImage"];
            if (oFile != null)
            {
                filebase = new HttpPostedFileWrapper(oFile);
                if (filebase.ContentLength > 0)
                {
                    sRealFileName = filebase.FileName;
                    sModifiedFileName = CommonHelper.AppendTimeStamp(filebase.FileName);
                    oNewsViewModel.NEWS_IMG_FILE_PATH = Path.Combine(this.CurrentApplicationID.ToString(), "News", sModifiedFileName).Replace('\\', '/');
                }
            }

            oNewsViewModel.PUBLISHED_DATE = DateTime.ParseExact(string.Format("{0} {1}", oNewsViewModel.FORMATTED_PUBLISHED_DATE, oNewsViewModel.PUBLISHED_TIME), "dd/MM/yyyy HH:mm", CultureInfo.InvariantCulture);

            oNewsViewModel.MODIFIED_BY = Convert.ToInt32(CurrentUser.nUserID);

            oResponseResult = this.oINewsService.oUpdateNews(oNewsViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    {
                        this.OperationResultMessages = CommonResx.MessageAddSuccess;
                        if (oFile != null)
                        {
                            try
                            {
                                FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));

                                //DirectoryPath = Saved Application ID + News Folder
                                string sDirectoryPath = Path.Combine(this.CurrentApplicationID.ToString(), "News");
                                string sFullFilePath = Path.Combine(sDirectoryPath, sModifiedFileName);
                                oFileAccessService.CreateDirectory(sDirectoryPath);

                                MagickImage oMagickImage = new MagickImage(filebase.InputStream);
                                oMagickImage.Format = MagickFormat.Png;
                                oMagickImage.Resize(Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.ImageWidth)), Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.ImageHeight)));

                                oFileAccessService.WirteFileByte(sFullFilePath, oMagickImage.ToByteArray());

                            }
                            catch (Exception ex)
                            {
                                this.OperationResultMessages = ex.Message.ToString();
                            }
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

        #region Method :: JsonResult :: Delete News
        /// <summary>
        ///  Delete event
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JDeleteNews(string ID)
        {
            Response oResponseResult = null;

            oResponseResult = this.oINewsService.oDeleteNews(Convert.ToInt32(ID));
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

        #region FileResult :: Download file
        /// <summary>
        /// Download file
        /// </summary>
        /// <param name="p"></param>
        /// <param name="d"></param>       
        /// <returns></returns>
        public FileResult Download(String p, String d)
        {
            return File(Path.Combine(Server.MapPath("~/UploadFolder/"), p), System.Net.Mime.MediaTypeNames.Application.Octet, d);
        }
        #endregion

        #region JsonResult :: Delete file
        /// <summary>
        /// Delete file
        /// </summary>
        /// <param name="id"></param>             
        /// <returns></returns>
        [HttpPost]
        public string DeleteFile(string id)
        {
            Response oResponseResult = new Response();
            try
            {
                NEWS files = this.oINewsService.oDeleteFile(Convert.ToString(id));
                //this.OperationResult = oResponseResult.OperationResult;

                if (files != null)
                {
                    this.OperationResultMessages = CommonResx.MessageDeleteSuccess;
                }
                else
                {
                    this.OperationResultMessages = CommonResx.MessageDeleteFailed;
                }

                ////TODO :: Delete file from the file system

            }

            catch (Exception ex)
            {

            }
            return this.OperationResultMessages;
        }
        #endregion
        #endregion
    }
}