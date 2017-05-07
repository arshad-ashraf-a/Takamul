/*************************************************************************************************/
/* Class Name           : MemberInfoService.cs                                                   */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 05.04.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Member Infor service                                                   */
/*************************************************************************************************/

using System.Collections.Generic;
using System.Data.Entity;
using Data.Core;
using Takamul.Models;
using Takamul.Models.ViewModel;
using System.Data.Common;
using System.Data;
using System.Linq;
using System;
using Infrastructure.Core;

namespace Takamul.Services
{
    public class MemberInfoService : EntityService<Lookup>, IMemberInfoService
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;
        private IDbSet<MEMBER_INFO> oMemberInfoDBSet;// Represent DB Set Table For MEMBER_INFO

        #endregion

        #region Properties
        #region Property :: MemberInfoDBSet
        /// <summary>
        ///  Get MEMBER_INFO DBSet Object
        /// </summary>
        private IDbSet<MEMBER_INFO> MemberInfoDBSet
        {
            get
            {
                if (oMemberInfoDBSet == null)
                {
                    oMemberInfoDBSet = oTakamulConnection.Set<MEMBER_INFO>();
                }
                return oMemberInfoDBSet;
            }
        }
        #endregion
        #endregion

        #region :: Constructor ::
        public MemberInfoService(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<MemberInfoViewModel> :: lGetAllMemberInfo
        /// <summary>
        /// Get all member info
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns>List of Events</returns>
        public List<MemberInfoViewModel> lGetAllMemberInfo(int nApplicationID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<MemberInfoViewModel> lstMemberInfo = this.ExecuteStoredProcedureList<MemberInfoViewModel>("GetMemberInfo", arrParameters.ToArray());
            return lstMemberInfo;
            #endregion
        }
        #endregion

        #region Method :: IPagedList<MemberInfoViewModel> :: IlGetAllMemberInfo
        /// <summary>
        /// Get all events
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="sSearchByEventName"></param>
        /// <param name="nPageIndex"></param>
        /// <param name="nPageSize"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public IPagedList<MemberInfoViewModel> IlGetAllMemberInfo(int nApplicationID, int nPageIndex, int nPageSize, string sColumnName, string sColumnOrder)
        {
            #region Build Left Join Query And Keep All Query Source As IQueryable To Avoid Any Immediate Execution DataBase
            var lstMemberInfo = (from c in this.MemberInfoDBSet
                             where c.APPLICATION_ID == (int)nApplicationID
                             orderby c.ID descending
                             select new
                             {
                                 ID = c.ID,
                                 APPLICATION_ID = c.APPLICATION_ID,
                                 MEMBER_INFO_TITLE = c.MEMBER_INFO_TITLE,
                                 MEMBER_INFO_DESCRIPTION = c.MEMBER_INFO_DESCRIPTION
                             });
            #endregion

            #region Execute The Query And Return Page Result
            var oTempMemberInfoPagedResult = new PagedList<dynamic>(lstMemberInfo, nPageIndex - 1, nPageSize, sColumnName, sColumnOrder);
            int nTotal = oTempMemberInfoPagedResult.TotalCount;
            PagedList<MemberInfoViewModel> plstApplicaiton = new PagedList<MemberInfoViewModel>(oTempMemberInfoPagedResult.Select(oMemberInfoPagedResult => new MemberInfoViewModel
            {
                ID = oMemberInfoPagedResult.ID,
                APPLICATION_ID = oMemberInfoPagedResult.APPLICATION_ID,
                MEMBER_INFO_TITLE = oMemberInfoPagedResult.MEMBER_INFO_TITLE,
                MEMBER_INFO_DESCRIPTION = oMemberInfoPagedResult.MEMBER_INFO_DESCRIPTION

            }), oTempMemberInfoPagedResult.PageIndex, oTempMemberInfoPagedResult.PageSize, oTempMemberInfoPagedResult.TotalCount);

            if (plstApplicaiton.Count > 0)
            {
                plstApplicaiton[0].TotalCount = nTotal;
            }

            return plstApplicaiton;
            #endregion
        }
        #endregion

        #region Method :: Response :: InsertMemberInfo
        /// <summary>
        ///  Insert member info
        /// </summary>
        /// <param name="oMemberInfoViewModel"></param>
        /// <returns>Response</returns>
        public Response oInsertMemberInfo(MemberInfoViewModel oMemberInfoViewModel)
        {
            #region ": Insert :"

            Response oResponse = new Response();

            try
            {
                if (oMemberInfoViewModel != null)
                {
                    var lstMemberInfo = (from c in this.MemberInfoDBSet
                                         where c.APPLICATION_ID == oMemberInfoViewModel.APPLICATION_ID
                                         orderby c.ID descending
                                         select new
                                         {
                                             ID = c.ID,
                                             APPLICATION_ID = c.APPLICATION_ID,
                                             MEMBER_INFO_TITLE = c.MEMBER_INFO_TITLE,
                                             MEMBER_INFO_DESCRIPTION = c.MEMBER_INFO_DESCRIPTION
                                         });
                    if (lstMemberInfo.Count() >= 3 )
                    {
                        oResponse.OperationResult = enumOperationResult.RelatedRecordFaild;
                        return oResponse;
                    }

                    MEMBER_INFO oMEMBER_INFO = new MEMBER_INFO()
                    {
                        APPLICATION_ID = oMemberInfoViewModel.APPLICATION_ID,
                        MEMBER_INFO_TITLE = oMemberInfoViewModel.MEMBER_INFO_TITLE,
                        MEMBER_INFO_DESCRIPTION = oMemberInfoViewModel.MEMBER_INFO_DESCRIPTION,
                        CREATED_BY = oMemberInfoViewModel.CREATED_BY,
                        CREATED_DATE = DateTime.Now
                    };
                    this.oTakamulConnection.MEMBER_INFO.Add(oMEMBER_INFO);
                    if (this.intCommit() > 0)
                    {
                        oResponse.OperationResult = enumOperationResult.Success;
                    }
                    else
                    {
                        oResponse.OperationResult = enumOperationResult.Faild;
                    }

                }
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

        #region Method :: Response :: UpdateMemberInfo
        /// <summary>
        /// Update member info
        /// </summary>
        /// <param name="oMemberInfoViewModel"></param>
        /// <returns>Response</returns>
        public Response oUpdateMemberInfo(MemberInfoViewModel oMemberInfoViewModel)
        {
            Response oResponse = new Response();

            #region Try Block

            try
            {
                // Start try

                #region Check oEventViewModel Value
                MEMBER_INFO oMEMBER_INFO = new MEMBER_INFO();
                oMEMBER_INFO = this.oTakamulConnection.MEMBER_INFO.Find(oMemberInfoViewModel.ID);

                if (oMEMBER_INFO == null)
                {
                    throw new ArgumentNullException("oMEMBER_INFO Entity Is Null");
                }

                #endregion

                #region Update Default EVENTS

                oMEMBER_INFO.APPLICATION_ID = oMemberInfoViewModel.APPLICATION_ID;
                oMEMBER_INFO.MEMBER_INFO_TITLE = oMemberInfoViewModel.MEMBER_INFO_TITLE;
                oMEMBER_INFO.MEMBER_INFO_DESCRIPTION = oMemberInfoViewModel.MEMBER_INFO_DESCRIPTION;
                oMEMBER_INFO.MODIFIED_BY = oMemberInfoViewModel.CREATED_BY;
                oMEMBER_INFO.MODIFIED_DATE = DateTime.Now;
                this.MemberInfoDBSet.Attach(oMEMBER_INFO);
                this.oTakamulConnection.Entry(oMEMBER_INFO).State = EntityState.Modified;

                if (this.intCommit() > 0)
                {
                    oResponse.OperationResult = enumOperationResult.Success;
                }
                else
                {
                    oResponse.OperationResult = enumOperationResult.Faild;
                }
                #endregion

            }// End try 
            #endregion

            #region Catch Block
            catch (Exception Ex)
            {// Start Catch
                oResponse.OperationResult = enumOperationResult.Faild;
                //TODO : Log Error Message
                oResponse.OperationResultMessage = Ex.Message.ToString();
            }//End Catch 
            #endregion

            return oResponse;
        }
        #endregion

        #region Method :: Response :: DeleteMemberInfo
        /// <summary>
        /// Delete event
        /// </summary>
        /// <param name="nMemberInoID"></param>
        /// <returns></returns>
        public Response oDeleteMemberInfo(int nMemberInoID)
        {
            #region ": Delete :"

            Response oResponse = new Response();
            try
            {
                this.oTakamulConnection.MEMBER_INFO.RemoveRange(this.oTakamulConnection.MEMBER_INFO.Where(x => x.ID == nMemberInoID));
                if (this.intCommit() > 0)
                {
                    oResponse.OperationResult = enumOperationResult.Success;
                }
                else
                {
                    oResponse.OperationResult = enumOperationResult.Faild;
                }
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

        #endregion

    }
}
