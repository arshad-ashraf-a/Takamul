﻿/*************************************************************************************************/
/* Class Name           : AuthenticationService.cs                                               */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 02:0 PM                                                     */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage authentication operation                                        */
/*************************************************************************************************/

using System.Collections.Generic;
using System.Data.Entity;
using Data.Core;
using Takamul.Models;
using Takamul.Models.ViewModel;
using System.Data.Common;
using System.Data;
using Infrastructure.Core;
using System;
using Infrastructure.Utilities;

namespace Takamul.Services
{
    public class AuthenticationService : EntityService<UserInfoViewModel>, IAuthenticationService
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;

        #endregion

        #region Properties

        #endregion

        #region :: Constructor ::
        public AuthenticationService(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: UserInfoViewModel :: oGetUserDetails
        /// <summary>
        ///  Get user details
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nUserID"></param>
        /// <param name="sPhoneNumber"></param>
        /// <returns></returns>
        public UserInfoViewModel oGetUserDetails(int nApplicationID, int nUserID, string sPhoneNumber)
        {
            UserInfoViewModel oUserInfoViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nUserID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PhoneNumber", SqlDbType.VarChar, sPhoneNumber, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<UserInfoViewModel> lstUserDetails = this.ExecuteStoredProcedureList<UserInfoViewModel>("GetMobileAppUserInfo", arrParameters.ToArray());
            if (lstUserDetails.Count > 0)
            {
                oUserInfoViewModel = new UserInfoViewModel();
                oUserInfoViewModel = lstUserDetails[0];
            }
            return oUserInfoViewModel;
            #endregion

        }
        #endregion

        #region Method :: Response :: oInsertMobileUser
        /// <summary>
        /// Insert Mobile User
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        public Response oInsertMobileUser(UserInfoViewModel oUserInfoViewModel)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, oUserInfoViewModel.APPLICATION_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserTypeId", SqlDbType.Int, oUserInfoViewModel.USER_TYPE_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_FullName", SqlDbType.NVarChar, oUserInfoViewModel.FULL_NAME, 100, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PhoneNumber", SqlDbType.VarChar, oUserInfoViewModel.PHONE_NUMBER, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Email", SqlDbType.VarChar, oUserInfoViewModel.EMAIL, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_CivilID", SqlDbType.VarChar, oUserInfoViewModel.CIVIL_ID, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Address", SqlDbType.VarChar, oUserInfoViewModel.ADDRESS, 300, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_AreaId", SqlDbType.Int, oUserInfoViewModel.AREA_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_WilayatId", SqlDbType.Int, oUserInfoViewModel.WILAYAT_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_VillageId", SqlDbType.Int, oUserInfoViewModel.VILLAGE_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_OTPNumber", SqlDbType.Int, oUserInfoViewModel.OTP_NUMBER, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_DeviceID", SqlDbType.VarChar, oUserInfoViewModel.DEVICE_ID, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PreferedLanguageID", SqlDbType.Int, oUserInfoViewModel.PREFERED_LANGUAGE_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_ApplicationName", SqlDbType.NVarChar, ParameterDirection.Output,200));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_UserID", SqlDbType.Int, ParameterDirection.Output));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("InsertMobileUser", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[15].Value.ToString());
                if (oResponse.OperationResult == enumOperationResult.Success)
                {
                    //Application Name
                    oResponse.ResponseCode = arrParameters[13].Value.ToString();
                    //Inserted UserID
                    oResponse.ResponseID = arrParameters[14].Value.ToString();
                }
            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = enumOperationResult.Faild;
                //TODO : Log Error Message
                oResponse.OperationResultMessage = Ex.Message.ToString();
            }

            return oResponse;
            #endregion
        }
        #endregion

        #region Method :: Response :: oValidateOTPNumber
        /// <summary>
        ///  Validate user otp number
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="sPhoneNumber"></param>
        /// <param name="nOTPNumber"></param>
        /// <param name="sDeviceID"></param>
        /// <returns></returns>
        public Response oValidateOTPNumber(int nApplicationID, string sPhoneNumber, int nOTPNumber, string sDeviceID)
        {
            #region ": Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PhoneNumber", SqlDbType.VarChar, sPhoneNumber, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_OTPNumber", SqlDbType.Int, nOTPNumber, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_DeviceID", SqlDbType.VarChar, sDeviceID, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("ValidateOPTNumber", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[4].Value.ToString());
            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = enumOperationResult.Faild;
                //TODO : Log Error Message
                oResponse.OperationResultMessage = Ex.Message.ToString();
            }

            return oResponse;
            #endregion
        }
        #endregion

        #region Method :: Response :: oResendOTPNumber
        /// <summary>
        ///  Resend user otp number
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="sPhoneNumber"></param>
        /// <param name="nOTPNumber"></param>
        /// <returns></returns>
        public Response oResendOTPNumber(int nApplicationID, string sPhoneNumber, int nOTPNumber)
        {
            #region ": Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PhoneNumber", SqlDbType.VarChar, sPhoneNumber, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_OTPNumber", SqlDbType.Int, nOTPNumber, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_ApplicationName", SqlDbType.NVarChar, ParameterDirection.Output, 200));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("ResendOPTNumber", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[4].Value.ToString());
                if (oResponse.OperationResult == enumOperationResult.Success)
                {
                    //Application Name
                    oResponse.ResponseCode = arrParameters[3].Value.ToString();
                }
            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = enumOperationResult.Faild;
                //TODO : Log Error Message
                oResponse.OperationResultMessage = Ex.Message.ToString();
            }

            return oResponse;
            #endregion
        }
        #endregion

        #region Method :: Response :: oUpdateOTPStatus
        /// <summary>
        /// Update the OTP Status
        /// </summary>
        /// <param name="nUserId"></param>
        /// <param name="bSmsSentStatus"></param>
        /// <returns></returns>
        public Response oUpdateOTPStatus(int nUserId, bool bSmsSentStatus)
        {
            #region ": Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nUserId, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_SmsSentStatus", SqlDbType.Bit, bSmsSentStatus, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("UpdateOTPStatus", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[2].Value.ToString());

            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = enumOperationResult.Faild;
                //TODO : Log Error Message
                oResponse.OperationResultMessage = Ex.Message.ToString();
            }

            return oResponse;
            #endregion
        }
        #endregion

        #endregion
    }
}
