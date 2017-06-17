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
using Infrastructure.Core;
using System;

namespace Takamul.Services
{
    public class CommonServices : EntityService<Lookup>, ICommonServices
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;

        #endregion

        #region Properties

        #endregion

        #region :: Constructor ::
        public CommonServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<MemberInfoViewModel> :: oGetMemberInfo
        /// <summary>
        /// Get member info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nLaguageID"></param>
        /// <returns>List of News</returns>
        public List<MemberInfoViewModel> oGetMemberInfo(int nApplicationID,int nLaguageID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLaguageID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<MemberInfoViewModel> lstMemberInfo = this.ExecuteStoredProcedureList<MemberInfoViewModel>("GetMemberInfo", arrParameters.ToArray());
            return lstMemberInfo;
            #endregion
        }
        #endregion

        #region Method :: AreaInfo :: oGetAllAreas
        /// <summary>
        /// Get all areas
        /// </summary>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        public List<AreaInfoViewModel> oGetAllAreas(int nLanguageID)
        {

            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLanguageID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<AreaInfoViewModel> lstAreaDetails = this.ExecuteStoredProcedureList<AreaInfoViewModel>("GetAllAreas", arrParameters.ToArray());
            return lstAreaDetails;

            #endregion

        }
        #endregion

        #region Method :: WilayatInfoViewModel :: oGetAllWilayats
        /// <summary>
        ///   Get all wilayat
        /// </summary>
        /// <param name="sAreaCode"></param>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        public List<WilayatInfoViewModel> oGetAllWilayats(string sAreaCode, int nLanguageID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_AreaCode", SqlDbType.VarChar, sAreaCode, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLanguageID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<WilayatInfoViewModel> lstWilayatDetails = this.ExecuteStoredProcedureList<WilayatInfoViewModel>("GetAllWilayats", arrParameters.ToArray());
            return lstWilayatDetails;

            #endregion

        }
        #endregion

        #region Method :: VillageInfoViewModel :: oGetAllVillages
        /// <summary>
        /// Get all villages
        /// </summary>
        /// <param name="sAreaCode"></param>
        /// <param name="sWilayatCode"></param>
        /// <param name="nLanguageID"></param>
        /// <returns></returns>
        public List<VillageInfoViewModel> oGetAllVillages(string sAreaCode,string sWilayatCode, int nLanguageID)
        {

            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_AreaCode", SqlDbType.VarChar, sAreaCode, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_WilayatCode", SqlDbType.VarChar, sWilayatCode, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LanguageId", SqlDbType.Int, nLanguageID, ParameterDirection.Input));

            #endregion

            #region ":Get Sp Result:"
            List<VillageInfoViewModel> lstVillage = this.ExecuteStoredProcedureList<VillageInfoViewModel>("GetAllVillages", arrParameters.ToArray());
            return lstVillage;

            #endregion

        }
        #endregion


        #endregion
    }
}
