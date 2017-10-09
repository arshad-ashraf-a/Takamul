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
        #region Method :: List<MemberInfoViewModel> :: oGetMemberInfo
        /// <summary>
        /// Get member info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nLaguageID"></param>
        /// <returns>List of News</returns>
        List<MemberInfoViewModel> oGetMemberInfo(int nApplicationID, int nLaguageID);
        #endregion

        #region Method :: Response :: oGetAllAreas
        /// <summary>
        ///  Get area list
        /// </summary>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        List<AreaInfoViewModel> oGetAllAreas(int nLanguageID);
        #endregion

        #region Method :: Response :: oGetAllWilayats
        /// <summary>
        ///  Get Wilayats list
        /// </summary>
        /// <param name="AreaCode"></param>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        List<WilayatInfoViewModel> oGetAllWilayats(string AreaCode, int nLanguageID);
        #endregion

        #region Method :: Response :: oGetAllVillages
        /// <summary>
        ///  Get Villages
        /// </summary>
        /// <param name="sAreaCode"></param>
        /// <param name="sWilayatCode"></param>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        List<VillageInfoViewModel> oGetAllVillages(string sAreaCode, string sWilayatCode, int nLanguageID);
        #endregion

        #region Method :: Response :: oInsertNotificationLog
        /// <summary>
        ///  Insert Notification Log
        /// </summary>
        /// <param name="oNotificationLogViewModel"></param>
        /// <returns></returns>
        Response oInsertNotificationLog(NotificationLogViewModel oNotificationLogViewModel);
        #endregion

        #region Method :: List<MemberInfoViewModel> :: oGetPushNotificationLogs
        /// <summary>
        /// Get push notification logs
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns>List of Logs</returns>
        List<NotificationLogViewModel> oGetPushNotificationLogs(int nApplicationID, int nPageNumber, int nRowspPage);
        #endregion


    }
}
