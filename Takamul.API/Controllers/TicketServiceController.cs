/*************************************************************************************************/
/* Class Name           : TicketServiceController.cs                                               */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:01 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage ticket operations                                                 */
/*************************************************************************************************/

using Infrastructure.Core;
using Infrastructure.Utilities;
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Http.Cors;
using Takamul.Models;
using Takamul.Models.ApiViewModel;
using Takamul.Models.ViewModel;
using Takamul.Services;

namespace Takamul.API.Controllers
{
    /// <summary>
    /// Ticket Service
    /// </summary>
    public class TicketServiceController : ApiController
    {
        #region ::   State   ::
        #region Private Members
        private readonly ITicketServices oITicketServices;
        #endregion
        #endregion

        #region :: Constructor ::
        public TicketServiceController(
                                        ITicketServices ITicketServicesInitializer
                                    )
        {
            oITicketServices = ITicketServicesInitializer;
        }
        #endregion

        #region :: Methods::

        #region Method :: HttpResponseMessage :: GetAllTickets
        // GET: api/TakamulTicket/GetAllTickets
        /// <summary>
        /// Get all tickets
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nUserID"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetAllTickets(int nApplicationID, int nUserID)
        {
            List<TakamulTicket> lstTakamulTicket = null;
            var lstTickets = this.oITicketServices.IlGetAllActiveTickets(nApplicationID, nUserID);
            if (lstTickets.Count() > 0)
            {
                lstTakamulTicket = new List<TakamulTicket>();
                foreach (var ticket in lstTickets)
                {
                    string sBase64DefaultImage = string.Empty;
                    if (!string.IsNullOrEmpty(ticket.DEFAULT_IMAGE))
                    {
                        FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                        byte[] oByteFile = oFileAccessService.ReadFile(ticket.DEFAULT_IMAGE);
                        if (oByteFile.Length > 0)
                        {
                            sBase64DefaultImage = Convert.ToBase64String(oByteFile);
                        }
                    }

                    TakamulTicket oTakamulTicket = new TakamulTicket()
                    {
                        TicketID = ticket.ID,
                        TicketCode = ticket.TICKET_CODE,
                        ApplicationID = ticket.APPLICATION_ID,
                        Base64DefaultImage = sBase64DefaultImage,
                        TicketName = ticket.TICKET_NAME,
                        TicketDescription = ticket.TICKET_DESCRIPTION,
                        TicketStatusID = ticket.TICKET_STATUS_ID,
                        TicketStatusRemark = ticket.TICKET_STATUS_REMARK,
                        TicketStatusName = ticket.TICKET_STATUS_NAME
                    };
                    
                    lstTakamulTicket.Add(oTakamulTicket);
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK, lstTakamulTicket);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetTicketDetails
        // GET: api/TakamulTicket/GetTicketDetails
        /// <summary>
        /// Get ticket details by ticket id
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetTicketDetails(int nTicketID)
        {
            TakamulTicket oTakamulTicket = null;
            TicketViewModel oTicketViewModel = this.oITicketServices.oGetTicketDetails(nTicketID);
            if (oTicketViewModel != null)
            {
                string sBase64DefaultImage = string.Empty;
                if (!string.IsNullOrEmpty(oTicketViewModel.DEFAULT_IMAGE))
                {
                    FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                    byte[] oByteFile = oFileAccessService.ReadFile(oTicketViewModel.DEFAULT_IMAGE);
                    if (oByteFile.Length > 0)
                    {
                        sBase64DefaultImage = Convert.ToBase64String(oByteFile);
                    }
                }

                oTakamulTicket = new TakamulTicket()
                {
                    TicketID = oTicketViewModel.ID,
                    ApplicationID = oTicketViewModel.APPLICATION_ID,
                    Base64DefaultImage = sBase64DefaultImage,
                    TicketCode = oTicketViewModel.TICKET_CODE,
                    TicketName = oTicketViewModel.TICKET_NAME,
                    TicketDescription = oTicketViewModel.TICKET_DESCRIPTION,
                    TicketStatusID = oTicketViewModel.TICKET_STATUS_ID,
                    TicketStatusRemark = oTicketViewModel.TICKET_STATUS_REMARK,
                    TicketStatusName = oTicketViewModel.TICKET_STATUS_NAME
                };
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulTicket);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetTicketChats
        // GET: api/TakamulTicket/GetTicketChats
        /// <summary>
        /// Get ticket chats by ticket id
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetTicketChats(int nTicketID)
        {
            List<TakamulTicketChat> lstTakamulTicket = null;
            List<TicketChatViewModel> lstTicketViewModel = this.oITicketServices.IlGetTicketChats(nTicketID);
            if (lstTicketViewModel.Count > 0)
            {
                lstTakamulTicket = new List<TakamulTicketChat>();
                foreach (var oTicketChatItem in lstTicketViewModel)
                {
                    string sReplyMessage = string.Empty;
                    string sBase64ReplyImage = string.Empty;
                    if (oTicketChatItem.TICKET_CHAT_TYPE_ID != 1)
                    {
                        FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                        byte[] oByteFile = oFileAccessService.ReadFile(oTicketChatItem.REPLY_FILE_PATH);
                        if (oByteFile.Length > 0)
                        {
                            sBase64ReplyImage = Convert.ToBase64String(oByteFile);
                        }
                    }
                    TakamulTicketChat oTakamulTicketChat = new TakamulTicketChat()
                    {
                        ApplicationID = oTicketChatItem.APPLICATION_ID,
                        TicketID = oTicketChatItem.TICKET_ID,
                        ReplyMessage = oTicketChatItem.REPLY_MESSAGE,
                        ReplyDate = oTicketChatItem.REPLIED_DATE,
                        TicketChatID = oTicketChatItem.ID,
                        TicketChatTypeID = oTicketChatItem.TICKET_CHAT_TYPE_ID,
                        TicketChatTypeName = oTicketChatItem.CHAT_TYPE,
                        UserFullName = oTicketChatItem.PARTICIPANT_FULL_NAME,
                        UserID = oTicketChatItem.TICKET_PARTICIPANT_ID,
                        Base64ReplyImage = sBase64ReplyImage
                    };

                    lstTakamulTicket.Add(oTakamulTicketChat);
                }

            }
            return Request.CreateResponse(HttpStatusCode.OK, lstTakamulTicket);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: CreateTicket
        // POST: api/TakamulTicket/CreateTicket
        /// <summary>
        /// Create a ticket
        /// </summary>
        /// <param name="oTakamulTicket"></param>
        /// <param name="nUserID"></param>
        /// <returns></returns>
        [HttpPost]
        public HttpResponseMessage CreateTicket(TakamulTicket oTakamulTicket, int nUserID)
        {
            ApiResponse oApiResponse = new ApiResponse();
            if (ModelState.IsValid)
            {
                try
                {
                    string sDefaultImagePath = string.Empty;
                    if (!string.IsNullOrEmpty(oTakamulTicket.Base64DefaultImage))
                    {
                        enumFileTypes oEnumFileTypes = (enumFileTypes)Enum.Parse(typeof(enumFileTypes), oTakamulTicket.DefaultImageType.ToString());
                        switch (oEnumFileTypes)
                        {
                            case enumFileTypes.png:
                                sDefaultImagePath = CommonHelper.AppendTimeStamp("fake.png");
                                break;
                            case enumFileTypes.jpg:
                                sDefaultImagePath = CommonHelper.AppendTimeStamp("fake.jpg");
                                break;
                            case enumFileTypes.jpeg:
                                sDefaultImagePath = CommonHelper.AppendTimeStamp("fake.jpeg");
                                break;
                        }
                    }

                    TicketViewModel oTicketViewModel = new TicketViewModel()
                    {
                        APPLICATION_ID = oTakamulTicket.ApplicationID,
                        TICKET_NAME = oTakamulTicket.TicketName,
                        TICKET_DESCRIPTION = oTakamulTicket.TicketDescription,
                        DEFAULT_IMAGE = sDefaultImagePath
                    };

                    Response oResponse = this.oITicketServices.oInsertTicket(oTicketViewModel, nUserID);
                    if (oResponse.OperationResult == enumOperationResult.Success)
                    {
                        if (!string.IsNullOrEmpty(sDefaultImagePath) && !string.IsNullOrEmpty(oTakamulTicket.Base64DefaultImage))
                        {
                            FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                            if (!oResponse.ResponseID.Equals("-99"))
                            {
                                Byte[] oArrImage = Convert.FromBase64String(oTakamulTicket.Base64DefaultImage);
                                string sDirectoyPath = Path.Combine(oTakamulTicket.ApplicationID.ToString(), oResponse.ResponseID);
                                oFileAccessService.CreateDirectory(sDirectoyPath);
                                oFileAccessService.WirteFileByte(Path.Combine(sDirectoyPath, sDefaultImagePath), oArrImage);
                            }
                        }
                        oApiResponse.OperationResult = 1;
                        oApiResponse.ResponseID = Convert.ToInt32(oResponse.ResponseID);
                        oApiResponse.OperationResultMessage = "Ticket has been successfully created.";
                    }
                    else
                    {
                        oApiResponse.OperationResult = 0;
                        oApiResponse.OperationResultMessage = "Ticket insert failed.";
                    }
                    return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);
                }
                catch (Exception)
                {
                    oApiResponse.OperationResult = 0;
                    oApiResponse.OperationResultMessage = "Internal sever error";
                    return Request.CreateResponse(HttpStatusCode.InternalServerError, oApiResponse);
                }
            }
            oApiResponse.OperationResult = 0;
            oApiResponse.OperationResultMessage = "Model validation failed";
            return Request.CreateResponse(HttpStatusCode.BadRequest, oApiResponse);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: PostTicketChat
        // POST: api/TakamulTicket/PostTicketChat
        /// <summary>
        /// Post a ticket chat
        /// </summary>
        /// <param name="oTakamulTicketChat"></param>
        /// <returns></returns>
        [HttpPost]
        public HttpResponseMessage PostTicketChat(TakamulTicketChat oTakamulTicketChat)
        {
            ApiResponse oApiResponse = new ApiResponse();
            if (ModelState.IsValid)
            {
                try
                {
                    string sReplyImagePath = string.Empty;
                    string sReplyImageDirectory = string.Empty;
                    string sFullFilePath = string.Empty;
                    if (!string.IsNullOrEmpty(oTakamulTicketChat.Base64ReplyImage))
                    {
                        sReplyImageDirectory = Path.Combine(oTakamulTicketChat.ApplicationID.ToString(), oTakamulTicketChat.TicketID.ToString());
                        enumFileTypes oEnumFileTypes = (enumFileTypes)Enum.Parse(typeof(enumFileTypes), oTakamulTicketChat.TicketChatTypeID.ToString());
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
                        sFullFilePath = Path.Combine(sReplyImageDirectory, sReplyImagePath);
                    }

                    TicketChatViewModel oTicketChatViewModel = new TicketChatViewModel()
                    {
                        TICKET_ID = oTakamulTicketChat.TicketID,
                        REPLY_MESSAGE = oTakamulTicketChat.ReplyMessage,
                        REPLY_FILE_PATH = sFullFilePath.Replace('\\', '/'),
                        TICKET_CHAT_TYPE_ID = oTakamulTicketChat.TicketChatTypeID,
                        TICKET_PARTICIPANT_ID = oTakamulTicketChat.UserID
                    };

                    Response oResponse = this.oITicketServices.oInsertTicketChat(oTicketChatViewModel);
                    if (oResponse.OperationResult == enumOperationResult.Success)
                    {
                        if (!string.IsNullOrEmpty(sFullFilePath) && !string.IsNullOrEmpty(oTakamulTicketChat.Base64ReplyImage))
                        {
                            FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                            Byte[] oArrImage = Convert.FromBase64String(oTakamulTicketChat.Base64ReplyImage);
                            oFileAccessService.CreateDirectory(sReplyImageDirectory);
                            oFileAccessService.WirteFileByte(Path.Combine(sReplyImageDirectory, sReplyImagePath), oArrImage);
                        }
                        oApiResponse.OperationResult = 1;
                    }
                    else
                    {
                        oApiResponse.OperationResult = 0;
                        oApiResponse.OperationResultMessage = "Chat post failed.";
                    }
                    return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);
                }
                catch (Exception Ex)
                {
                    oApiResponse.OperationResult = 0;
                    oApiResponse.OperationResultMessage = "Internal sever error :: " + Ex.Message.ToString();
                    return Request.CreateResponse(HttpStatusCode.InternalServerError, oApiResponse);
                }
            }
            oApiResponse.OperationResult = 0;
            oApiResponse.OperationResultMessage = "Model validation failed";
            return Request.CreateResponse(HttpStatusCode.BadRequest, oApiResponse);
        }
        #endregion

        #region Method :: HttpResponseMessage :: ResolveTicket
        // POST: api/TakamulTicket/UpdateTicket
        /// <summary>
        /// Post a ticket chat
        /// </summary>
        /// <param name="oTicketId"></param>
        /// /// <param name="oUserid"></param>
        /// <returns></returns>
        [HttpPost]
        public HttpResponseMessage ResolveTicket(int oTicketId,int oUserid)
        {
            ApiResponse oApiResponse = new ApiResponse();
            if (ModelState.IsValid)
            {
                try
                {                  

                    Response oResponse = this.oITicketServices.oResolveTicket(oTicketId,2, oUserid);
                    if (oResponse.OperationResult == enumOperationResult.Success)
                    {
                       
                        oApiResponse.OperationResult = 1;
                    }
                    else
                    {
                        oApiResponse.OperationResult = 0;
                        oApiResponse.OperationResultMessage = "Chat post failed.";
                    }
                    return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);
                }
                catch (Exception Ex)
                {
                    oApiResponse.OperationResult = 0;
                    oApiResponse.OperationResultMessage = "Internal sever error :: " + Ex.Message.ToString();
                    return Request.CreateResponse(HttpStatusCode.InternalServerError, oApiResponse);
                }
            }
            oApiResponse.OperationResult = 0;
            oApiResponse.OperationResultMessage = "Model validation failed";
            return Request.CreateResponse(HttpStatusCode.BadRequest, oApiResponse);
        }
        #endregion 

        #endregion
    }
}
