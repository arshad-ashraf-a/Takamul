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
        #region Method :: IPagedList<ApplicationViewModel> :: IlGetAllApplications
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
        IPagedList<ApplicationViewModel> IlGetAllApplications(int nSearchByAppliationID, string sSearchByApplicationName, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder);
        #endregion

        #region Method :: ApplicationViewModel :: oGetApplicationDetails
        /// <summary>
        ///  Get application details
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        ApplicationViewModel oGetApplicationDetails(int nApplicationID);
        #endregion
    }
}
