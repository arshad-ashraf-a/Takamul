/*************************************************************************************************/
/* Class Name           : IUserServices.cs                                                     */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : User services                                                        */
/*************************************************************************************************/

using System.Collections.Generic;
using Takamul.Models;
using Takamul.Models.ViewModel;

namespace Takamul.Services
{
    public interface IUserServices
    {
        #region Method :: List<UserInfoViewModel> :: lGetApplicationUsers
        /// <summary>
        ///  Get list of application users
        /// </summary>
        /// <returns></returns>
        List<UserInfoViewModel> lGetApplicationUsers(int nApplicationID, int nUserTypeID, string sUserSeach, int nPageNumber, int nRowspPage);

        #endregion

        #region Method :: UserInfoViewModel :: oGetUserDetails
        /// <summary>
        ///  Get user details
        /// </summary>
        /// <returns></returns>
        UserInfoViewModel oGetUserDetails(int nUserID);
        #endregion

        #region Method :: Response :: oInsertUser
        /// <summary>
        /// Insert Mobile User
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        Response oInsertUser(UserInfoViewModel oUserInfoViewModel);
        #endregion

        #region Method :: Response :: oUpdateProfileInformation
        /// <summary>
        /// Update profile information
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        Response oUpdateProfileInformation(UserInfoViewModel oUserInfoViewModel);
        #endregion

        #region Method :: Response :: oUpdateUserPassowrd
        /// <summary>
        /// Update user password
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        Response oUpdateUserPassowrd(int nUserID, string sPassword, int nModifiedBy);
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
        Response oUpdateUserStatus(int nUserID, bool bIsActive, bool bIsBlocked, bool bIsOTPVerified, string sBlockedReason, int nModifiedBy);
        #endregion

        #region Method :: List<UserInfoViewModel> :: lGetAllMembers
        /// <summary>
        ///  Get list of member users
        /// </summary>
        /// <returns></returns>
        List<UserInfoViewModel> lGetAllMembers(string sUserSeach, int nPageNumber, int nRowspPage);
        #endregion

    }
}
