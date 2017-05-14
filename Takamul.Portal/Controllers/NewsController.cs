using Infrastructure.Core;
using Infrastructure.Utilities;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using System.Xml.Linq;
using Takamul.Models;
using Takamul.Models.ViewModel;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class NewsController : BaseController
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
            this.PageTitle = "News List";
            this.TitleHead = "News List";

            return View();
        }
        #endregion

        #region View :: AddNewNews
        public ActionResult AddNewNews()
        {
            this.PageTitle = "Add New News";
            this.TitleHead = "Add New News";

            NewsViewModel oNewsViewModel = new NewsViewModel();
            oNewsViewModel.PUBLISHED_DATE = DateTime.Now;
            return View(oNewsViewModel);
        }
        #endregion

        #region View :: EditNews
        public ActionResult EditNews(int nNewsID)
        {
            NewsViewModel oNewsViewModel = this.oINewsService.oGetNewsDetails(nNewsID);
            this.PageTitle = "Edit New News";
            this.TitleHead = "Edit New News";
            return View(oNewsViewModel);
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
            var lstNews = this.oINewsService.IlGetAllNews(CurrentApplicationID, sSearchByNewsName, nPage, nRows, sColumnName, sColumnOrder);
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
            
            //oNewsViewModel.FileDetails = fileDetails;
             
            oNewsViewModel.CREATED_BY = Convert.ToInt32(CurrentUser.nUserID);
            oNewsViewModel.APPLICATION_ID = CurrentApplicationID;
            
           // int InsertedID = this.oINewsService.oInsertNews(oNewsViewModel);
            //this.OperationResult = oResponseResult.OperationResult;
            //FileDetail fileDetails = new FileDetail();
            for (int i = 0; i < Request.Files.Count; i++)
            {
                var file = Request.Files[i];
                if (file != null && file.ContentLength > 0)
                {
                    var fileName = Path.GetFileName(file.FileName);
                    oNewsViewModel.FileName = fileName;
                    oNewsViewModel.FileExtension = Path.GetExtension(fileName);
                    oNewsViewModel.FileId = Guid.NewGuid(); 

                    var path = Path.Combine(Server.MapPath("~/UploadFolder/"), oNewsViewModel.FileId + oNewsViewModel.FileExtension);
                    file.SaveAs(path);

                }

                oResponseResult = this.oINewsService.oInsertNews(oNewsViewModel);

                break;

            }
            

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageAddSuccess;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageAddFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = 1,
                    sResultMessages = CommonResx.MessageAddSuccess
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

            oNewsViewModel.CREATED_BY = Convert.ToInt32(CurrentUser.nUserID);
            oNewsViewModel.APPLICATION_ID = CurrentApplicationID;

            if (Request.Files.Count > 0)
            {
                for (int i = 0; i < Request.Files.Count; i++)
                {
                    var file = Request.Files[i];

                    if (file != null && file.ContentLength > 0)
                    {
                        var fileName = Path.GetFileName(file.FileName);
                        oNewsViewModel.FileExtension = Path.GetExtension(fileName);
                        oNewsViewModel.FileName = fileName;
                        oNewsViewModel.FileId = Guid.NewGuid();                        
                        var path = Path.Combine(Server.MapPath("~/UploadFolder/"), oNewsViewModel.FileId + oNewsViewModel.FileExtension);
                        file.SaveAs(path);
                        oResponseResult = this.oINewsService.oUpdateNews(oNewsViewModel);

                    }
                }
            }
            else
            {
                oResponseResult = this.oINewsService.oUpdateNews(oNewsViewModel);
                this.OperationResult = oResponseResult.OperationResult;
            }

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageAddSuccess;
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

                //Delete file from the file system
                var path = Path.Combine(Server.MapPath("~/UploadFolder/"), files.FileId + files.FileExtension);
                if (System.IO.File.Exists(path))
                {
                    System.IO.File.Delete(path);
                }

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