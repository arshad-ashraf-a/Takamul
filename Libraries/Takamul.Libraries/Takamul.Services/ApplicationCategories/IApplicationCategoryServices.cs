/*************************************************************************************************/
/* Class Name           : IApplicationCategoryServices.cs                                        */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 05.04.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : used for application category                                           */
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
    public interface IApplicationCategoryServices
    {
        #region Method :: List<ApplicationCategoryViewModel> :: lGetAllApplicationCategories
        /// <summary>
        /// Get all application category
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nLanguageID"></param>
        /// <returns>List of Events</returns>
        List<ApplicationCategoryViewModel> lGetAllApplicationCategories(int nApplicationID, int nLanguageID);

        #endregion

        #region Method :: IPagedList<ApplicationCategoryViewModel> :: IlGetAllApplicationCategories
        /// <summary>
        /// Get all application category
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="sSearchByEventName"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        IPagedList<ApplicationCategoryViewModel> IlGetAllApplicationCategories(int nApplicationID, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder, int nLanguageID);

        #endregion

        #region Method :: Response :: InsertApplicationCategory
        /// <summary>
        ///  Insert application category
        /// </summary>
        /// <param name="oApplicationCategoryViewModel"></param>
        /// <returns>Response</returns>
        Response oInsertApplicationCategory(ApplicationCategoryViewModel oApplicationCategoryViewModel);

        #endregion

        #region Method :: Response :: UpdateApplicationCategory
        /// <summary>
        /// Update application category
        /// </summary>
        /// <param name="oApplicationCategoryViewModel"></param>
        /// <returns>Response</returns>
        Response oUpdateApplicationCategory(ApplicationCategoryViewModel oApplicationCategoryViewModel);

        #endregion

        #region Method :: Response :: DeleteApplicationCategory
        /// <summary>
        /// Delete application category
        /// </summary>
        /// <param name="nApplicationCategoryID"></param>
        /// <returns></returns>
        Response oDeleteApplicationCategory(int nApplicationCategoryID);
        
        #endregion
    }
}
