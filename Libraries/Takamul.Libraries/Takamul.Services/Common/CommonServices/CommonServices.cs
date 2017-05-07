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

        #region Method :: MemberInfoViewModel :: oGetMemberInfo
        /// <summary>
        /// Get member info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns>List of News</returns>
        public MemberInfoViewModel oGetMemberInfo(int nApplicationID)
        {
            MemberInfoViewModel oNewsViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<MemberInfoViewModel> lstMemberInfo = this.ExecuteStoredProcedureList<MemberInfoViewModel>("GetAllActiveNews", arrParameters.ToArray());
            if (lstMemberInfo.Count > 0)
            {
                return lstMemberInfo[0];
            }
            return oNewsViewModel;
            #endregion
        }
        #endregion 

        #region Method :: Response :: oInsertMobileUser
        /// <summary>
        /// Insert Mobile User
        /// </summary>
        /// <param name="oUserInfoViewModel"></param>
        /// <returns></returns>
        public Response oInsertMobileUser(UserInfoViewModel oUserInfoViewModel)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, oUserInfoViewModel.APPLICATION_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserTypeId", SqlDbType.Int,oUserInfoViewModel.USER_TYPE_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_FullName", SqlDbType.VarChar, oUserInfoViewModel.FULL_NAME,100, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PhoneNumber", SqlDbType.VarChar, oUserInfoViewModel.PHONE_NUMBER,50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Email", SqlDbType.VarChar, oUserInfoViewModel.EMAIL,50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_CivilID", SqlDbType.VarChar, oUserInfoViewModel.CIVIL_ID,50, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Address", SqlDbType.VarChar, oUserInfoViewModel.ADDRESS,300, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_AreaId", SqlDbType.Int, oUserInfoViewModel.AREA_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_WilayatId", SqlDbType.Int, oUserInfoViewModel.WILAYAT_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_VillageId", SqlDbType.Int, oUserInfoViewModel.VILLAGE_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("Inc_InsertPreliminary", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[23].Value.ToString());
            }
            catch (Exception Ex)
            {
                oResponse.OperationResult = enumOperationResult.Faild;
                //TODO : Log Error Message
                oResponse.OperationResultMessage = Ex.Message.ToString();
            }

            return oResponse;
            #endregion
        }

        #endregion

        #region Method :: AreaInfo :: oGetAllAreas
        /// <summary>
        ///  Get all areas
        /// </summary>
        /// <returns></returns>
        public List<AreaInfoViewModel> oGetAllAreas()
        {

            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("AreaCode", SqlDbType.VarChar, null, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<AreaInfoViewModel> lstAreaDetails = this.ExecuteStoredProcedureList<AreaInfoViewModel>("GetAllAreas", arrParameters.ToArray());
            return lstAreaDetails;

            #endregion

        }
        #endregion

        #region Method :: WilayatInfoViewModel :: oGetAllWilayats
        /// <summary>
        ///  Get all wilayat
        /// </summary>
        /// <returns></returns>
        public List<WilayatInfoViewModel> oGetAllWilayats(string sAreaCode)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("AreaCode", SqlDbType.VarChar, sAreaCode, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<WilayatInfoViewModel> lstWilayatDetails = this.ExecuteStoredProcedureList<WilayatInfoViewModel>("GetAllWilayats", arrParameters.ToArray());
            return lstWilayatDetails;

            #endregion

        }
        #endregion

        #region Method :: VillageInfoViewModel :: oGetAllVillages
        /// <summary>
        ///  Get all villages
        /// </summary>
        /// <param name="nUserID"></param>
        /// <returns></returns>
        public List<VillageInfoViewModel> oGetAllVillages(string sWilayatCode)
        {

            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("WilayatCode", SqlDbType.NVarChar, sWilayatCode, ParameterDirection.Input));
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
