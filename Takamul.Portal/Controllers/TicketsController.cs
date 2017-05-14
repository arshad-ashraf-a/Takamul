using Infrastructure.Core;
using Infrastructure.Utilities;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
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
    public class TicketsController : BaseController
    {
        #region ::  State ::
        #region Private Members
        private ITicketServices oITicketServices;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// TicketsController Constructor 
        /// </summary>
        /// <param name="oITicketServicesInitializer"></param>
        public TicketsController(ITicketServices oITicketServicesInitializer)
        {
            this.oITicketServices = oITicketServicesInitializer;
        }
        #endregion

        #region :: Behaviour ::

        #region View :: TicketsList
        public ActionResult TicketsList()
        {
            this.PageTitle = "Tickets List";
            this.TitleHead = "Tickets List";

            return View();
        }
        #endregion

        #region View :: TicketDetails
        public ActionResult TicketDetails(int nTicketID)
        {
            TicketViewModel oTicketViewModel = this.oITicketServices.oGetTicketDetails(nTicketID);
            this.PageTitle = "Ticket Details";
            this.TitleHead = "Ticket Details";

            return View(oTicketViewModel);
        }
        #endregion

        #region View :: PartialUpdateTicket
        /// <summary>
        ///  Edit area master
        /// </summary>
        /// <param name="oTicketViewModel"></param>
        /// <returns></returns>
        public PartialViewResult PartialUpdateTicket(TicketViewModel oTicketViewModel)
        {
            return PartialView("_UpdateTicket", oTicketViewModel);
        }
        #endregion

        #endregion

        #region ::  Methods ::

        #region JsonResult :: Bind Grid All Tickets
        /// <summary>
        /// Bind all application tickets
        /// </summary>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public JsonResult JBindAllTickets(string sTicketCode, string sTicketName, int nTicketStatusId, int nParticipantID, int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var lstEvents = this.oITicketServices.IlGetAllTickets(CurrentApplicationID, nParticipantID, nTicketStatusId, sTicketCode, sTicketName, nPage, nRows);
            return Json(lstEvents, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: JGetTicketChats
        /// <summary>
        /// Get ticket chats
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetTicketChats(int nTicketID)
        {
            var lstTicketChats = this.oITicketServices.IlGetTicketChats(nTicketID);
            return Json(lstTicketChats, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: Send Chat
        /// <summary>
        /// Send Chat 
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JSendChat(int nTicketID, string sChatMessage)
        {

            TicketChatViewModel oTicketChatViewModel = new TicketChatViewModel()
            {
                TICKET_ID = nTicketID,
                REPLY_MESSAGE = sChatMessage,
                TICKET_CHAT_TYPE_ID = 1,
                TICKET_PARTICIPANT_ID = CurrentUser.nUserID
            };

            Response oResponse = this.oITicketServices.oInsertTicketChat(oTicketChatViewModel);
            this.OperationResult = oResponse.OperationResult;
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

        #region Method :: Save Chat File
        /// <summary>
        /// Save Chat File
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JSaveChatFile(int nTicketID, int nChatTypeID)
        {
            if (nTicketID != 99)
            {
                string sReplyImagePath = string.Empty;
                string sReplyImageDirectory = string.Empty;
                string sFullFilePath = string.Empty;
                if (System.Web.HttpContext.Current.Request.Files.AllKeys.Any())
                {
                    var oFile = System.Web.HttpContext.Current.Request.Files["ChatFile"];
                    HttpPostedFileBase filebase = new HttpPostedFileWrapper(oFile);

                    sReplyImageDirectory = Path.Combine(CurrentApplicationID.ToString(), nTicketID.ToString());

                    #region Create dynamic file name based on file type
                    enumFileTypes oEnumFileTypes = (enumFileTypes)Enum.Parse(typeof(enumFileTypes), nChatTypeID.ToString());
                    switch (oEnumFileTypes)
                    {
                        case enumFileTypes.png:
                            sReplyImagePath = CommonHelper.AppendTimeStamp("fake.png");
                            break;
                        case enumFileTypes.jpg:
                            sReplyImagePath = CommonHelper.AppendTimeStamp("fake.jpg");
                            break;
                        case enumFileTypes.jpeg:
                            sReplyImagePath = CommonHelper.AppendTimeStamp("fake.jpeg");
                            break;
                        case enumFileTypes.doc:
                            sReplyImagePath = CommonHelper.AppendTimeStamp("fake.doc");
                            break;
                        case enumFileTypes.docx:
                            sReplyImagePath = CommonHelper.AppendTimeStamp("fake.docx");
                            break;
                        case enumFileTypes.pdf:
                            sReplyImagePath = CommonHelper.AppendTimeStamp("fake.pdf");
                            break;
                    }
                    #endregion

                    sFullFilePath = Path.Combine(sReplyImageDirectory, sReplyImagePath);

                    TicketChatViewModel oTicketChatViewModel = new TicketChatViewModel()
                    {
                        TICKET_ID = nTicketID,
                        REPLY_FILE_PATH = sFullFilePath.Replace('\\', '/'),
                        TICKET_CHAT_TYPE_ID = nChatTypeID,
                        TICKET_PARTICIPANT_ID = CurrentUser.nUserID
                    };

                    Response oResponse = this.oITicketServices.oInsertTicketChat(oTicketChatViewModel);
                    if (oResponse.OperationResult == enumOperationResult.Success)
                    {
                        if (!string.IsNullOrEmpty(sFullFilePath))
                        {
                            FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                            MemoryStream target = new MemoryStream();
                            filebase.InputStream.CopyTo(target);
                            byte[] oArrImage = target.ToArray();

                            oFileAccessService.CreateDirectory(sReplyImageDirectory);
                            oFileAccessService.WirteFileByte(Path.Combine(sReplyImageDirectory, sReplyImagePath), oArrImage);
                        }
                        this.OperationResult = enumOperationResult.Success;
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
                }

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

        #region Method :: ActionResult :: DownloadFile
        public virtual ActionResult DownloadFile(int nTicketID, string sFileName)
        {
            byte[] oFileToDownload = null;
            FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));

            try
            {
                string sFileFullPath = Path.Combine(this.CurrentApplicationID.ToString(), nTicketID.ToString(), sFileName);
                oFileToDownload = oFileAccessService.ReadFile(sFileFullPath);
            }
            catch (Exception ex) {

            }
            return File(oFileToDownload, "application/force-download", sFileName);
        }
        #endregion

        #region Method :: JsonResult :: JGetTop5Tickets
        /// <summary>
        /// Get ticket chats
        /// </summary>
        /// <returns></returns>
        [HttpGet]
        public JsonResult JGetTop5Tickets()
        {
            var lstOpenTickets = this.oITicketServices.lGetTop5TicketsByStatus(this.CurrentApplicationID, Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.TicketStatusOpenID)));
            var lstClosedTickets = this.oITicketServices.lGetTop5TicketsByStatus(this.CurrentApplicationID, Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.TicketStatusClosedID)));
            var lstRejectedTickets = this.oITicketServices.lGetTop5TicketsByStatus(this.CurrentApplicationID, Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.TicketStatusRejectedID)));
            return Json(new
            {
                lstOpenTickets = lstOpenTickets,
                lstClosedTickets = lstClosedTickets,
                lstRejectedTickets = lstRejectedTickets
            }, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Edit Ticket
       /// <summary>
       /// Edit Ticket
       /// </summary>
       /// <param name="nTicketID"></param>
       /// <param name="bIsActive"></param>
       /// <param name="nTicketStatusID"></param>
       /// <param name="sRejectReason"></param>
       /// <returns></returns>
        [HttpPost]
        public JsonResult JEditTicket(int nTicketID,bool bIsActive, int nTicketStatusID,string sRejectReason)
        {
            Response oResponseResult = null;

            oResponseResult = this.oITicketServices.oUpdateTicket(nTicketID,nTicketStatusID,bIsActive,sRejectReason,CurrentUser.nUserID);
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