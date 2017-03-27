/************************************************************************************************************************/
/* Class Name    : BundleConfig.cs                                                                                      */
/* Designed BY   : Arshad Ashraf                                                                                        */
/* Created BY    : Arshad Ashraf                                                                                        */
/* Creation Date : 01.01.2017 08:08 PM                                                                                  */
/* Description   : BundleConfig will register all JS and Css minified files for manpower e services soltuions           */
/************************************************************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.UI;

namespace Takamul.Portal.App_Start
{
    public class BundleConfig
    {
        // For more information on Bundling, visit http://go.microsoft.com/fwlink/?LinkID=303951
        public static void RegisterBundles(BundleCollection bundles)
        {

            #region Core CSS Files

            bundles.Add(new StyleBundle("~/bundles/CoreStyles").Include(
                      "~/assets/css/bootstrap.css",
                      "~/assets/css/core.css",
                      "~/assets/css/components.css",
                      "~/assets/css/colors.css",
                      "~/assets/css/custom.css",
                      //"~/assets/css/jquery-ui.min.css",
                      "~/assets/css/icons/icomoon/styles.css",
                      "~/assets/css/icons/fontawesome/styles.min.css",
                      "~/assets/js/plugins/loaders/fakeLoader.min.css"
                      ));

            #endregion

            #region Core Js Files

            bundles.Add(new ScriptBundle("~/bundles/CoreScripts").Include(
                      "~/assets/js/core/libraries/jquery.min.js",
                      "~/assets/js/core/libraries/bootstrap.min.js",
                      "~/assets/js/plugins/loaders/fakeLoader.js",
                      "~/Scripts/knockout-3.4.1.js"
                      ));

            #endregion

            #region Core CSS Utilities

            bundles.Add(new StyleBundle("~/bundles/CoreStyleUtilities").Include(
                     "~/assets/js/plugins/notification/css/Notification.css",
                     "~/assets/js/plugins/notification/css/Notification_en.css"

                      ));

            #endregion

            #region Core Js Utilities

            bundles.Add(new ScriptBundle("~/bundles/CoreScriptUtilities").Include(
                      "~/assets/js/core/libraries/jquery-ui.min.js",
                      "~/assets/js/plugins/forms/select2.min.js",
                      "~/assets/js/plugins/forms/validate.min.js",
                      "~/assets/js/plugins/forms/uniform.min.js",
                      "~/assets/js/plugins/forms/moment.min.js",
                      "~/assets/js/core/app.js",
                     "~/assets/js/plugins/notification/js/Notification.js",
                     "~/assets/js/core/CommonLib.js"
                      ));

            #endregion
        }
    }
}