using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Core
{
    public class ConstantNames
    {
        #region TakamulConnectionString
        /// <summary>
        /// Takamul Connection Name
        /// </summary>
        public static string TakamulConnectionString
        {
            get
            {
                return "TakamulServiceConnection";
            }
        }
        #endregion

        #region FileAccessURL
        /// <summary>
        /// Takamul Connection Name
        /// </summary>
        public static string FileAccessURL
        {
            get
            {
                return "FileAccessURL";
            }
        }
        #endregion

        #region FileServiceUploadFolder
        /// <summary>
        /// Takamul Connection Name
        /// </summary>
        public static string FileServiceUploadFolder
        {
            get
            {
                return "FileServiceUploadFolder";
            }
        }
        #endregion

        #region TakamulGoogleMapApIKey
        /// <summary>
        /// Takamul Google Map Key
        /// </summary>
        public static string TakamulGoogleMapApIKey
        {
            get
            {
                return "TakamulGoogleMapApIKey";
            }
        }
        #endregion

        #region GooglePlaceAPIUrl
        /// <summary>
        /// Google Place API Url
        /// </summary>
        public static string GooglePlaceAPIUrl
        {
            get
            {
                return "GooglePlaceAPIUrl";
            }
        }
        #endregion

        #region GooglePlaceDetailsAPIUrl
        /// <summary>
        /// Google Place Details API Url
        /// </summary>
        public static string GooglePlaceDetailsAPIUrl
        {
            get
            {
                return "GooglePlaceDetailsAPIUrl";
            }
        }
        #endregion

        #region TicketStatusOpenID
        /// <summary>
        /// Ticket Status Open ID
        /// </summary>
        public static string TicketStatusOpenID
        {
            get
            {
                return "TicketStatusOpenID";
            }
        }
        #endregion

        #region TicketStatusClosedID
        /// <summary>
        /// Ticket Closed Open ID
        /// </summary>
        public static string TicketStatusClosedID
        {
            get
            {
                return "TicketStatusClosedID";
            }
        }
        #endregion

        #region TicketStatusRejectedID
        /// <summary>
        /// Ticket Rejected Open ID
        /// </summary>
        public static string TicketStatusRejectedID
        {
            get
            {
                return "TicketStatusRejectedID";
            }
        }
        #endregion

        #region DefaultUserAccountPassword
        /// <summary>
        ///DefaultUserAccountPassword
        /// </summary>
        public static string DefaultUserAccountPassword
        {
            get
            {
                return "DefaultUserAccountPassword";
            }
        }
        #endregion

        #region TempBase64Image
        /// <summary>
        ///TempBase64Image
        /// </summary>
        public static string TempBase64Image
        {
            get
            {
                return "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";
            }
        }
        #endregion

    }
}
