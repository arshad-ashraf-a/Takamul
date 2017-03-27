
using Infrastructure.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using Newtonsoft.Json;
using Takamul.Services;
using Takamul.Models;

namespace LDC.eServices.Portal.Controllers
{
    public class AccountController : Controller
    {
        // GET: Home
        [AllowAnonymous]
        public ActionResult Login()
        {
            return View();
        }

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult LogOn(Login login, string returnUrl)
        {
            if (!ValidateLogOn(login.username, login.password))
                return View("Login");

            if (LoginServices.ValidateUser(login, Response))
            {
                if (!string.IsNullOrEmpty(returnUrl))
                    return Redirect(returnUrl);
                else
                    return RedirectToAction("Index", "Home");
            }
            else
            {
                ModelState.AddModelError("", "Invalid username or password.");
                return View("Login");
            }
        }

        private bool ValidateLogOn(string userName, string password)
        {
            if (string.IsNullOrEmpty(userName))
                ModelState.AddModelError("username", "User name required");

            if (string.IsNullOrEmpty(password))
                ModelState.AddModelError("password", "Password required");

            return ModelState.IsValid;
        }

        [AllowAnonymous]
        public ActionResult LogOut()
        {
            LoginServices.Logoff(Session, Response);
            return RedirectToAction("Login", "Account", null);
        }
    }
}