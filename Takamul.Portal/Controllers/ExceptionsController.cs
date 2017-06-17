using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Portal.Resources.Common;

namespace LDC.eServices.Portal.Controllers
{
    public class ExceptionsController : BaseController
    {
        public ActionResult Error()
        {
            this.PageTitle = CommonResx.ErrorPage;
            this.TitleHead = CommonResx.ErrorPage;
            return View();
        }
    }
}