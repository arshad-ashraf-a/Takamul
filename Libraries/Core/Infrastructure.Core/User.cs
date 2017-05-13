using Data.Core;
using System;
namespace Infrastructure.Core
{
    public class User
    {
        #region nUserID
        private int userID;

        public int nUserID
        {
            get { return userID; }
            set { userID = value; }
        }
        #endregion

        #region sUserName
        private string userName;

        public string sUserName
        {
            get { return userName; }
            set { userName = value; }
        }
        #endregion

        #region sPassword
        private string password;

        public string sPassword
        {
            get { return password; }
            set { password = value; }
        }
        #endregion

        #region sUserFullNameArabic
        private string userFullNameArabic;

        public string sUserFullNameArabic
        {
            get { return userFullNameArabic; }
            set { userFullNameArabic = value; }
        }
        #endregion

        #region sUserTypeName
        private string userTypeName;

        public string sUserTypeName
        {
            get { return userTypeName; }
            set { userTypeName = value; }
        }
        #endregion

        #region sUserFullNameEnglish
        private string userFullNameEnglish;

        public string sUserFullNameEnglish
        {
            get { return userFullNameEnglish; }
            set { userFullNameEnglish = value; }
        }
        #endregion

        #region sTelephone
        private string telephone;

        public string sTelephone
        {
            get { return telephone; }
            set { telephone = value; }
        }
        #endregion

        #region sGSM
        private string gsm;

        public string sGSM
        {
            get { return gsm; }
            set { gsm = value; }
        }
        #endregion

        #region sEmail
        private int email;

        public int sEmail
        {
            get { return email; }
            set { email = value; }
        }
        #endregion

        #region sUserMenuHTML
        private string userMenuHTML;

        public string sUserMenuHTML
        {
            get { return userMenuHTML; }
            set { userMenuHTML = value; }
        }
        #endregion

        #region sUserImageURL
        private string userImageURL;

        public string sUserImageURL
        {
            get { return userImageURL; }
            set { userImageURL = value; }
        }
        #endregion

        #region sUserTypeIDs
        private string userTypeIDs;

        public string sUserTypeIDs
        {
            get { return userTypeIDs; }
            set { userTypeIDs = value; }
        }
        #endregion

        #region dtBirthDay
        private DateTime birthDay;

        public DateTime dtBirthDay
        {
            get { return birthDay; }
            set { birthDay = value; }
        }
        #endregion

        #region PreferedLanguage
        public Languages PreferedLanguage
        {
            get
            {
                return this.oPreferedLanguage;
            }
            set
            {
                this.oPreferedLanguage = value;
            }
        }

        private Languages oPreferedLanguage;
        #endregion

        #region CurrentLanguageID
        private int nCurrentLanguageID;

        public int CurrentLanguageID
        {
            get
            {
                return this.nCurrentLanguageID;
            }
            set
            {
                this.nCurrentLanguageID = value;
            }
        }
        #endregion

        #region CurrentApplicationID
        private int nCurrentApplicationID;

        public int CurrentApplicationID
        {
            get
            {
                return this.nCurrentApplicationID;
            }
            set
            {
                this.nCurrentApplicationID = value;
            }
        }
        #endregion

        #region UserType 

        public enumUserType UserType { get; set; }
        #endregion
    }
}
