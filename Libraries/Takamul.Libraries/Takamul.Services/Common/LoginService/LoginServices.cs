using Common.DBAccess;
using Infrastructure.Core;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Security;
using Takamul.Models;
using static Common.DBAccess.DBConnector;

namespace Takamul.Services
{
    public class LoginServices : BaseClassLibrary
    {
        #region :: Public Properties ::
        public string sUserName { get; set; }
        public string sPassword { get; set; }
        #endregion

        #region :: Constructor ::
        public LoginServices()
        {
            this.sUserName = string.Empty;
            this.sPassword = string.Empty;
        }
        #endregion


        /// <summary>
        /// Authenticates a user against a database, web service, etc.
        /// </summary>
        /// <param name="username">Username</param>
        /// <param name="password">Password</param>
        /// <returns>User</returns>
        public User AuthenticateUser()
        {
            User user = null;
            user = this.oGetCurrentUser();
            return user;
        }

        /// <summary>
        /// Authenticates a user via the MembershipProvider and creates the associated forms authentication ticket.
        /// </summary>
        /// <param name="logon">Logon</param>
        /// <param name="response">HttpResponseBase</param>
        /// <returns>bool</returns>
        public static bool ValidateUser(Login logon, HttpResponseBase response)
        {
            bool result = false;

            if (Membership.ValidateUser(logon.username, logon.password))
            {
                // Create the authentication ticket with custom user data.
                var serializer = new JavaScriptSerializer();
                string userData = serializer.Serialize(Infrastructure.Utilities.BaseController.CurrentUser);

                FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(1,
                        logon.username,
                        DateTime.Now,
                        DateTime.Now.AddDays(30),
                        true,
                        userData,
                        FormsAuthentication.FormsCookiePath);

                // Encrypt the ticket.
                string encTicket = FormsAuthentication.Encrypt(ticket);

                // Create the cookie.
                response.Cookies.Add(new HttpCookie(FormsAuthentication.FormsCookieName, encTicket));

                result = true;
            }

            return result;
        }

        /// <summary>
        /// Clears the user session, clears the forms auth ticket, expires the forms auth cookie.
        /// </summary>
        /// <param name="session">HttpSessionStateBase</param>
        /// <param name="response">HttpResponseBase</param>
        public static void Logoff(HttpSessionStateBase session, HttpResponseBase response)
        {
            // Delete the user details from cache.
            session.Abandon();

            // Delete the authentication ticket and sign out.
            FormsAuthentication.SignOut();

            // Clear authentication cookie.
            HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, "");
            cookie.Expires = DateTime.Now.AddYears(-1);
            response.Cookies.Add(cookie);
        }


        #region Get Current User

        public User oGetCurrentUser()
        {
            if (this.DBConnectionString.Trim().Equals(string.Empty))
            {
                throw new Exception("The DBConnectionString property is not set");
            }

            this.OperationResult = 0;
            this.oDBConnector = new DBConnector(this.DBConnectionString);
            User oUser = null;

            if (this.oDBConnector != null)
            {
                this.oDBConnector.AddInParam("@UserName", this.sUserName, DBTypes.VarChar);
                this.oDBConnector.AddInParam("@Password", this.sPassword, DBTypes.VarChar);

                try
                {
                    this.oDBConnector.Open();
                    IDataReader oReader = this.oDBConnector.ReadDbWithStoredProcedureDataReader("UserLogin");

                    if (oReader != null)
                    {
                        while (oReader.Read())
                        {
                            oUser = new User();
                            oUser.nUserID = oReader.FieldExists("ID") ? Convert.ToInt32(oReader["ID"]) : -99;
                            oUser.sUserName = oReader.FieldExists("USER_NAME") ? oReader["USER_NAME"].ToString() : string.Empty;
                            oUser.sUserTypeName = oReader.FieldExists("USER_TYPE_NAME") ? oReader["USER_TYPE_NAME"].ToString() : string.Empty;
                        }
                        this.OperationResult = 1;
                    }
                }
                catch
                {
                    oUser = null;
                    this.OperationResult = 0;
                }
                finally
                {
                    if (this.oDBConnector != null)
                    {
                        this.oDBConnector.Close();
                    }
                }
            }
            return oUser;
        }
        #endregion
    }
}
