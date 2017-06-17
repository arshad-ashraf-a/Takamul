/*************************************************************************************************/
/* Class Name           : AboutServices.cs                                                        */
/* Designed BY          : Samh Khalid                                                          */
/* Created BY           : Samh Khalid                                                          */
/* Creation Date        : 06-07-2017 02:0 PM                                                     */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage About App operations                                                 */
/*************************************************************************************************/

using System.Collections.Generic;
using System.Data.Entity;
using Data.Core;
using Takamul.Models;
using Takamul.Models.ViewModel;
using System.Data.Common;
using System.Data;
using System;
using System.Linq;
using Infrastructure.Core;
using System.IO;
using System.Net;
using System.Web;

namespace Takamul.Services
{
    public class AboutServices : EntityService<Lookup>, IAboutServices
    {

        #region Members
        private readonly TakamulConnection oTakamulConnection;
        private IDbSet<ABOUT_APP> oAboutDBSet;// Represent DB Set Table For EVENTS
        #endregion

        #region Properties
        #region Property :: EventsDBSet
        /// <summary>
        ///  Get NEWS DBSet Object
        /// </summary>
        private IDbSet<ABOUT_APP> NewsDBSet
        {
            get
            {
                if (oAboutDBSet == null)
                {
                    oAboutDBSet = oTakamulConnection.Set<ABOUT_APP>();
                }
                return oAboutDBSet;
            }
        }
        #endregion
        #endregion

        #region :: Constructor ::
        public AboutServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods :: 

        #region Method :: AboutAppViewModel :: oGetAboutAppDetails
        /// <summary>
        /// 
        /// </summary>
        /// <param name="nLanguageID"></param>
        /// <returns> </returns>
        public AboutAppViewModel oGetAppDetails(int nLanguageID)
        {
            AboutAppViewModel oAboutViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("nLanguageID", SqlDbType.Int, nLanguageID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<AboutAppViewModel> lstApp = this.ExecuteStoredProcedureList<AboutAppViewModel>("GetAboutAppDetails", arrParameters.ToArray());
            if (lstApp.Count > 0)
            {
                return lstApp[0];
            }
            return oAboutViewModel;
            #endregion
        }
        #endregion

        #region Method :: AboutAppViewModel :: oGetHelpMenus
        /// <summary>
        /// 
        /// </summary>
        /// <param name="nLanguageID"></param>
        /// <returns> </returns>
        public AboutAppViewModel oGetHelpMenus(int nLanguageID)
        {
            AboutAppViewModel oAboutViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("nLanguageID", SqlDbType.Int, nLanguageID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<AboutAppViewModel> lstApp = this.ExecuteStoredProcedureList<AboutAppViewModel>("GetAboutAppLinks", arrParameters.ToArray());
            if (lstApp.Count > 0)
            {
                return lstApp[0];
            }
            return oAboutViewModel;
            #endregion
        }
        #endregion

        #endregion


    }
}

 