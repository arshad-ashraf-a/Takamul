/*************************************************************************************************/
/* Class Name           : IAuthenticationService.cs                                               */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : authentication services                                                */
/*************************************************************************************************/

using System.Collections.Generic;
using Takamul.Models;
using Takamul.Models.ViewModel;

namespace Takamul.Services
{
    public interface IAuthenticationService
    {
        #region Method :: UserInfoViewModel :: oGetUserDetails
        /// <summary>
        ///  Get user details
        /// </summary>
        /// <param name="nUserID"></param>
        /// <param name="sPhoneNumber"></param>
        /// <returns></returns>
        UserInfoViewModel oGetUserDetails(int nUserID, string sPhoneNumber);
        #endregion

        #region Method :: Response :: oInsertMobileUser
        /// <summary>
        /// Insert Mobile User
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        Response oInsertMobileUser(UserInfoViewModel oUserInfoViewModel);
        #endregion

        #region Method :: Response :: oValidateOTPNumber
        /// <summary>
        ///  Validate user otp number
        /// </summary>
        /// <param name="sPhoneNumber"></param>
        /// <param name="nOTPNumber"></param>
        /// <returns></returns>
        Response oValidateOTPNumber(string sPhoneNumber, int nOTPNumber, string sDeviceID);
        #endregion

        #region Method :: Response :: oResendOTPNumber
        /// <summary>
        ///  Resend user otp number
        /// </summary>
        /// <param name="sPhoneNumber"></param>
        /// <param name="nOTPNumber"></param>
        /// <returns></returns>
        Response oResendOTPNumber(string sPhoneNumber, int nOTPNumber, int nUserId);
        #endregion

        #region Method :: Response :: oUpdateOTPStatus
        /// <summary>
        /// Update the OTP Status
        /// </summary>
        /// <param name="nUserId"></param>
        /// <returns></returns>
        Response oUpdateOTPStatus(int nUserId);

        #endregion

    }
}
