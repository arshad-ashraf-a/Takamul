/*************************************************************************************************/
/* Class Name           : ITicketServices.cs                                                       */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:03 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Ticket service                                                           */
/*************************************************************************************************/

using System.Collections.Generic;
using Takamul.Models;
using Takamul.Models.ViewModel;

namespace Takamul.Services
{
    public interface ITicketServices
    {
        #region Method :: List<TicketViewModel> :: IlGetAllActiveTickets
        /// <summary>
        /// Get all active tickets
        /// </summary>
        /// <param name="nApplicationID"></param>
        /// <param name="nTicketID"></param>
        /// <param name="nUserID"></param>
        /// <returns></returns>
        List<TicketViewModel> IlGetAllActiveTickets(int nApplicationID, int nTicketID, int nUserID);
        #endregion

        #region Method :: TicketViewModel :: oGetTicketDetails
        /// <summary>
        /// Get ticket details by ticket id
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        TicketViewModel oGetTicketDetails(int nTicketID);
        #endregion

        #region Method :: List<TicketChatViewModel> :: IlGetTicketChats
        /// <summary>
        /// Get all ticket chats
        /// </summary>
        /// <param name="nTicketID"></param>
        /// <returns></returns>
        List<TicketChatViewModel> IlGetTicketChats(int nTicketID);
        #endregion

        #region Method :: Response :: oInsertTicket
        /// <summary>
        /// Insert Ticket
        /// </summary>
        /// <param name="oTicketViewModel"></param>
        /// <param name="nParticipantUserID"></param>
        /// <returns></returns>
        Response oInsertTicket(TicketViewModel oTicketViewModel, int nParticipantUserID);
        #endregion

        #region Method :: Response :: oInsertTicketChat
        /// <summary>
        /// Insert Ticket Chat
        /// </summary>
        /// <param name="oTicketChatViewModel"></param>
        /// <returns></returns>
        Response oInsertTicketChat(TicketChatViewModel oTicketChatViewModel);
        #endregion
    }
}
