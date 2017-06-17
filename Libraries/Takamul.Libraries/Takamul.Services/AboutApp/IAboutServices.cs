/*************************************************************************************************/
/* Class Name           : IAboutServices.cs                                                       */
/* Designed BY          : Samh Khalid                                                          */
/* Created BY           : Samh Khalid                                                          */
/* Creation Date        : 06-07-2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : About service                                                           */
/*************************************************************************************************/

using Data.Core;
using System.Collections.Generic;
using Takamul.Models;
using Takamul.Models.ViewModel;

namespace Takamul.Services
{
    public interface IAboutServices
    {
        #region Method :: AboutViewModel :: oGetAboutDetails
        /// <summary>
        /// Get about app details
        /// </summary>
        /// <param name="nLangID"></param>
        /// <returns>App Details</returns>
        AboutAppViewModel oGetAppDetails(int nLangID);
        #endregion
        #region Method :: AboutViewModel :: oGetHelpMenus
        /// <summary>
        /// Get about app details
        /// </summary>
        /// <param name="nLangID"></param>
        /// <returns>App Details</returns>
        AboutAppViewModel oGetHelpMenus(int nLangID);
        #endregion

    }
}
