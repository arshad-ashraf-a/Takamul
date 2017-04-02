/*************************************************************************************************/
/* Class Name           : TakamulTicketController.cs                                               */
/* Designed BY          : Arshad Ashraf                                                          */
/* Created BY           : Arshad Ashraf                                                          */
/* Creation Date        : 31.03.2017 03:01 PM                                                    */
/* Modified BY          : -                                                                      */
/* Last Modified Date   : -                                                                      */
/* Description          : Manage ticket operations                                                 */
/*************************************************************************************************/

using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Http.Cors;
using Takamul.Models.ApiViewModel;
using Takamul.Models.ViewModel;
using Takamul.Services;

namespace Takamul.API.Controllers
{
    public class TakamulTicketController : ApiController
    {
        #region ::   State   ::
        #region Private Members
        private readonly ITicketServices oITicketServices;
        #endregion
        #endregion

        #region :: Constructor ::
        public TakamulTicketController(
                                        ITicketServices ITicketServicesInitializer
                                    )
        {
            oITicketServices = ITicketServicesInitializer;
        }
        #endregion

        #region :: Methods::

        #region Method :: HttpResponseMessage :: GetAllTickets
        // GET: api/TakamulTicket/GetAllTickets
        [HttpGet]
        public HttpResponseMessage GetAllTickets(int nApplicationID,int nUserID)
        {
            List<TakamulTicket> lstTakamulTicket = null;
            var lstTickets = this.oITicketServices.IlGetAllActiveTickets(nApplicationID, -99, nUserID);
            if (lstTickets.Count() > 0)
            {
                lstTakamulTicket = new List<TakamulTicket>();
                foreach (var ticket in lstTickets)
                {
                    TakamulTicket oTakamulTicket = new TakamulTicket()
                    {
                        TicketID = ticket.ID,
                        ApplicationID = ticket.APPLICATION_ID,
                        Base64DefaultImage = ticket.DEFAULT_IMAGE,
                        TicketName = ticket.TICKET_NAME,
                        TicketDescription = ticket.TICKET_DESCRIPTION,
                        TicketStatusID = ticket.TICKET_STATUS_ID,
                        TicketStatusRemark = ticket.TICKET_STATUS_REMARK,
                        TicketStatusName = ticket.TICKET_STATUS_NAME
                    };
                    lstTakamulTicket.Add(oTakamulTicket);
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK, lstTakamulTicket);
        }
        #endregion 

        #region Method :: HttpResponseMessage :: GetTicketDetails
        // GET: api/TakamulTicket/GetTicketDetails
        [HttpGet]
        public HttpResponseMessage GetTicketDetails(int nTicketID)
        {
            TakamulTicket oTakamulTicket = null;
            TicketViewModel oTicketViewModel = this.oITicketServices.oGetTicketDetails(nTicketID);
            if (oTicketViewModel != null)
            {
                 oTakamulTicket = new TakamulTicket()
                {
                     TicketID = oTicketViewModel.ID,
                     ApplicationID = oTicketViewModel.APPLICATION_ID,
                     Base64DefaultImage = oTicketViewModel.DEFAULT_IMAGE,
                     TicketName = oTicketViewModel.TICKET_NAME,
                     TicketDescription = oTicketViewModel.TICKET_DESCRIPTION,
                     TicketStatusID = oTicketViewModel.TICKET_STATUS_ID,
                     TicketStatusRemark = oTicketViewModel.TICKET_STATUS_REMARK,
                     TicketStatusName = oTicketViewModel.TICKET_STATUS_NAME
                };
            }
            return Request.CreateResponse(HttpStatusCode.OK, oTakamulTicket);
        }
        #endregion 

        #endregion
    }
}
