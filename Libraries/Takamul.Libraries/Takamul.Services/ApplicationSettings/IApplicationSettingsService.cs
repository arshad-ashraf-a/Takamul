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
    public interface IApplicationSettingsService
    {
        #region Method :: List<ApplicationSettingsViewModel> :: IlGetAllApplicationSettings
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        List<ApplicationSettingsViewModel> IlGetAllApplicationSettings(int nApplicationID, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder);
        #endregion

        #region Method :: Response :: UpdateApplicationSettings
        /// <summary>
        /// Update member settings
        /// </summary>
        /// <param name="oApplicationSettingsViewModel"></param>
        /// <returns>Response</returns>
        Response oUpdateApplicationSettings(ApplicationSettingsViewModel oApplicationSettingsViewModel);
        #endregion
    }
}

