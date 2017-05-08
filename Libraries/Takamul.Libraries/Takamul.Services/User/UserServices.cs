/*************************************************************************************************/
/* Class Name           : UserServices.cs                                                        */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 02:0 PM                                                     */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage user operations                                                 */
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
    public class UserServices : EntityService<Lookup>, IUserServices
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;

        #endregion

        #region Properties

        #endregion

        #region :: Constructor ::
        public UserServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<UserInfoViewModel> :: lGetApplicationUsers
        /// <summary>
        ///  Get list of application users
        /// </summary>
        /// <returns></returns>
        public List<UserInfoViewModel> lGetApplicationUsers(int nApplicationID, int nPageNumber, int nRowspPage)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, nPageNumber, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, nRowspPage, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<UserInfoViewModel> lstUsers = this.ExecuteStoredProcedureList<UserInfoViewModel>("GetApplicationUsers", arrParameters.ToArray());
            return lstUsers;

            #endregion

        }
        #endregion

        #region Method :: UserInfoViewModel :: oGetUserDetails
        /// <summary>
        ///  Get user details
        /// </summary>
        /// <returns></returns>
        public UserInfoViewModel oGetUserDetails(int nUserID)
        {
            UserInfoViewModel oUserInfoViewModel = new UserInfoViewModel();
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nUserID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, 1, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, 1, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<UserInfoViewModel> lstUsers = this.ExecuteStoredProcedureList<UserInfoViewModel>("GetApplicationUsers", arrParameters.ToArray());
            if (lstUsers.Count == 1)
            {
                oUserInfoViewModel = lstUsers[0];
                enumUserType oEnmUserType = (enumUserType)Enum.Parse(typeof(enumUserType), oUserInfoViewModel.USER_TYPE_ID.ToString(), true);
                oUserInfoViewModel.UserType = oEnmUserType;
            }
            return oUserInfoViewModel;

            #endregion

        }
        #endregion
        #endregion
    }
}
