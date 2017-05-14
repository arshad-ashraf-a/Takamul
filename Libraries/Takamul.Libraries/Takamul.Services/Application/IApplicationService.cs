/*************************************************************************************************/
/* Class Name           : IApplicationService.cs                                               */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : application services                                                */
/*************************************************************************************************/

using Data.Core;
using System.Collections.Generic;
using Takamul.Models;
using Takamul.Models.ViewModel;

namespace Takamul.Services
{
    public interface IApplicationService
    {
        #region Method :: List<ApplicationViewModel> :: IlGetAllApplications
        /// <summary>
        ///  Get all applications
        /// </summary>
        /// <param name="nSearchByAppliationID"></param>
        /// <param name="sSearchByApplicationName"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        List<ApplicationViewModel> IlGetAllApplications(int nApplicationID, string sSearchByApplicationName, int nPageNumber, int nRowspPage);
        #endregion

        #region Method :: ApplicationViewModel :: oGetApplicationDetails
        /// <summary>
        ///  Get application details
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        ApplicationViewModel oGetApplicationDetails(int nApplicationID);
        #endregion

        #region Method :: ApplicationViewModel :: oGetApplicationStatistics
        /// <summary>
        ///  Get application details
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        ApplicationViewModel oGetApplicationStatistics(int nApplicationID);
        #endregion
    }
}
