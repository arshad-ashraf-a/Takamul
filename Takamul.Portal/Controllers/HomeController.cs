using Data.Core;
using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Models.ViewModel;
using Takamul.Portal.Helpers;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class HomeController : BaseController
    {
        // GET: Home
        public ActionResult Index()
        {
            this.PageTitle = CommonResx.Home;
            this.TitleHead = CommonResx.Home;

            var userId = CurrentUser.nUserID;
            return View();
        }

        
    }
}