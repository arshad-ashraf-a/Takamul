using Infrastructure.Core;
using Infrastructure.Utilities;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Xml.Linq;
using Takamul.Models;
using Takamul.Models.ViewModel;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class TicketsController : BaseController
    {
        #region ::  State ::
        #region Private Members
        private ITicketServices oITicketServices;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// TicketsController Constructor 
        /// </summary>
        /// <param name="oITicketServicesInitializer"></param>
        public TicketsController(ITicketServices oITicketServicesInitializer)
        {
            this.oITicketServices = oITicketServicesInitializer;
        }
        #endregion

        #region :: Behaviour ::

        #region View :: TicketsList
        public ActionResult TicketsList()
        {
            this.PageTitle = "Tickets List";
            this.TitleHead = "Tickets List";

            return View();
        }
        #endregion

        #region View :: TicketsList
        public ActionResult TicketDetails(int nTicketID)
        {
            this.PageTitle = "Ticket Details";
            this.TitleHead = "Ticket Details";

            return View();
        }
        #endregion

        #endregion

        #region ::  Methods ::

        #region JsonResult :: Bind Grid All Events
        /// <summary>
        /// Bind all application tickets
        /// </summary>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public JsonResult JBindAllTickets(int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var lstEvents = this.oITicketServices.IlGetAllTickets(CurrentApplicationID, nPage, nRows);
            return Json(lstEvents, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #endregion



    }
}