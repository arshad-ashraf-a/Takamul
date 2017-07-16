/*************************************************************************************************/
/* Class Name           : UserServices.cs                                                        */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 02:0 PM                                                     */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage user operations                                                 */
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

namespace Takamul.Services
{
    public class UserServices : EntityService<Lookup>, IUserServices
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;

        #endregion

        #region Properties

        #endregion

        #region :: Constructor ::
        public UserServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<UserInfoViewModel> :: lGetApplicationUsers
        /// <summary>
        ///  Get list of application users
        /// </summary>
        /// <returns></returns>
        public List<UserInfoViewModel> lGetApplicationUsers(int nApplicationID, int nUserTypeID, string sUserSeach, int nPageNumber, int nRowspPage)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserType", SqlDbType.Int, nUserTypeID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserSearch", SqlDbType.VarChar, sUserSeach, 100, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, nPageNumber, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, nRowspPage, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<UserInfoViewModel> lstUsers = this.ExecuteStoredProcedureList<UserInfoViewModel>("GetApplicationUsers", arrParameters.ToArray());
            return lstUsers;

            #endregion

        }
        #endregion

        #region Method :: List<UserInfoViewModel> :: lGetApplicationUsers
        /// <summary>
        /// Get application users
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nUserTypeIDs"></param>
        /// <returns></returns>
        public List<UserInfoViewModel> lGetApplicationUsers(int nApplicationID, string nUserTypeIDs)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserTypeIds", SqlDbType.VarChar, nUserTypeIDs, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<UserInfoViewModel> lstTicketUsers = this.ExecuteStoredProcedureList<UserInfoViewModel>("GetApplicationUsersByUserTypes", arrParameters.ToArray());
            return lstTicketUsers;
            #endregion

        }
        #endregion

        #region Method :: List<UserInfoViewModel> :: lGetAllMembers
        /// <summary>
        ///  Get list of member users
        /// </summary>
        /// <returns></returns>
        public List<UserInfoViewModel> lGetAllMembers(string sUserSeach, int nPageNumber, int nRowspPage)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_MemberId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_MemberName", SqlDbType.VarChar, sUserSeach, 100, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, nPageNumber, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, nRowspPage, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<UserInfoViewModel> lstUsers = this.ExecuteStoredProcedureList<UserInfoViewModel>("GetAllMembers", arrParameters.ToArray());
            return lstUsers;

            #endregion

        }
        #endregion

        #region Method :: UserInfoViewModel :: oGetUserDetails
        /// <summary>
        ///  Get user details
        /// </summary>
        /// <returns></returns>
        public UserInfoViewModel oGetUserDetails(int nUserID)
        {
            UserInfoViewModel oUserInfoViewModel = new UserInfoViewModel();
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nUserID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserType", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserSearch", SqlDbType.VarChar, string.Empty, 100, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, 1, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, 1, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<UserInfoViewModel> lstUsers = this.ExecuteStoredProcedureList<UserInfoViewModel>("GetApplicationUsers", arrParameters.ToArray());
            if (lstUsers.Count == 1)
            {
                oUserInfoViewModel = lstUsers[0];
                enumUserType oEnmUserType = (enumUserType)Enum.Parse(typeof(enumUserType), oUserInfoViewModel.USER_TYPE_ID.ToString(), true);
                oUserInfoViewModel.UserType = oEnmUserType;
            }
            return oUserInfoViewModel;

            #endregion

        }
        #endregion

        #region Method :: UserInfoViewModel :: oGetUserDetails
        /// <summary>
        ///  Get user details
        /// </summary>
        /// <returns></returns>
        public UserInfoViewModel oGetUserDetails(int nUserID,int nLanguageID)
        {
            UserInfoViewModel oUserInfoViewModel = new UserInfoViewModel();
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nUserID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLanguageID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<UserInfoViewModel> lstUsers = this.ExecuteStoredProcedureList<UserInfoViewModel>("GetUserDetails", arrParameters.ToArray());
            if (lstUsers.Count == 1)
            {
                oUserInfoViewModel = lstUsers[0];
                enumUserType oEnmUserType = (enumUserType)Enum.Parse(typeof(enumUserType), oUserInfoViewModel.USER_TYPE_ID.ToString(), true);
                oUserInfoViewModel.UserType = oEnmUserType;
            }
            return oUserInfoViewModel;

            #endregion

        }
        #endregion

        #region Method :: Response :: oInsertUser
        /// <summary>
        /// Insert Mobile User
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        public Response oInsertUser(UserInfoViewModel oUserInfoViewModel)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, oUserInfoViewModel.APPLICATION_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserTypeId", SqlDbType.Int, oUserInfoViewModel.USER_TYPE_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserName", SqlDbType.VarChar, oUserInfoViewModel.USER_NAME, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Password", SqlDbType.VarChar, oUserInfoViewModel.PASSWORD, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_FullName", SqlDbType.NVarChar, oUserInfoViewModel.FULL_NAME, 100, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PhoneNumber", SqlDbType.VarChar, oUserInfoViewModel.PHONE_NUMBER, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Email", SqlDbType.VarChar, oUserInfoViewModel.EMAIL, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_CivilID", SqlDbType.VarChar, oUserInfoViewModel.CIVIL_ID, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Address", SqlDbType.VarChar, oUserInfoViewModel.ADDRESS, 300, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_AreaId", SqlDbType.Int, oUserInfoViewModel.AREA_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_WilayatId", SqlDbType.Int, oUserInfoViewModel.WILAYAT_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_VillageId", SqlDbType.Int, oUserInfoViewModel.VILLAGE_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_CreatedBy", SqlDbType.Int, oUserInfoViewModel.CREATED_BY, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_UserID", SqlDbType.Int, ParameterDirection.Output));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("InsertUser", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[14].Value.ToString());
                if (oResponse.OperationResult == enumOperationResult.Success)
                {
                    //Inserted UserID
                    oResponse.ResponseID = arrParameters[13].Value.ToString();
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

        #region Method :: Response :: oUpdateProfileInformation
        /// <summary>
        /// Update profile information
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        public Response oUpdateProfileInformation(UserInfoViewModel oUserInfoViewModel)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, oUserInfoViewModel.ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_FullName", SqlDbType.NVarChar, oUserInfoViewModel.FULL_NAME, 100, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PhoneNumber", SqlDbType.VarChar, oUserInfoViewModel.PHONE_NUMBER, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Email", SqlDbType.VarChar, oUserInfoViewModel.EMAIL, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_CivilID", SqlDbType.VarChar, oUserInfoViewModel.CIVIL_ID, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Address", SqlDbType.NVarChar, oUserInfoViewModel.ADDRESS, 300, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_AreaId", SqlDbType.Int, oUserInfoViewModel.AREA_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_WilayatId", SqlDbType.Int, oUserInfoViewModel.WILAYAT_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_VillageId", SqlDbType.Int, oUserInfoViewModel.VILLAGE_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketSubmissionIntervalDays", SqlDbType.Int, oUserInfoViewModel.TICKET_SUBMISSION_INTERVAL_DAYS, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_IsTicketSubmissionRestricted", SqlDbType.Int, oUserInfoViewModel.IS_TICKET_SUBMISSION_RESTRICTED, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ModifiedBy", SqlDbType.Int, oUserInfoViewModel.MODIFIED_BY, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("UpdateProfileInformation", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[12].Value.ToString());
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

        #region Method :: Response :: oUpdateUserPassowrd
        /// <summary>
        /// Update user password
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        public Response oUpdateUserPassowrd(int nUserID, string sPassword, int nModifiedBy)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nUserID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Password", SqlDbType.VarChar, sPassword, 50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ModifiedBy", SqlDbType.Int, nModifiedBy, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("UpdateUserPassword", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[3].Value.ToString());
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

        #region Method :: Response :: oUpdateUserStatus
        /// <summary>
        /// Update user status
        /// </summary>
        /// <param name="nUserID"></param>
        /// <param name="bIsActive"></param>
        /// <param name="bIsBlocked"></param>
        /// <param name="bIsOTPVerified"></param>
        /// <param name="sBlockedReason"></param>
        /// <param name="nModifiedBy"></param>
        /// <returns></returns>
        public Response oUpdateUserStatus(int nUserID, bool bIsActive, bool bIsBlocked, bool bIsOTPVerified, string sBlockedReason, int nModifiedBy)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nUserID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_IsActive", SqlDbType.Bit, bIsActive, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_IsBlocked", SqlDbType.Bit, bIsBlocked, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_IsOTPVerified", SqlDbType.Bit, bIsOTPVerified, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_BlockedReason", SqlDbType.VarChar, sBlockedReason, 1000, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ModifiedBy", SqlDbType.Int, nModifiedBy, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("UpdateUserStatus", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[6].Value.ToString());
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

        #region Method :: List<UserInfoViewModel> :: IlGetAllApplications
        /// <summary>
        ///  Get all members
        /// </summary>
        /// <param name="nSearchByMemberID"></param>
        /// <param name="sSearchByMemberName"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public List<UserInfoViewModel> IlGetAllMembers(int nSearchByMemberID, string sSearchByMemberName, int nPageNumber, int nRowspPage)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_MemberId", SqlDbType.Int, nSearchByMemberID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_MemberName", SqlDbType.VarChar, sSearchByMemberName, 200, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, nPageNumber, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, nRowspPage, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<UserInfoViewModel> lstUsers = this.ExecuteStoredProcedureList<UserInfoViewModel>("GetAllMembers", arrParameters.ToArray());
            return lstUsers;
            #endregion
        }
        #endregion


        #endregion
    }
}
