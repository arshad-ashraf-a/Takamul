/*************************************************************************************************/
/* Class Name           : IMemberInfoService.cs                                                  */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 05.04.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : used for member informations                                           */
/*************************************************************************************************/

using Data.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Takamul.Models;
using Takamul.Models.ViewModel;

namespace Takamul.Services
{
    public interface IMemberInfoService
    {
        #region Method :: List<MemberInfoViewModel> :: lGetAllMemberInfo
        /// <summary>
        /// Get all member info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns>List of Events</returns>
        List<MemberInfoViewModel> lGetAllMemberInfo(int nApplicationID);
        
        #endregion

        #region Method :: IPagedList<MemberInfoViewModel> :: IlGetAllMemberInfo
        /// <summary>
        /// Get all events
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="sSearchByEventName"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        IPagedList<MemberInfoViewModel> IlGetAllMemberInfo(int nApplicationID, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder);
        
        #endregion

        #region Method :: Response :: InsertMemberInfo
        /// <summary>
        ///  Insert member info
        /// </summary>
        /// <param name="oMemberInfoViewModel"></param>
        /// <returns>Response</returns>
        Response oInsertMemberInfo(MemberInfoViewModel oMemberInfoViewModel);
        
        #endregion

        #region Method :: Response :: UpdateMemberInfo
        /// <summary>
        /// Update member info
        /// </summary>
        /// <param name="oMemberInfoViewModel"></param>
        /// <returns>Response</returns>
        Response oUpdateMemberInfo(MemberInfoViewModel oMemberInfoViewModel);
        
        #endregion

        #region Method :: Response :: DeleteMemberInfo
        /// <summary>
        /// Delete event
        /// </summary>
        /// <param name="nMemberInoID"></param>
        /// <returns></returns>
        Response oDeleteMemberInfo(int nMemberInoID);
        
        #endregion
    }
}
