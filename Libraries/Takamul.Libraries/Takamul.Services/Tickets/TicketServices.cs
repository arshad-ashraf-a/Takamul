﻿/*************************************************************************************************/
/* Class Name           : TicketServices.cs                                                        */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 02:0 PM                                                     */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage ticket operations                                                 */
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
    public class TicketServices : EntityService<Lookup>, ITicketServices
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;

        #endregion

        #region Properties

        #endregion

        #region :: Constructor ::
        public TicketServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region :: Methods ::

        #region Method :: List<TicketViewModel> :: IlGetAllActiveTickets
        /// <summary>
        /// Get all active tickets
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nTicketID"></param>
        /// <param name="nUserID"></param>
        /// <returns></returns>
        public List<TicketViewModel> IlGetAllActiveTickets(int nApplicationID, int nUserID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nUserID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketViewModel> lstTickets = this.ExecuteStoredProcedureList<TicketViewModel>("GetAllActiveTickets", arrParameters.ToArray());
            return lstTickets;
            #endregion
        }
        #endregion

        #region Method :: List<TicketViewModel> :: IlGetAllTickets
        /// <summary>
        /// Get all tickets
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        public List<TicketViewModel> IlGetAllTickets(int nApplicationID, int nParticipantID, int nTicketStatusID, int nTicketCategoryID, string sTicketName, int nPageNumber, int nRowspPage)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nParticipantID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketStatusId", SqlDbType.Int, nTicketStatusID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketCategoryId", SqlDbType.Int, nTicketCategoryID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketName", SqlDbType.VarChar, sTicketName, 300, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, nPageNumber, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, nRowspPage, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketViewModel> lstTickets = this.ExecuteStoredProcedureList<TicketViewModel>("GetAllTickets", arrParameters.ToArray());
            return lstTickets;
            #endregion

        }
        #endregion

        #region Method :: List<TicketViewModel> :: lGetTop5TicketsByStatus
        /// <summary>
        /// Get top 5 ticket by status
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <returns></returns>
        public List<TicketViewModel> lGetTop5TicketsByStatus(int nApplicationID, int nTicketStatusID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, nApplicationID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketStatusId", SqlDbType.Int, nTicketStatusID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketViewModel> lstTickets = this.ExecuteStoredProcedureList<TicketViewModel>("GetTop5TicketsByStatus", arrParameters.ToArray());
            return lstTickets;
            #endregion

        }
        #endregion

        #region Method :: TicketViewModel :: oGetTicketDetails
        /// <summary>
        /// Get ticket details by ticket id
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        public TicketViewModel oGetTicketDetails(int nTicketID)
        {
            TicketViewModel oTicketViewModel = null;
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketStatusId", SqlDbType.Int, -99, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketCode", SqlDbType.VarChar, string.Empty, 10, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketName", SqlDbType.VarChar, string.Empty, 300, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, 1, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, 1, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketViewModel> lstTickets = this.ExecuteStoredProcedureList<TicketViewModel>("GetAllTickets", arrParameters.ToArray());
            if (lstTickets.Count > 0)
            {
                return lstTickets[0];
            }
            return oTicketViewModel;
            #endregion
        }
        #endregion

        #region Method :: List<TicketChatViewModel> :: IlGetTicketChats
        /// <summary>
        /// Get all ticket chats
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        public List<TicketChatViewModel> IlGetTicketChats(int nTicketID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketChatViewModel> lstTickets = this.ExecuteStoredProcedureList<TicketChatViewModel>("GetTicketChats", arrParameters.ToArray());
            return lstTickets;
            #endregion
        }
        #endregion

        #region Method :: List<TicketChatViewModel> :: IlGetMoreTicketChats
        /// <summary>
        /// Get more ticket chats
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <param name="nLastTicketChatID"></param>
        /// <returns></returns>
        public List<TicketChatViewModel> IlGetMoreTicketChats(int nTicketID, int nLastTicketChatID)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_LastTicketChatId", SqlDbType.Int, nLastTicketChatID, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketChatViewModel> lstTickets = this.ExecuteStoredProcedureList<TicketChatViewModel>("GetMoreTicketChats", arrParameters.ToArray());
            return lstTickets;
            #endregion
        }
        #endregion

        #region Method :: List<TicketParticipantViewModel> :: IlGetTicketParticipants
        /// <summary>
        /// Get ticket participants
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        public List<TicketParticipantViewModel> IlGetTicketParticipants(int nTicketID, int nPageNumber, int nRowspPage)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_PageNumber", SqlDbType.Int, nPageNumber, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_RowspPage", SqlDbType.Int, nRowspPage, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketParticipantViewModel> lstTicketParticipants = this.ExecuteStoredProcedureList<TicketParticipantViewModel>("GetTicketParticipants", arrParameters.ToArray());
            return lstTicketParticipants;
            #endregion

        }
        #endregion

        #region Method :: Response :: oInsertTicket
        /// <summary>
        /// Insert Ticket
        /// </summary>
        /// <param name="oTicketViewModel"></param>
        /// <param name="nParticipantUserID"></param>
        /// <returns></returns>
        public Response oInsertTicket(TicketViewModel oTicketViewModel, int nParticipantUserID)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ApplicationId", SqlDbType.Int, oTicketViewModel.APPLICATION_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_UserId", SqlDbType.Int, nParticipantUserID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketName", SqlDbType.NVarChar, oTicketViewModel.TICKET_NAME, 300, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketDesciption", SqlDbType.NVarChar, oTicketViewModel.TICKET_DESCRIPTION, 5000, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_DefaultImagePath", SqlDbType.VarChar, oTicketViewModel.DEFAULT_IMAGE, 500, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketCreatedPlatForm", SqlDbType.Int, oTicketViewModel.TICKET_CREATED_PLATFORM, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_CreatedBy", SqlDbType.Int, oTicketViewModel.CREATED_BY, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_DeviceID", SqlDbType.VarChar, 50, ParameterDirection.Output));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_TicketID", SqlDbType.Int, ParameterDirection.Output));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("InsertTicket", arrParameters.ToArray());
                oResponse.nOperationResult = Convert.ToInt32(arrParameters[9].Value.ToString());
                if (oResponse.nOperationResult == 1)
                {
                    //Inserted Ticket ID
                    oResponse.ResponseID = arrParameters[8].Value.ToString();

                    //User Device ID
                    oResponse.ResponseCode = arrParameters[7].Value.ToString();

                    oResponse.OperationResult = enumOperationResult.Success;
                }
                //oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[6].Value.ToString());
                //if (oResponse.OperationResult == enumOperationResult.Success)
                //{
                //    // Inserted Ticket ID
                //    oResponse.ResponseID = arrParameters[5].Value.ToString();
                //}
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

        #region Method :: Response :: oInsertTicketChat
        /// <summary>
        /// Insert Ticket Chat
        /// </summary>
        /// <param name="oTicketChatViewModel"></param>
        /// <returns></returns>
        public Response oInsertTicketChat(TicketChatViewModel oTicketChatViewModel)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, oTicketChatViewModel.TICKET_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_Ticket_Participant_Id", SqlDbType.Int, oTicketChatViewModel.TICKET_PARTICIPANT_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ReplyMessage", SqlDbType.NVarChar, oTicketChatViewModel.REPLY_MESSAGE, 4000, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ReplyFilePath", SqlDbType.VarChar, oTicketChatViewModel.REPLY_FILE_PATH, 500, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketChatTypeId", SqlDbType.Int, oTicketChatViewModel.TICKET_CHAT_TYPE_ID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_DeviceID", SqlDbType.VarChar, ParameterDirection.Output, 4000));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_ChatID", SqlDbType.Int, ParameterDirection.Output));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));


                this.ExecuteStoredProcedureCommand("InsertTicketChat", arrParameters.ToArray());
                oResponse.nOperationResult = Convert.ToInt32(arrParameters[7].Value.ToString());


                if (oResponse.nOperationResult == 1)
                {
                    //User Device ID
                    oResponse.ResponseCode = arrParameters[5].Value.ToString();
                    oResponse.OperationResult = enumOperationResult.Success;
                    oResponse.ResponseID = arrParameters[6].Value.ToString();
                }

                //oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[5].Value.ToString());
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

        #region Method :: Response :: oUpdateTicket
        /// <summary>
        /// Udpate Ticket
        /// </summary>
        /// <param name="oTicketChatViewModel"></param>
        /// <returns></returns>
        public Response oUpdateTicket(int nTicketID, int nTicketStatusID, bool nIsActive, string sRejectReason, int nDoneBy)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketStatusID", SqlDbType.Int, nTicketStatusID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_IsActive", SqlDbType.Bit, nIsActive, int.MaxValue, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_StatusRemark", SqlDbType.VarChar, sRejectReason, 1000, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ModifiedBy", SqlDbType.Int, nDoneBy, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("UpdateTicket", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[5].Value.ToString());
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

        #region Method :: Response :: oResolveTicket
        /// <summary>
        /// Udpate Ticket
        /// </summary>
        /// <param name="oTicketChatViewModel"></param>
        /// <returns></returns>
        public Response oResolveTicket(int nTicketID, int nTicketStatusID, int nDoneBy)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketStatusID", SqlDbType.Int, nTicketStatusID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ModifiedBy", SqlDbType.Int, nDoneBy, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("ResolveTicket", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[3].Value.ToString());
                oResponse.OperationResultMessage = "Ticket has been resolved";
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

        #region Method :: Response :: oDeleteTicket
        /// <summary>
        /// Delete a user ticket
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <param name="nDoneBy"></param>
        /// <returns></returns>
        public Response oDeleteTicket(int nTicketID, int nDoneBy)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ModifiedBy", SqlDbType.Int, nDoneBy, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("DeleteTicket", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[2].Value.ToString());
                oResponse.OperationResultMessage = "Ticket has been deleted";
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

        #region Method :: Response :: oInsertTicketParticipant
        /// <summary>
        /// Insert Ticket Participant
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <param name="nParticipantUserID"></param>
        /// <param name="nCreatedBy"></param>
        /// <returns></returns>
        public Response oInsertTicketParticipant(int nTicketID, int nParticipantUserID, int nCreatedBy)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ParticipantID", SqlDbType.Int, nParticipantUserID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_CreatedBy", SqlDbType.Int, nCreatedBy, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("InsertTicketParticipant", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[3].Value.ToString());

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

        #region Method :: Response :: oDeleteTicketParticipant
        /// <summary>
        /// Delete a ticket participant
        /// </summary>
        /// <param name="nTicketParticipantID"></param>
        /// <returns></returns>
        public Response oDeleteTicketParticipant(int nTicketParticipantID, int nTicketID)
        {
            #region ": Delete Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketParticipantId", SqlDbType.Int, nTicketParticipantID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("DeleteTicketParticipant", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[2].Value.ToString());
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

        #region Method :: List<TicketParticipantViewModel> :: IlGetTicketParticipants
        /// <summary>
        /// Get ticket mobile user participants
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <param name="nExcludedMobileUser"></param>
        /// <returns></returns>
        public List<TicketMobileUserParticipantViewModel> IlGetTicketMobileUserParticipants(int nTicketID, int nExcludedMobileUser = -99)
        {
            #region ":DBParamters:"
            List<DbParameter> arrParameters = new List<DbParameter>();
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
            arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ExcludedUserId", SqlDbType.Int, nExcludedMobileUser, ParameterDirection.Input));
            #endregion

            #region ":Get Sp Result:"
            List<TicketMobileUserParticipantViewModel> lstTicketParticipants = this.ExecuteStoredProcedureList<TicketMobileUserParticipantViewModel>("GetTicketMObileUserParticipants", arrParameters.ToArray());
            return lstTicketParticipants;
            #endregion

        }
        #endregion

        #region Method :: Response :: oAssignTicketCategory
        /// <summary>
        /// Assign Ticket Category
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <param name="nCategoryID"></param>
        /// <param name="nModifiedBy"></param>
        /// <returns></returns>
        public Response oAssignTicketCategory(int nTicketID, int nCategoryID, int nModifiedBy)
        {
            #region ": Insert Sp Result:"

            Response oResponse = new Response();

            try
            {
                List<DbParameter> arrParameters = new List<DbParameter>();

                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_TicketId", SqlDbType.Int, nTicketID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_CategoryID", SqlDbType.Int, nCategoryID, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pin_ModifiedBy", SqlDbType.Int, nModifiedBy, ParameterDirection.Input));
                arrParameters.Add(CustomDbParameter.BuildParameter("Pout_Error", SqlDbType.Int, ParameterDirection.Output));

                this.ExecuteStoredProcedureCommand("AssignTicketCategory", arrParameters.ToArray());
                oResponse.OperationResult = (enumOperationResult)Enum.Parse(typeof(enumOperationResult), arrParameters[3].Value.ToString());

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
