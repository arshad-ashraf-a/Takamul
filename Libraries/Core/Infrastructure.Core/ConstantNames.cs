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

    }
}
