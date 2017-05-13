
/*********************************************************************************************/
/* Class Name       : HelperExtentions.cs                                                   */
/* Designed BY      : Arshad Ashraf                                                         */
/* Created BY       : Arshad Ashraf                                                         */
/* Creation Date    : 09.10.2016 10:56 AM                                                   */
/* Description      :                                                                       */
/*********************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Mvc;

namespace Takamul.Portal.App_Code
{
    public static class HelperExtension
    {
        #region Method :: string :: sMakeMenuActive
        public static string sMakeMenuActive(this UrlHelper urlHelper, string action, string controller, string area = "")
        {
            string result = "active";
            string requestContextRoute;
            string passedInRoute;

            // Get the route values from the request           
            var sb = new StringBuilder().Append(urlHelper.RequestContext.RouteData.DataTokens["area"]);
            sb.Append("/");
            sb.Append(urlHelper.RequestContext.RouteData.Values["controller"].ToString());
            sb.Append("/");
            sb.Append(urlHelper.RequestContext.RouteData.Values["action"].ToString());
            requestContextRoute = sb.ToString();

            if (action.Equals(string.Empty) && controller.Equals(string.Empty))
            {
                string requestRouteArea = urlHelper.RequestContext.RouteData.DataTokens["area"] != null ? urlHelper.RequestContext.RouteData.DataTokens["area"].ToString() : "";
                if (requestRouteArea.Equals(area, StringComparison.OrdinalIgnoreCase))
                {
                    return result;
                }
            }

            if (string.IsNullOrWhiteSpace(area))
            {
                passedInRoute = "/" + controller + "/" + action;
            }
            else
            {
                passedInRoute = area + "/" + controller + "/" + action;
            }

            //  Are the 2 routes the same?
            if (!requestContextRoute.Equals(passedInRoute, StringComparison.OrdinalIgnoreCase))
            {
                result = null;
            }

            return result;
        }
        #endregion
    }
}