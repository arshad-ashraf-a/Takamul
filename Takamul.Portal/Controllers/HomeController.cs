using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LDC.eServices.Portal.Controllers
{
    public class HomeController : BaseController
    {
        // GET: Home
        public ActionResult Index()
        {
            this.PageTitle = "Home";
            this.TitleHead = "Home";

            var userId = CurrentUser.nUserID;
            return View();
        }

        
    }
}