﻿using Infrastructure.Core;
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
    public class UsersController : BaseController
    {
        #region ::  State ::
        #region Private Members
        private IUserServices oIUserServicesService;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// UsersController Constructor 
        /// </summary>
        /// <param name="oIUserServicesInitializer"></param>
        public UsersController(IUserServices oIUserServicesInitializer)
        {
            this.oIUserServicesService = oIUserServicesInitializer;
        }
        #endregion

        #region :: Behaviour ::

        #region View :: UsersList
        public ActionResult UsersList()
        {
            this.PageTitle = "Users List";
            this.TitleHead = "Users List";

            return View();
        }
        #endregion

        #endregion

        #region ::  Methods ::

        #region Method :: JsonResult :: JGetApplicationUsers
        /// <summary>
        /// Get application users
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetApplicationUsers()
        {
            var lstUsers = this.oIUserServicesService.lGetApplicationUsers(this.CurrentApplicationID);
            return Json(lstUsers, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #endregion
    }
}