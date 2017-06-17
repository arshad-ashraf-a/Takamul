using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Portal.Resources.Common;

namespace LDC.eServices.Portal.Controllers
{
    public class AccessDeniedController : BaseController
    {
        public ActionResult Index()
        {
            this.PageTitle = CommonResx.AccessDenied;
            this.TitleHead = CommonResx.AccessDenied;
            return View();
        }
    }
}