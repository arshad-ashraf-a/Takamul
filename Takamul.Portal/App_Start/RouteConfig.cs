using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Routing;
using System.Web.Mvc;

namespace Takamul.Portal.App_Start
{
    public static class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
         
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
            #region Home Page Route
            routes.MapRoute(
                   name: "Default",
                   url: "{controller}/{action}",
                   defaults: new { controller = "home", action = "Index", id = UrlParameter.Optional }
               );
            #endregion
        }
    }
}
