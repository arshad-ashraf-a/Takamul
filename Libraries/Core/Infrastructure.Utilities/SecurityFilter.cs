using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;

namespace Infrastructure.Utilities
{
    public class SecurityFilter : AuthorizeAttribute
    {

        //public override void OnAuthorization(AuthorizationContext filterContext)
        //{
        //    base.OnAuthorization(filterContext);
        //    BaseController oBaseController = (BaseController)filterContext.Controller;

        //    if (!filterContext.HttpContext.User.Identity.IsAuthenticated || oBaseController.CurrentUser == null)
        //    {
        //        var ReturnUrl = filterContext.HttpContext.Request.Url;

        //        var Url = new UrlHelper(filterContext.RequestContext);
        //        var LoginUrl = Url.Action("Login", "Account", new { area = "", ReturnUrl = ReturnUrl });
        //        filterContext.Result = new RedirectResult(LoginUrl);
        //        return;
        //    }

        //    if (filterContext.Result is HttpUnauthorizedResult)
        //    {
        //        filterContext.Result = new RedirectResult("~/Account/AccessDenied");
        //        return;
        //    }

        //}

        private bool IsAccessAllowed(string Controller, string Action, IPrincipal User, string IP)
        {
            return false;
        }
    }
}
