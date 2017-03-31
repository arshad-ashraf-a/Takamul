using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using Takamul.Portal.App_Start;

namespace Takamul.API
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            AutofacConfig.RegisterComponents();
            config.EnableCors();
            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                 name: "DefaultApi",
                 routeTemplate: "api/{controller}/{action}/{id}",
                 defaults: new { id = RouteParameter.Optional }
             );

            var json = config.Formatters.JsonFormatter;
            json.SerializerSettings.Formatting = Newtonsoft.Json.Formatting.Indented;

            GlobalConfiguration.Configuration.MessageHandlers.Add(new CorsHandler());

        }
    }
}
