using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LDC.eServices.Portal.Controllers
{
    public class AccessDeniedController : BaseController
    {
        public ActionResult Index()
        {
            this.PageTitle = "Access Denied";
            this.TitleHead = "Access Denied";
            return View();
        }
    }
}