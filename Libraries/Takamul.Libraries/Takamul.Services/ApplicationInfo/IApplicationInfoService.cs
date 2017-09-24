/*************************************************************************************************/
/* Class Name           : IApplicationInfoService.cs                                             */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 22.09.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : used for application informations                                      */
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
    public interface IApplicationInfoService
    {
        #region Method :: List<ApplicationInfoViewModel> :: lGetAllApplicationInfo
        /// <summary>
        /// Get all application info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        List<ApplicationInfoViewModel> lGetAllApplicationInfo(int nApplicationID);
        #endregion

        #region Method :: IPagedList<ApplicationInfoViewModel> :: IlGetAllApplicationInfo
        /// <summary>
        /// Get application info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        IPagedList<ApplicationInfoViewModel> IlGetAllApplicationInfo(int nApplicationID, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder);

        #endregion

        #region Method :: Response :: InsertApplicationInfo
        /// <summary>
        ///  Insert application info
        /// </summary>
        /// <param name="oApplicationInfoViewModel"></param>
        /// <returns>Response</returns>
        Response oInsertApplicationInfo(ApplicationInfoViewModel oApplicationInfoViewModel);

        #endregion

        #region Method :: Response :: UpdateApplicationInfo
        /// <summary>
        /// Update member info
        /// </summary>
        /// <param name="oApplicationInfoViewModel"></param>
        /// <returns>Response</returns>
        Response oUpdateApplicationInfo(ApplicationInfoViewModel oApplicationInfoViewModel);

        #endregion

        #region Method :: Response :: DeleteApplicationInfo
        /// <summary>
        /// Delete event
        /// </summary>
        /// <param name="nApplicationInoID"></param>
        /// <returns></returns>
        Response oDeleteApplicationInfo(int nApplicationInoID);

        #endregion
    }
}
