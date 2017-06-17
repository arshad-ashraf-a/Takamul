using Data.Core;
using Infrastructure.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web;

namespace Infrastructure.Utilities
{
    public class BaseController : Controller
    {
        #region Properties

        #region Property :: User :: CurrentUser
        public static User CurrentUser
        {
            get
            {
                if (System.Web.HttpContext.Current.User.Identity.IsAuthenticated)
                {
                    // The user is authenticated. Return the user from the forms auth ticket.
                    return ((PrincipalManager)(System.Web.HttpContext.Current.User)).User;
                }
                else if (System.Web.HttpContext.Current.Items.Contains("User"))
                {
                    // The user is not authenticated, but has successfully logged in.
                    return (User)System.Web.HttpContext.Current.Items["User"];
                }
                else
                {
                    return null;
                }
            }
        }
        #endregion

        #region Property :: OperationResult
        /// <summary>
        /// Gets or sets the operation result.
        /// </summary>
        /// <value>The operation result.</value>
        public enumOperationResult OperationResult
        {
            get;
            set;
        }
        #endregion

        #region Property :: OperationResultMessages
        /// <summary>
        /// Gets or sets the operation result messages.
        /// </summary>
        /// <value>The operation result messages.</value>
        public string OperationResultMessages
        {
            get;
            set;
        }
        #endregion

        #region Property :: TitleHead
        public string TitleHead
        {
            get
            {
                string result;
                if (base.ViewData["TitleHead"] != null && !string.IsNullOrEmpty(base.ViewData["TitleHead"].ToString()))
                {
                    result = base.ViewData["TitleHead"].ToString();
                }
                else
                {
                    result = "";
                }
                return result;
            }
            set
            {
                base.ViewData["TitleHead"] = value;
            }
        }
        #endregion

        #region Property :: TitleSub
        public string TitleSub
        {
            get
            {
                string result;
                if (base.ViewData["TitleSub"] != null && !string.IsNullOrEmpty(base.ViewData["TitleSub"].ToString()))
                {
                    result = base.ViewData["TitleSub"].ToString();
                }
                else
                {
                    result = "";
                }
                return result;
            }
            set
            {
                base.ViewData["TitleSub"] = value;
            }
        }
        #endregion

        #region Property :: ParentNode
        public string ParentNode
        {
            get
            {
                string result;
                if (base.ViewData["ParentNode"] != null && !string.IsNullOrEmpty(base.ViewData["ParentNode"].ToString()))
                {
                    result = base.ViewData["ParentNode"].ToString();
                }
                else
                {
                    result = "";
                }
                return result;
            }
            set
            {
                base.ViewData["ParentNode"] = value;
            }
        }
        #endregion

        #region Property :: CurrentPage
        public string CurrentPage
        {
            get
            {
                string result;
                if (base.ViewData["CurrentPage"] != null && !string.IsNullOrEmpty(base.ViewData["CurrentPage"].ToString()))
                {
                    result = base.ViewData["CurrentPage"].ToString();
                }
                else
                {
                    result = "";
                }
                return result;
            }
            set
            {
                base.ViewData["CurrentPage"] = value;
            }
        }
        #endregion

        #region PageTitle
        public string PageTitle
        {
            get
            {
                string sPageTitle = string.Empty;
                if (CurrentUser != null && CurrentUser.CurrentLanguageID == (int)System.Convert.ToInt16(Languages.Arabic))
                {
                    sPageTitle = "";
                }
                else
                {
                    sPageTitle = "LDC eServices";
                }
                if (base.ViewData["PageTitle"] != null)
                {
                    sPageTitle = base.ViewData["PageTitle"].ToString();
                }
                return sPageTitle;
            }
            set
            {
                base.ViewData["PageTitle"] = value;
            }
        }
        #endregion

        #region Property :: PublicMenu
        public string PublicMenu
        {
            get
            {
                string result;
                if (base.ViewData["PublicMenu"] != null)
                {
                    result = base.ViewData["PublicMenu"].ToString();
                }
                else
                {
                    result = string.Empty;
                }
                return result;
            }
            set
            {
                base.ViewData["PublicMenu"] = value;
            }
        }
        #endregion

        #region Property :: CurrentApplicationID
        public int CurrentApplicationID
        {
            get
            {
                int nCurrentAppID;
                if (base.Session["ApplicationID"] != null)
                {
                    nCurrentAppID = Convert.ToInt32(base.Session["ApplicationID"].ToString());
                }
                else
                {
                    nCurrentAppID = -99;
                }
                return nCurrentAppID;
            }
            set
            {
                base.Session["ApplicationID"] = value;
            }
        }
        #endregion

        #region Property :: CurrentApplicationName
        public string CurrentApplicationName
        {
            get
            {
                string sCurrentAppName = string.Empty;
                if (base.Session["ApplicationName"] != null)
                {
                    sCurrentAppName = base.Session["ApplicationName"].ToString();
                }
                return sCurrentAppName;
            }
            set
            {
                base.Session["ApplicationName"] = value;
            }
        }
        #endregion

        #region Property :: CurrentApplicationLanguage
        public Languages CurrentApplicationLanguage
        {
            get
            {
                Languages oLanguage = Languages.English;

                if (base.Session["CurrentApplicationLanguage"] == null)
                {
                    var langCookie = Request.Cookies["lang"];
                    if (langCookie != null)
                    {
                        oLanguage = Request.Cookies["lang"].Value.ToString().Contains("ar") ? Languages.Arabic : Languages.English;
                    }
                    base.Session["CurrentApplicationLanguage"] = oLanguage;
                }

                if (base.Session["CurrentApplicationLanguage"] != null)
                {
                    oLanguage = (Languages)Enum.Parse(typeof(Languages), base.Session["CurrentApplicationLanguage"].ToString());
                }
                return oLanguage;
            }
            set
            {
                base.Session["CurrentApplicationLanguage"] = value;
            }
        }
        #endregion

        #endregion

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            if (CurrentUser == null)
            {
                filterContext.Result = RedirectToAction("Login", "Account", new { area = "" });
            }

        }


        protected override void OnException(ExceptionContext filterContext)
        {
            //filterContext.ExceptionHandled = true;

            //// Redirect on error:
            //filterContext.Result = RedirectToAction("Error", "Exceptions", new { area = "" });

        }

        #region Json Result :: SetLanguage
        [HttpPost]
        public JsonResult SetLanguage(int nLanguageID)
        {
            if (nLanguageID == 1)
            {
                this.CurrentApplicationLanguage = Data.Core.Languages.Arabic;
                var langCookie = new HttpCookie("lang", "ar-SA")
                {
                    HttpOnly = true
                };
                Response.AppendCookie(langCookie);
            }
            else
            {
                this.CurrentApplicationLanguage = Data.Core.Languages.English;
                var langCookie = new HttpCookie("lang", "en-US")
                {
                    HttpOnly = true
                };
                Response.AppendCookie(langCookie);
            }

            return Json("1", JsonRequestBehavior.AllowGet);
        }
        #endregion
    }
}
