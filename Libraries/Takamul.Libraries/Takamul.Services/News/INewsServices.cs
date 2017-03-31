/*************************************************************************************************/
/* Class Name           : INewsServices.cs                                                       */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : News service                                                           */
/*************************************************************************************************/

using System.Collections.Generic;
using Takamul.Models;
using Takamul.Models.ViewModel;

namespace Takamul.Services
{
    public interface INewsServices
    {
        #region Method :: List<NewsViewModel> :: IlGetAllActiveNews
        /// <summary>
        /// Get all active news
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns>List of News</returns>
        List<NewsViewModel> IlGetAllActiveNews(int nApplicationID);
        #endregion

        #region Method :: NewsViewModel :: oGetNewsDetails
        /// <summary>
        /// Get news details by news id
        /// </summary>
        /// <param name="nNewsID"></param>
        /// <returns>List of News</returns>
        NewsViewModel oGetNewsDetails(int nNewsID);
        #endregion
    }
}
