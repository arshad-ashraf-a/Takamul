using Infrastructure.Core;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Security;

namespace Infrastructure.Utilities
{
    public class DomainController : BaseController
    {
        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            int nCurrentAppID = -99;
            if (BaseController.CurrentUser != null)
            {

                if (BaseController.CurrentUser.UserType == enumUserType.Admin)
                {
                    nCurrentAppID = this.CurrentApplicationID;
                }
                else
                {
                    this.CurrentApplicationID = BaseController.CurrentUser.CurrentApplicationID;
                    nCurrentAppID = BaseController.CurrentUser.CurrentApplicationID;
                }
            }
            if (nCurrentAppID == -99)
            {
                filterContext.Result = RedirectToAction("Login", "Account", new { area = "" });
            }
        }

        //protected override void OnActionExecuting(ActionExecutingContext filterContext)
        //{
        //    HttpContext context = System.Web.HttpContext.Current;
        //    if (context.Session != null)
        //    {
        //        if (context.Session["CurrentUser"] == null)
        //        {
        //            //string sessionCookie = context.Request.Headers["Cookie"];
        //            string sessionCookie = context.Request.Headers[FormsAuthentication.FormsCookieName];

        //            if ((sessionCookie != null) && (sessionCookie.IndexOf("ASP.NET_SessionId") >= 0))
        //            {
        //                FormsAuthentication.SignOut();
        //                string redirectTo = "~/Account/Login";
        //                if (!string.IsNullOrEmpty(context.Request.RawUrl))
        //                {
        //                    redirectTo = string.Format("~/Account/Login?ReturnUrl={0}", HttpUtility.UrlEncode(context.Request.RawUrl));
        //                    filterContext.Result = new RedirectResult(redirectTo);
        //                    return;
        //                }

        //            }
        //        }
        //    }

        //    base.OnActionExecuting(filterContext);
        //}




        protected override void Initialize(RequestContext requestContext)
        {
            base.Initialize(requestContext);
            System.Globalization.CultureInfo oCultureInfo = System.Globalization.CultureInfo.GetCultureInfo("en-GB");
            System.Threading.Thread.CurrentThread.CurrentCulture = oCultureInfo;
            System.Threading.Thread.CurrentThread.CurrentUICulture = oCultureInfo;

        }
    }
}