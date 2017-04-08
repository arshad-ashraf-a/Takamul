using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Routing;
using System.Web.Mvc;

namespace Takamul.API
{
    public static class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                name: "Root",
                url: "",
                defaults: new { controller = "Help", action = "Index" }
                ).DataTokens["area"] = "HelpPage";
        }
    }
}
