using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LDC.eServices.Portal.Controllers
{
    public class ExceptionsController : BaseController
    {
        public ActionResult Error()
        {
            this.PageTitle = "Error";
            this.TitleHead = "Error";
            return View();
        }
    }
}