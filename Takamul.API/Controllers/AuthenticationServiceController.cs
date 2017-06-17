﻿/*************************************************************************************************/
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
        /// <para>-->[ApiResponse]-->[1:Success],[0:Failure],[-3:The user already exists.Please contact app administrator]</para>
        /// </summary>
        /// <param name="oTakamulUser"></param>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns>[1:Success],[0:Failure],[-3:The user already exists.Please contact app administrator]</returns>
        [HttpPost]
        public HttpResponseMessage RegisterUser(TakamulUser oTakamulUser, int nLanguageID)
        {
            ApiResponse oApiResponse = new ApiResponse();
            string sResultMessage = string.Empty;
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
                        sResultMessage = nLanguageID == 2 ? "User registered successfully." : "تم تسجيل المستخدم بنجاح.";
                        oApiResponse.OperationResultMessage = sResultMessage;

                        oApiResponse.ResponseID = Convert.ToInt32(oResponse.ResponseID);
                        oApiResponse.ResponseCode = nOTPNumber.ToString();
                        //TODO::integrate with sms service and update status to database
                    }
                    else if (oResponse.OperationResult == enumOperationResult.AlreadyExistRecordFaild)
                    {
                        oApiResponse.OperationResult = -3;
                        sResultMessage = nLanguageID == 2 ? "The user already exists.Please contact app administrator." : "لمستخدم موجود من قبل. الرجاء الاتصال بمشرف التطبيق.";
                        oApiResponse.OperationResultMessage = sResultMessage;

                    }
                    else
                    {
                        oApiResponse.OperationResult = 0;
                        sResultMessage = nLanguageID == 2 ? "Error Occured.Please contact app administrator." : "حدث خطأ الرجاء الاتصال بمشرف التطبيق.";
                        oApiResponse.OperationResultMessage = sResultMessage;
                    }
                    return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);
                }
                catch (Exception)
                {
                    oApiResponse.OperationResult = 0;
                    sResultMessage = nLanguageID == 2 ? "An error occurred during the operation. Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى";
                    oApiResponse.OperationResultMessage = sResultMessage;
                    return Request.CreateResponse(HttpStatusCode.InternalServerError, oApiResponse);
                }
            }
            oApiResponse.OperationResult = 0;
            sResultMessage = nLanguageID == 2 ? "Validation failed." : "أخفقت عملية التحقق.";
            oApiResponse.OperationResultMessage = sResultMessage;
            return Request.CreateResponse(HttpStatusCode.BadRequest, oApiResponse);
        }
        #endregion

        #region Method :: HttpResponseMessage :: ResendOTPNumber
        //GET: api/Authentication/ResendOTPNumber?nPhoneNumber=
        /// <summary>
        /// Resend user OTP Number by phone number
        /// <para>-->[ApiResponse]-->[1:Success],[0:Failure],[-2:You have exceeded the maximum number of attempt.Please contact app administrator.],[-3:The user does not exist.Please contact app administrator]</para>
        /// </summary>
        /// <param name="sPhoneNumber"></param>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns>[1:Success],[0:Failure],[-2:You have exceeded the maximum number of attempt.Please contact app administrator.],[-3:The user does not exist.Please contact app administrator]</returns>
        [HttpGet]
        public HttpResponseMessage ResendOTPNumber(string sPhoneNumber, int nLanguageID)
        {
            ApiResponse oApiResponse = new ApiResponse();
            int nOTPNumber = CommonHelper.nGenerateRandomInteger(9999, 99999);
            string sResultMessage = string.Empty;
            Response oResponse = this.oIAuthenticationService.oResendOTPNumber(sPhoneNumber, nOTPNumber);

            if (oResponse.OperationResult == enumOperationResult.Success)
            {
                oApiResponse.OperationResult = 1;
                sResultMessage = nLanguageID == 2 ? "OTP has been successfully sent." : "تم إرسال مكتب المدعي العام بنجاح.";
                oApiResponse.OperationResultMessage = sResultMessage;

                //TODO::integrate with sms service and update status to database
                oApiResponse.ResponseCode = nOTPNumber.ToString();
            }
            else if (oResponse.OperationResult == enumOperationResult.RelatedRecordFaild)
            {
                oApiResponse.OperationResult = -2;
                sResultMessage = nLanguageID == 2 ? "You have exceeded the maximum number of attempt.Please contact app administrator." : "لقد تجاوزت الحد الأقصى لعدد المحاولات. يرجى الاتصال بمشرف التطبيق.";
                oApiResponse.OperationResultMessage = sResultMessage;
            }
            else if (oResponse.OperationResult == enumOperationResult.AlreadyExistRecordFaild)
            {
                oApiResponse.OperationResult = -3;
                sResultMessage = nLanguageID == 2 ? "The user does not exist.Please contact app administrator" : "المستخدم غير موجود. يرجى الاتصال بمشرف التطبيق";
                oApiResponse.OperationResultMessage = sResultMessage;
            }
            else
            {
                oApiResponse.OperationResult = 0;
                sResultMessage = nLanguageID == 2 ? "An error occured.Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى";
                oApiResponse.OperationResultMessage = sResultMessage;
            }
            return Request.CreateResponse(HttpStatusCode.OK, oApiResponse);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: ValidateOTPNumber
        // GET: api/Authentication/ValidateOTPNumber
        /// <summary>
        /// Validate user OTP Number by phone number
        /// <para>-->[ApiResponse]-->[1:Success],[0:Failure],[-3:The user does not exist.Please contact app administrator]</para>
        /// <para>-->[TakamulUserResponse]</para>
        /// </summary>
        /// <param name="sPhoneNumber"></param>
        /// <param name="nOTPNumber"></param>
        /// <param name="nLanguageID">[1:Arabic],[2:English]</param>
        /// <returns>[1:Success],[0:Failure],[-3:The user does not exist.Please contact app administrator]</returns>
        [HttpGet]
        public HttpResponseMessage ValidateOTPNumber(string sPhoneNumber, int nOTPNumber, int nLanguageID)
        {
            TakamulUserResponse oTakamulUserResponse = new TakamulUserResponse();
            ApiResponse oApiResponse = new ApiResponse();
            string sResultMessage = string.Empty;
            Response oResponse = this.oIAuthenticationService.oValidateOTPNumber(sPhoneNumber, nOTPNumber);

            if (oResponse.OperationResult == enumOperationResult.Success)
            {
                UserInfoViewModel oUserInfoViewModel = this.oIAuthenticationService.oGetUserDetails(-99, sPhoneNumber);
                TakamulUser oTakamulUser = new TakamulUser()
                {
                    UserID = oUserInfoViewModel.ID,
                    ApplicationID = Convert.ToInt32(oUserInfoViewModel.APPLICATION_ID),
                    PhoneNumber = oUserInfoViewModel.PHONE_NUMBER,
                    Email = oUserInfoViewModel.EMAIL,
                    Addresss = oUserInfoViewModel.ADDRESS,
                    IsActive = (bool)oUserInfoViewModel.IS_ACTIVE,
                    IsUserBlocked = (bool)oUserInfoViewModel.IS_BLOCKED,
                    BlockedRemarks = oUserInfoViewModel.BLOCKED_REMARKS,
                    IsOTPVerified = (bool)oUserInfoViewModel.IS_OTP_VALIDATED,
                    IsSmsSent = oUserInfoViewModel.SMS_SENT_STATUS != null ? oUserInfoViewModel.SMS_SENT_STATUS : false,
                    IsTicketSubmissionRestricted = oUserInfoViewModel.IS_TICKET_SUBMISSION_RESTRICTED != null ? oUserInfoViewModel.IS_TICKET_SUBMISSION_RESTRICTED : true,
                    TicketSubmissionIntervalDays = (int)oUserInfoViewModel.TICKET_SUBMISSION_INTERVAL_DAYS,
                    LastTicketSubmissionDate = oUserInfoViewModel.LAST_TICKET_SUBMISSION_DATE != null ? Convert.ToDateTime(oUserInfoViewModel.LAST_TICKET_SUBMISSION_DATE).ToString("dd/MM/yyyy") : ""
                };
                oTakamulUserResponse.TakamulUser = oTakamulUser;
                oApiResponse.OperationResult = 1;
                sResultMessage = nLanguageID == 2 ? "User verified successfully." : "تم التحقق من المستخدم بنجاح.";
                oApiResponse.OperationResultMessage = sResultMessage;

            }
            else if (oResponse.OperationResult == enumOperationResult.AlreadyExistRecordFaild)
            {
                oApiResponse.OperationResult = -3;
                sResultMessage = nLanguageID == 2 ? "The user does not exist.Please contact app administrator": "المستخدم غير موجود. يرجى الاتصال بمشرف التطبيق.";
                oApiResponse.OperationResultMessage = sResultMessage;
            }
            else
            {
                oApiResponse.OperationResult = 0;
                sResultMessage = nLanguageID == 2 ? "An error occurred during the operation. Please try again later." : "حدث خطأ اثناء العملية يرجى المحاولة لاحقا مرة اخرى.";
                oApiResponse.OperationResultMessage = sResultMessage;
            }
            oTakamulUserResponse.ApiResponse = oApiResponse;
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulUserResponse);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetUserDetails
        // GET: api/Authentication/GetUserDetails
        /// <summary>
        /// Get user detailed infomations by user id 
        /// </summary>
        /// <param name="nUserID"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetUserDetails(int nUserID)
        {
            TakamulUser oTakamulUser = null;
            UserInfoViewModel oUserInfoViewModel = this.oIAuthenticationService.oGetUserDetails(nUserID, string.Empty);

            if (oUserInfoViewModel != null)
            {
                oTakamulUser = new TakamulUser()
                {
                    UserID = oUserInfoViewModel.ID,
                    ApplicationID = Convert.ToInt32(oUserInfoViewModel.APPLICATION_ID),
                    PhoneNumber = oUserInfoViewModel.PHONE_NUMBER,
                    Email = oUserInfoViewModel.EMAIL,
                    Addresss = oUserInfoViewModel.ADDRESS,
                    IsActive = (bool)oUserInfoViewModel.IS_ACTIVE,
                    IsUserBlocked = (bool)oUserInfoViewModel.IS_BLOCKED,
                    BlockedRemarks = oUserInfoViewModel.BLOCKED_REMARKS,
                    IsOTPVerified = (bool)oUserInfoViewModel.IS_OTP_VALIDATED,
                    IsSmsSent = oUserInfoViewModel.SMS_SENT_STATUS != null ? oUserInfoViewModel.SMS_SENT_STATUS : false,
                    IsTicketSubmissionRestricted = oUserInfoViewModel.IS_TICKET_SUBMISSION_RESTRICTED != null ? oUserInfoViewModel.IS_TICKET_SUBMISSION_RESTRICTED : true,
                    TicketSubmissionIntervalDays = (int)oUserInfoViewModel.TICKET_SUBMISSION_INTERVAL_DAYS,
                    LastTicketSubmissionDate = oUserInfoViewModel.LAST_TICKET_SUBMISSION_DATE != null ? Convert.ToDateTime(oUserInfoViewModel.LAST_TICKET_SUBMISSION_DATE).ToString("dd/MM/yyyy") : ""
                };
            }

            return Request.CreateResponse(HttpStatusCode.OK, oTakamulUser);
        }
        #endregion

        #region Method :: HttpResponseMessage :: GetUserDetailsByPhoneNumber
        // GET: api/Authentication/GetUserDetailsByPhoneNumber
        /// <summary>
        /// Get user detailed infomations by phone number
        /// </summary>
        /// <param name="sPhoneNumber"></param>
        /// <returns></returns>
        [HttpGet]
        public HttpResponseMessage GetUserDetailsByPhoneNumber(string sPhoneNumber)
        {
            TakamulUser oTakamulUser = null;
            UserInfoViewModel oUserInfoViewModel = this.oIAuthenticationService.oGetUserDetails(-99, sPhoneNumber);

            if (oUserInfoViewModel != null)
            {
                oTakamulUser = new TakamulUser()
                {
                    UserID = oUserInfoViewModel.ID,
                    ApplicationID = Convert.ToInt32(oUserInfoViewModel.APPLICATION_ID),
                    PhoneNumber = oUserInfoViewModel.PHONE_NUMBER,
                    Email = oUserInfoViewModel.EMAIL,
                    Addresss = oUserInfoViewModel.ADDRESS,
                    IsActive = (bool)oUserInfoViewModel.IS_ACTIVE,
                    IsUserBlocked = (bool)oUserInfoViewModel.IS_BLOCKED,
                    BlockedRemarks = oUserInfoViewModel.BLOCKED_REMARKS,
                    IsOTPVerified = (bool)oUserInfoViewModel.IS_OTP_VALIDATED,
                    IsSmsSent = oUserInfoViewModel.SMS_SENT_STATUS != null ? oUserInfoViewModel.SMS_SENT_STATUS : false,
                    IsTicketSubmissionRestricted = oUserInfoViewModel.IS_TICKET_SUBMISSION_RESTRICTED != null ? oUserInfoViewModel.IS_TICKET_SUBMISSION_RESTRICTED : true,
                    TicketSubmissionIntervalDays = (int)oUserInfoViewModel.TICKET_SUBMISSION_INTERVAL_DAYS,
                    LastTicketSubmissionDate = oUserInfoViewModel.LAST_TICKET_SUBMISSION_DATE != null ? Convert.ToDateTime(oUserInfoViewModel.LAST_TICKET_SUBMISSION_DATE).ToString("dd/MM/yyyy") : ""
                };
            }

            return Request.CreateResponse(HttpStatusCode.OK, oTakamulUser);
        }
        #endregion

        #endregion
    }
}
