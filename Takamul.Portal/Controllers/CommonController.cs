using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class CommonController : BaseController
    {
        #region ::  State ::
        #region Private Members
        private ICommonServices oICommonServices;
        private ILookupServices oILookupServices;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// UsersController Constructor 
        /// </summary>
        /// <param name="oICommonServicesInitializer"></param>
        public CommonController(
                                ICommonServices oICommonServicesInitializer,
                                ILookupServices oILookupServicesInitializer
            )
        {
            this.oICommonServices = oICommonServicesInitializer;
            this.oILookupServices = oILookupServicesInitializer;
        }
        #endregion

        #region :: Behaviour ::


        #endregion

        #region ::  Methods ::

        #region Method :: JsonResult :: JGetAllTicketStatus
        /// <summary>
        /// Get all ticket status
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllTicketStatus()
        {
            var lstTicketStatus = this.oILookupServices.lGetAllTicketStatus();
            return Json(lstTicketStatus, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #endregion
    }
}