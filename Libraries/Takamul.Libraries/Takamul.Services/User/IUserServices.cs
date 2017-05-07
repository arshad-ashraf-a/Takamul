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
        List<UserInfoViewModel> lGetApplicationUsers(int nApplicationID);
        
        #endregion

    }
}
