/*************************************************************************************************/
/* Class Name           : NewsServices.cs                                                        */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 02:0 PM                                                     */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage news operations                                                 */
/*************************************************************************************************/

using System.Collections.Generic;
using System.Data.Entity;
using Data.Core;
using Takamul.Models;
using Takamul.Models.ViewModel;
using System.Data.Common;
using System.Data;

namespace Takamul.Services
{
    public class NewsServices : EntityService<Lookup>, INewsServices
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;

        #endregion

        #region Properties

        #endregion

        #region :: Constructor ::
        public NewsServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<NewsViewModel> :: IlGetAllActiveNews
        /// <summary>
        /// Get all active news
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns>List of News</returns>
        public List<NewsViewModel> IlGetAllActiveNews(int nApplicationID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_NewsId", SqlDbType.Int, -99, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<NewsViewModel> lstNews = this.ExecuteStoredProcedureList<NewsViewModel>("GetAllActiveNews", arrParameters.ToArray());
            return lstNews;
            #endregion
        }
        #endregion 

        #region Method :: NewsViewModel :: oGetNewsDetails
        /// <summary>
        /// Get news details by news id
        /// </summary>
        /// <param name="nNewsID"></param>
        /// <returns>List of News</returns>
        public NewsViewModel oGetNewsDetails(int nNewsID)
        {
            NewsViewModel oNewsViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_NewsId", SqlDbType.Int, nNewsID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<NewsViewModel> lstNews = this.ExecuteStoredProcedureList<NewsViewModel>("GetAllActiveNews", arrParameters.ToArray());
            if (lstNews.Count > 0)
            {
                return lstNews[0];
            }
            return oNewsViewModel;
            #endregion
        }
        #endregion 

        #endregion
    }
}
