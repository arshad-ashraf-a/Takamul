/*************************************************************************************************/
/* Class Name           : INewsServices.cs                                                       */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : News service                                                           */
/*************************************************************************************************/

using Data.Core;
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

        #region Method :: IPagedList<NewsViewModel> :: IlGetAllNews
        /// <summary>
        /// Get all News
        /// </summary>
        /// <param name="sSearchByNewsName"></param>
        /// <param name="nApplicationID"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        IPagedList<NewsViewModel> IlGetAllNews(int nApplicationID,
            string sSearchByNewsName, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder);

        #endregion

        #region Method :: NewsViewModel :: oGetNewsDetails
        /// <summary>
        /// Get news details by news id
        /// </summary>
        /// <param name="nNewsID"></param>
        /// <returns>List of News</returns>
        NewsViewModel oGetNewsDetails(int nNewsID);
        #endregion

        #region Method :: Response :: InsertNews
        /// <summary>
        ///  Insert news
        /// </summary>
        /// <param name="oNewsViewModel"></param>
        /// <returns>Response</returns>
        Response oInsertNews(NewsViewModel oNewsViewModel);
        #endregion

        #region Method :: Response :: DeleteFiles
        /// <summary>
        ///  Delete files
        /// </summary>
        /// <param name="oFilesViewModel"></param>
        /// <returns>Response</returns>
        NEWS oDeleteFile(string oGuid);
        #endregion

        

        #region Method :: Response :: UpdateNews
        /// <summary>
        ///  Update news
        /// </summary>
        /// <param name="oNewsViewModel"></param>
        /// <returns>Response</returns>
        Response oUpdateNews(NewsViewModel oNewsViewModel, FileDetail newsFile=null);
        #endregion

        #region Method :: Response :: DeleteNews
        /// <summary>
        /// Delete news
        /// </summary>
        /// <param name="nNewsID"></param>
        /// <returns></returns>
        Response oDeleteNews(int nNewsID);
        #endregion
    }
}
