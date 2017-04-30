using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LDC.eServices.Portal.Controllers
{
    public class ApplicationsController : BaseController
    {
        // GET: Home
        public ActionResult ApplicationsList()
        {
            this.PageTitle = "Applications List";
            this.TitleHead = "Applications List";

            return View();
        }
    }
}