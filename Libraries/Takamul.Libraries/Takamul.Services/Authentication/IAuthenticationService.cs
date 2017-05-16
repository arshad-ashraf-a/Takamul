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
        /// <returns></returns>
        UserInfoViewModel oGetUserDetails(int nUserID);
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
        /// <param name="nUserID"></param>
        /// <param name="nOTPNumber"></param>
        /// <returns></returns>
        Response oValidateOTPNumber(int nUserID, int nOTPNumber);
        #endregion

        #region Method :: Response :: oResendOTPNumber
        /// <summary>
        ///  Resend user otp number
        /// </summary>
        /// <param name="nUserID"></param>
        /// <param name="nOTPNumber"></param>
        /// <returns></returns>
        Response oResendOTPNumber(int nUserID,int nOTPNumber);
        #endregion

        #region Method :: Response :: oOTPforAppReinstall
        /// <summary>
        ///  Resend user otp number
        /// </summary>
        /// <param name="nUserID"></param>
        /// <param name="nOTPNumber"></param>
        /// <returns></returns>
        Response oOTPforAppReinstall(string nMob, int nOTPNumber);
        #endregion


    }
}
