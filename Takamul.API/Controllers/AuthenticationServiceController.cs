/*************************************************************************************************/
/* Class Name           : AuthenticationService.cs                                            */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:01 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage authentication services                                         */
/*************************************************************************************************/

using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Takamul.Models;
using Takamul.Models.ApiViewModel;
using Takamul.Models.ViewModel;
using Takamul.Services;

namespace Takamul.API.Controllers
{
    /// <summary>
    /// Authentication Service
    /// </summary>
    public class AuthenticationServiceController : ApiController
    {
        #region ::   State   ::
        #region Private Members
        private readonly IAuthenticationService oIAuthenticationService;
        #endregion
        #endregion

        #region :: Constructor ::
        public AuthenticationServiceController(
                                        IAuthenticationService IAuthenticationServiceInitializer
                                    )
        {
            oIAuthenticationService = IAuthenticationServiceInitializer;
        }
        #endregion

        #region :: Methods::

        #region Method :: HttpResponseMessage :: RegisterUser
        // POST: api/Authentication/RegisterUser
        /// <summary>
        /// Register a mobile user
        /// </summary>
        /// <param name="oTakamulUser"></param>
        /// <returns></returns>
        [HttpPost]
        public HttpResponseMessage RegisterUser(TakamulUser oTakamulUser)
        {
            ApiResponse oApiResponse = new ApiResponse();
            if (ModelState.IsValid)
            {
                try
                {
                    int nOTPNumber = CommonHelper.nGenerateRandomInteger(9999, 99999);

                    UserInfoViewModel oUserInfoViewModel = new UserInfoViewModel()
                    {
                        APPLICATION_ID = oTakamulUser.ApplicationID,
                        USER_TYPE_ID = 4, //Mobile user type
                        FULL_NAME = oTakamulUser.FullName,
                        PHONE_NUMBER = oTakamulUser.PhoneNumber,
                        EMAIL = oTakamulUser.Email,
                        ADDRESS = oTakamulUser.Addresss,
                        AREA_ID = oTakamulUser.AreaID,
                        WILAYAT_ID = oTakamulUser.WilayatID,
                        VILLAGE_ID = oTakamulUser.VillageID,
                        OTP_NUMBER = nOTPNumber
                    };

                    Response oResponse = this.oIAuthenticationService.oInsertMobileUser(oUserInfoViewModel);
                    if (oResponse.OperationResult == enumOperationResult.Success)
                    {
                        oApiResponse.OperationResult = 1;
                        oApiResponse.OperationResultMessage = "User registered successfully.";

                        oApiResponse.ResponseID = Convert.ToInt32(oResponse.ResponseID);
                        oApiResponse.ResponseCode = nOTPNumber.ToString();
                        //TODO::integrate with sms service and update status to database
                    }
                    else
                    {
                        oApiResponse.OperationResult = 0;
                        oApiResponse.OperationResultMessage = "Please contact app administrator.";
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

        #region Method :: HttpResponseMessage :: ResendOTPNumber
        //GET: api/Authentication/ResendOTPNumber? nUserID = &nOTPNumber =
        /// <summary>
        /// Resend user OTP Number
        /// </summary>
        /// <param name="nUserID"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage ResendOTPNumber(int nUserID)
        {
            ApiResponse oApiResponse = new ApiResponse();
            int nOTPNumber = CommonHelper.nGenerateRandomInteger(9999, 99999);
            Response oResponse = this.oIAuthenticationService.oResendOTPNumber(nUserID, nOTPNumber);

            if (oResponse.OperationResult == enumOperationResult.Success)
            {
                oApiResponse.OperationResult = 1;
                oApiResponse.OperationResultMessage = "OTP has been successfully sent.";

                //TODO::integrate with sms service and update status to database
                oApiResponse.ResponseCode = nOTPNumber.ToString();
            }
            else if (oResponse.OperationResult == enumOperationResult.RelatedRecordFaild)
            {
                oApiResponse.OperationResult = -2;
                oApiResponse.OperationResultMessage = "You have exceeded the maximum number of attempt.Please contact app administrator.";

                //TODO::integrate with sms service and update status to database
                oApiResponse.ResponseCode = nOTPNumber.ToString();
            }
            else
            {
                oApiResponse.OperationResult = 0;
                oApiResponse.OperationResultMessage = "An error occured.Please try again later.";
            }
            return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: ValidateOTPNumber
        // GET: api/Authentication/ValidateOTPNumber
        /// <summary>
        /// Validate user OTP Number
        /// </summary>
        /// <param name="nUserID"></param>
        /// <param name="nOTPNumber"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage ValidateOTPNumber(int nUserID, int nOTPNumber)
        {
            ApiResponse oApiResponse = new ApiResponse();
            Response oResponse = this.oIAuthenticationService.oValidateOTPNumber(nUserID, nOTPNumber);

            if (oResponse.OperationResult == enumOperationResult.Success)
            {
                oApiResponse.OperationResult = 1;
                oApiResponse.OperationResultMessage = "User verified successfully.";
            }
            else
            {
                oApiResponse.OperationResult = 0;
                oApiResponse.OperationResultMessage = "Please contact app administrator.";
            }
            return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetUserDetails
        // GET: api/Authentication/GetUserDetails
        /// <summary>
        /// Get user detailed infomations
        /// </summary>
        /// <param name="nUserID"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetUserDetails(int nUserID)
        {
            TakamulUser oTakamulUser = null;
            UserInfoViewModel oUserInfoViewModel = this.oIAuthenticationService.oGetUserDetails(nUserID);

            if (oUserInfoViewModel != null)
            {
                oTakamulUser = new TakamulUser()
                {
                    UserID = oUserInfoViewModel.ID,
                    ApplicationID = oUserInfoViewModel.APPLICATION_ID,
                    PhoneNumber = oUserInfoViewModel.PHONE_NUMBER,
                    Email = oUserInfoViewModel.EMAIL,
                    Addresss = oUserInfoViewModel.ADDRESS,
                    IsActive = (bool)oUserInfoViewModel.IS_ACTIVE,
                    IsUserBlocked = (bool)oUserInfoViewModel.IS_BLOCKED,
                    BlockedRemarks = oUserInfoViewModel.BLOCKED_REMARKS,
                    IsOTPVerified = (bool)oUserInfoViewModel.IS_OTP_VALIDATED,
                    IsSmsSent = oUserInfoViewModel.SMS_SENT_STATUS != null ? oUserInfoViewModel.SMS_SENT_STATUS : false,
                    IsTicketSubmissionRestricted = oUserInfoViewModel.IS_TICKET_SUBMISSION_RESTRICTED != null ? oUserInfoViewModel.IS_TICKET_SUBMISSION_RESTRICTED : true ,
                    TicketSubmissionIntervalDays = (int)oUserInfoViewModel.TICKET_SUBMISSION_INTERVAL_DAYS,
                    LastTicketSubmissionDate = oUserInfoViewModel.LAST_TICKET_SUBMISSION_DATE != null ? Convert.ToDateTime(oUserInfoViewModel.LAST_TICKET_SUBMISSION_DATE).ToString("dd/MM/yyyy") : ""
                };
            }

            return Request.CreateResponse(HttpStatusCode.OK, oTakamulUser);
        }
        #endregion

        #region Method :: HttpResponseMessage :: GetOTPForAppReinstall
        // GET: api/Authentication/GetOTPForAppReinstall
        /// <summary>
        /// Get user detailed infomations
        /// </summary>
        /// <param name="nPhoneNumber"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetOTPForAppReinstall(string nPhoneNumber)
        {
            ApiResponse oApiResponse = new ApiResponse();
            int nOTPNumber = CommonHelper.nGenerateRandomInteger(9999, 99999);
            Response oResponse = this.oIAuthenticationService.oOTPforAppReinstall(nPhoneNumber, nOTPNumber);

            if (oResponse.OperationResult == enumOperationResult.Success)
            {
                oApiResponse.OperationResult = 1;
                oApiResponse.OperationResultMessage = "OTP has been successfully sent.";

                //TODO::integrate with sms service and update status to database
                oApiResponse.ResponseCode = nOTPNumber.ToString();
            }
            else if (oResponse.OperationResult == enumOperationResult.RelatedRecordFaild)
            {
                oApiResponse.OperationResult = -2;
                oApiResponse.OperationResultMessage = "You have exceeded the maximum number of attempt.Please contact app administrator.";

                //TODO::integrate with sms service and update status to database
                oApiResponse.ResponseCode = nOTPNumber.ToString();
            }
            else
            {
                oApiResponse.OperationResult = 0;
                oApiResponse.OperationResultMessage = "An error occured.Please try again later.";
            }
            return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);

        }
        #endregion



        #endregion
    }
}
