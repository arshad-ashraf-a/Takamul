/*************************************************************************************************/
/* Class Name           : ICommonServices.cs                                                     */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Common services                                                        */
/*************************************************************************************************/

using System.Collections.Generic;
using Takamul.Models;
using Takamul.Models.ViewModel;

namespace Takamul.Services
{
    public interface ICommonServices
    {
        #region Method :: MemberInfoViewModel :: oGetMemberInfo
        /// <summary>
        /// Get member info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns>List of News</returns>
        MemberInfoViewModel oGetMemberInfo(int nApplicationID);
        #endregion

        #region Method :: Response :: oInsertMobileUser
        /// <summary>
        /// Insert Mobile User
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        Response oInsertMobileUser(UserInfoViewModel oUserInfoViewModel);
        #endregion


        #region Method :: Response :: oGetAllAreas
        /// <summary>
        /// Get area list
        /// </summary>
        /// <returns></returns>
        List<AreaInfoViewModel> oGetAllAreas();
        #endregion

        #region Method :: Response :: oGetAllWilayats
        /// <summary>
        /// Get Wilayats list
        /// </summary>
        /// <param name="oAreaCode"></param>
        /// <returns></returns>
        List<WilayatInfoViewModel> oGetAllWilayats(string AreaCode);
        #endregion

        #region Method :: Response :: oGetAllVillages
        /// <summary>
        /// Get Villages
        /// </summary>
        /// <param name="oWilayatCode"></param>
        /// <returns></returns>
        List<VillageInfoViewModel> oGetAllVillages(string WilayatCode);
        #endregion

    }
}
