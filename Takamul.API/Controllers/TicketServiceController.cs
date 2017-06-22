/*************************************************************************************************/
/* Class Name           : TicketServiceController.cs                                               */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:01 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage ticket operations                                                 */
/*************************************************************************************************/

using ImageMagick;
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
                    string sRemoteFilePath = string.Empty;
                    if (!string.IsNullOrEmpty(ticket.DEFAULT_IMAGE))
                    {
                        try
                        {
                            FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                            byte[] oByteFile = oFileAccessService.ReadFile(ticket.DEFAULT_IMAGE);
                            if (oByteFile.Length > 0)
                            {
                                sBase64DefaultImage = Convert.ToBase64String(oByteFile);
                            }

                            sRemoteFilePath = Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.RemoteFileServerPath), ticket.DEFAULT_IMAGE);
                        }
                        catch (Exception Ex)
                        {
                            sBase64DefaultImage = Ex.Message.ToString();
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
                        TicketStatusName = ticket.TICKET_STATUS_NAME,
                        RemoteFilePath = sRemoteFilePath,
                        CreatedDate = string.Format("{0} {1}", ticket.CREATED_DATE.ToShortDateString(), ticket.CREATED_DATE.ToShortTimeString())
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
        /// <returns>TakamulTicketChatRepo</returns>
        [HttpGet]
        public HttpResponseMessage GetTicketChats(int nTicketID)
        {
            TakamulTicketChatRepo oTakamulTicketChatRepo = new TakamulTicketChatRepo();
            List<TakamulTicketChat> lstTakamulTicket = null;
            List<TicketChatViewModel> lstTicketViewModel = this.oITicketServices.IlGetTicketChats(nTicketID);
            if (lstTicketViewModel.Count > 0)
            {
                lstTakamulTicket = new List<TakamulTicketChat>();
                foreach (var oTicketChatItem in lstTicketViewModel)
                {
                    string sReplyMessage = string.Empty;
                    string sBase64ReplyImage = string.Empty;
                    string sRemoteFilePath = string.Empty;
                    //ticket chat type 2:png , 3:jpg, 4:jpeg
                    if (oTicketChatItem.TICKET_CHAT_TYPE_ID == 2 || oTicketChatItem.TICKET_CHAT_TYPE_ID == 3 || oTicketChatItem.TICKET_CHAT_TYPE_ID == 4)
                    {
                        FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                        byte[] oByteFile = oFileAccessService.ReadFile(oTicketChatItem.REPLY_FILE_PATH);
                        if (oByteFile.Length > 0)
                        {
                            sBase64ReplyImage = Convert.ToBase64String(oByteFile);
                        }
                    }
                    if (oTicketChatItem.TICKET_CHAT_TYPE_ID != 1)
                    {
                        sRemoteFilePath = Path.Combine(CommonHelper.sGetConfigKeyValue(ConstantNames.RemoteFileServerPath), oTicketChatItem.REPLY_FILE_PATH);
                    }
                    TakamulTicketChat oTakamulTicketChat = new TakamulTicketChat()
                    {
                        ApplicationID = oTicketChatItem.APPLICATION_ID,
                        TicketID = oTicketChatItem.TICKET_ID,
                        ReplyMessage = oTicketChatItem.REPLY_MESSAGE,
                        ReplyDate = string.Format("{0} {1}", oTicketChatItem.REPLIED_DATE.ToShortDateString(), oTicketChatItem.REPLIED_DATE.ToShortTimeString()),
                        TicketChatID = oTicketChatItem.ID,
                        TicketChatTypeID = oTicketChatItem.TICKET_CHAT_TYPE_ID,
                        TicketChatTypeName = oTicketChatItem.CHAT_TYPE,
                        UserFullName = oTicketChatItem.PARTICIPANT_FULL_NAME,
                        UserID = oTicketChatItem.TICKET_PARTICIPANT_ID,
                        RemoteFilePath = sRemoteFilePath,
                        Base64ReplyImage = sBase64ReplyImage
                    };

                    lstTakamulTicket.Add(oTakamulTicketChat);
                    oTakamulTicketChatRepo.TakamulTicketChatList = lstTakamulTicket;
                }

                TicketViewModel oTicketViewModel = this.oITicketServices.oGetTicketDetails(nTicketID);
                TakamulTicket oTakamulTicket = null;
                if (oTicketViewModel != null)
                {
                    oTakamulTicket = new TakamulTicket()
                    {
                        TicketID = oTicketViewModel.ID,
                        ApplicationID = oTicketViewModel.APPLICATION_ID,
                        TicketCode = oTicketViewModel.TICKET_CODE,
                        TicketName = oTicketViewModel.TICKET_NAME,
                        TicketDescription = oTicketViewModel.TICKET_DESCRIPTION,
                        TicketStatusID = oTicketViewModel.TICKET_STATUS_ID,
                        TicketStatusRemark = oTicketViewModel.TICKET_STATUS_REMARK,
                        TicketStatusName = oTicketViewModel.TICKET_STATUS_NAME
                    };
                    oTakamulTicketChatRepo.TakamulTicket = oTakamulTicket;

                    //TODO:: Replace with original code
                    if (oTicketViewModel.TICKET_STATUS_ID == 3) //Rejected
                    {
                        oTakamulTicketChatRepo.RejectReason = "reject reason from database";
                    }
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulTicketChatRepo);
        }
        #endregion

        #region Method :: HttpResponseMessage :: CreateTicket
        // POST: api/TakamulTicket/CreateTicket
        /// <summary>
        /// Create a ticket
        /// </summary>
        /// <param name="oTakamulTicket"></param>
        /// <param name="nUserID"></param>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        [HttpPost]
        public HttpResponseMessage CreateTicket(TakamulTicket oTakamulTicket, int nUserID, int nLanguageID)
        {
            ApiResponse oApiResponse = new ApiResponse();
            string sResultMessage = string.Empty;
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
                    if (oResponse.nOperationResult == 1)
                    {
                        if (!string.IsNullOrEmpty(sDefaultImagePath) && !string.IsNullOrEmpty(oTakamulTicket.Base64DefaultImage))
                        {
                            FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                            if (!oResponse.ResponseID.Equals("-99"))
                            {
                                Byte[] oArrImage = Convert.FromBase64String(oTakamulTicket.Base64DefaultImage);

                                MagickImage oMagickImage = new MagickImage(oArrImage);
                                oMagickImage.Format = MagickFormat.Png;
                                oMagickImage.Resize(Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.ImageWidth)), Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.ImageHeight)));


                                string sDirectoyPath = Path.Combine(oTakamulTicket.ApplicationID.ToString(), oResponse.ResponseID);
                                oFileAccessService.CreateDirectory(sDirectoyPath);
                                oFileAccessService.WirteFileByte(Path.Combine(sDirectoyPath, sDefaultImagePath), oMagickImage.ToByteArray());
                            }
                        }
                        oApiResponse.OperationResult = 1;
                        oApiResponse.ResponseID = Convert.ToInt32(oResponse.ResponseID);
                        sResultMessage = nLanguageID == 2 ? "Ticket has been successfully created." : "تم إنشاء تذكرة بنجاح.";
                        oApiResponse.OperationResultMessage = sResultMessage;
                    }
                    else
                    {
                        switch (oResponse.nOperationResult)
                        {
                            case -5:
                                oApiResponse.OperationResult = -5;
                                sResultMessage = nLanguageID == 2 ? "The Application is expired." : "انتهت صلاحية الطلب.";
                                oApiResponse.OperationResultMessage = sResultMessage;
                                break;
                            case -6:
                                oApiResponse.OperationResult = -6;
                                sResultMessage = nLanguageID == 2 ? "OTP is not verified." : "لم يتم التحقق من مكتب المدعي العام.";
                                oApiResponse.OperationResultMessage = sResultMessage; break;
                            case -7:
                                oApiResponse.OperationResult = -7;
                                sResultMessage = nLanguageID == 2 ? "User is blocked." : "تم حظر المستخدم.";
                                oApiResponse.OperationResultMessage = sResultMessage;
                                break;
                            case -8:
                                oApiResponse.OperationResult = -8;
                                sResultMessage = nLanguageID == 2 ? "Ticket submission is restricted." : "يتم تقييد تقديم التذاكر.";
                                oApiResponse.OperationResultMessage = sResultMessage;
                                break;
                            case -9:
                                oApiResponse.OperationResult = -9;
                                sResultMessage = nLanguageID == 2 ? "Ticket Submission Interval Days reached." : "وصلت الفترات الزمنية لتقديم التذاكر.";
                                oApiResponse.OperationResultMessage = sResultMessage;
                                break;
                            default:
                                oApiResponse.OperationResult = 0;
                                sResultMessage = nLanguageID == 2 ? "An error occurred during the operation. Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى.";
                                oApiResponse.OperationResultMessage = sResultMessage;
                                break;
                        }
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
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns></returns>
        [HttpPost]
        public HttpResponseMessage PostTicketChat(TakamulTicketChat oTakamulTicketChat, int nLanguageID)
        {
            ApiResponse oApiResponse = new ApiResponse();
            string sResultMessage = string.Empty;
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
                    if (oResponse.nOperationResult == 1)
                    {
                        if (!string.IsNullOrEmpty(sFullFilePath) && !string.IsNullOrEmpty(oTakamulTicketChat.Base64ReplyImage))
                        {
                            FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));
                            Byte[] oArrImage = Convert.FromBase64String(oTakamulTicketChat.Base64ReplyImage);
                            oFileAccessService.CreateDirectory(sReplyImageDirectory);

                            enumFileTypes oEnumFileTypes = (enumFileTypes)Enum.Parse(typeof(enumFileTypes), oTakamulTicketChat.TicketChatTypeID.ToString());
                            if (oEnumFileTypes == enumFileTypes.jpeg || oEnumFileTypes == enumFileTypes.jpg ||
                                oEnumFileTypes == enumFileTypes.png)
                            {
                                MagickImage oMagickImage = new MagickImage(oArrImage);
                                oMagickImage.Format = MagickFormat.Png;
                                oMagickImage.Resize(Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.ImageWidth)), Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.ImageHeight)));
                                oFileAccessService.WirteFileByte(Path.Combine(sReplyImageDirectory, sReplyImagePath), oMagickImage.ToByteArray());
                            }
                            else
                            {
                                oFileAccessService.WirteFileByte(Path.Combine(sReplyImageDirectory, sReplyImagePath), oArrImage);
                            }
                            
                        }
                        oApiResponse.OperationResult = 1;
                        oApiResponse.OperationResultMessage = "Success.";
                    }
                    else
                    {
                        switch (oResponse.nOperationResult)
                        {
                            case -5:
                                oApiResponse.OperationResult = -5;
                                sResultMessage = nLanguageID == 2 ? "The Application is expired." : "انتهت صلاحية الطلب.";
                                oApiResponse.OperationResultMessage = sResultMessage;
                                break;
                            case -6:
                                oApiResponse.OperationResult = -6;
                                sResultMessage = nLanguageID == 2 ? "OTP is not verified." : "لم يتم التحقق من مكتب المدعي العام.";
                                oApiResponse.OperationResultMessage = sResultMessage; break;
                            case -7:
                                oApiResponse.OperationResult = -7;
                                sResultMessage = nLanguageID == 2 ? "User is blocked." : "تم حظر المستخدم.";
                                oApiResponse.OperationResultMessage = sResultMessage;
                                break;
                            case -8:
                                oApiResponse.OperationResult = -8;
                                sResultMessage = nLanguageID == 2 ? "Ticket submission is restricted." : "يتم تقييد تقديم التذاكر.";
                                oApiResponse.OperationResultMessage = sResultMessage;
                                break;
                            case -9:
                                oApiResponse.OperationResult = -9;
                                sResultMessage = nLanguageID == 2 ? "Ticket Submission Interval Days reached." : "وصلت الفترات الزمنية لتقديم التذاكر.";
                                oApiResponse.OperationResultMessage = sResultMessage;
                                break;
                            default:
                                oApiResponse.OperationResult = 0;
                                sResultMessage = nLanguageID == 2 ? "An error occurred during the operation. Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى.";
                                oApiResponse.OperationResultMessage = sResultMessage;
                                break;
                        }
                    }
                    return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);
                }
                catch (Exception Ex)
                {
                    oApiResponse.OperationResult = 0;
                    sResultMessage = nLanguageID == 2 ? "An error occurred during the operation. Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى.";
                    oApiResponse.OperationResultMessage = sResultMessage;
                    return Request.CreateResponse(HttpStatusCode.InternalServerError, oApiResponse);
                }
            }
            oApiResponse.OperationResult = 0;
            sResultMessage = nLanguageID == 2 ? "An error occurred during the operation. Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى.";
            oApiResponse.OperationResultMessage = sResultMessage;
            return Request.CreateResponse(HttpStatusCode.BadRequest, oApiResponse);
        }
        #endregion

        #region Method :: HttpResponseMessage :: ResolveTicket
        // POST: api/TakamulTicket/UpdateTicket
        /// <summary>
        /// Resolve a ticket 
        /// </summary>
        /// <param name="oTicketId"></param>
        /// /// <param name="oUserid"></param>
        /// /// <param name="nLanguageID"></param>
        /// <returns></returns>
        [HttpPost]
        public HttpResponseMessage ResolveTicket(int oTicketId, int oUserid, int nLanguageID)
        {
            ApiResponse oApiResponse = new ApiResponse();
            string sResultMessage = string.Empty;

            try
            {
                Response oResponse = this.oITicketServices.oResolveTicket(oTicketId, Convert.ToInt32(CommonHelper.sGetConfigKeyValue(ConstantNames.TicketStatusClosedID)), oUserid);
                if (oResponse.OperationResult == enumOperationResult.Success)
                {

                    oApiResponse.OperationResult = 1;
                    sResultMessage = nLanguageID == 2 ? "Ticket has been resolved." : "تم حل التذكرة.";
                    oApiResponse.OperationResultMessage = sResultMessage;
                }
                else
                {
                    oApiResponse.OperationResult = 0;
                    sResultMessage = nLanguageID == 2 ? "An error occurred during the operation. Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى.";
                    oApiResponse.OperationResultMessage = sResultMessage;
                }
                return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);
            }
            catch (Exception Ex)
            {
                oApiResponse.OperationResult = 0;
                sResultMessage = nLanguageID == 2 ? "An error occurred during the operation. Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى.";
                oApiResponse.OperationResultMessage = sResultMessage;
                return Request.CreateResponse(HttpStatusCode.InternalServerError, oApiResponse);
            }
        }
        #endregion 

        #region Method :: HttpResponseMessage :: DeleteTicket
        // POST: api/TakamulTicket/UpdateTicket
        /// <summary>
        /// Delete a ticket
        /// </summary>
        /// <param name="oTicketId"></param>
        /// /// <param name="oUserid"></param>
        /// /// <param name="nLanguageID"></param>
        /// <returns></returns>
        [HttpPost]
        public HttpResponseMessage DeleteTicket(int oTicketId, int oUserid, int nLanguageID)
        {
            ApiResponse oApiResponse = new ApiResponse();
            string sResultMessage = string.Empty;
            try
            {
                Response oResponse = this.oITicketServices.oDeleteTicket(oTicketId, oUserid);
                if (oResponse.OperationResult == enumOperationResult.Success)
                {

                    oApiResponse.OperationResult = 1;
                    sResultMessage = nLanguageID == 2 ? "Ticket has been deleted." : "تم حذف التذكرة.";
                    oApiResponse.OperationResultMessage = sResultMessage;
                }
                else
                {
                    oApiResponse.OperationResult = 0;
                    sResultMessage = nLanguageID == 2 ? "An error occurred during the operation. Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى.";
                    oApiResponse.OperationResultMessage = sResultMessage;
                }
                return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);
            }
            catch (Exception Ex)
            {
                oApiResponse.OperationResult = 0;
                sResultMessage = nLanguageID == 2 ? "An error occurred during the operation. Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى.";
                oApiResponse.OperationResultMessage = sResultMessage;
                return Request.CreateResponse(HttpStatusCode.InternalServerError, oApiResponse);
            }
        }
        #endregion 

        #endregion
    }
}
