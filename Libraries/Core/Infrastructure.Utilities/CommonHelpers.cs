using Data.Core;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Globalization;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;

namespace Infrastructure.Utilities
{
    public class CommonHelper
    {
        #region Method :: string :: AppendTimeStamp
        public static string AppendTimeStamp(string fileName)
        {
            return string.Concat(
                DateTime.Now.ToString("yyyyMMddHHmmssfff"),
                Path.GetExtension(fileName)
                );
        }
        #endregion
        

        #region sGetIPAddress
        public static string sGetIPAddress()
        {
            string sIP = string.Empty;
            string sForwardedFor = string.Empty;
            try
            {
                sForwardedFor = string.Format("{0}", HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"]);
                if (sForwardedFor.CompareTo("") == 0)
                {
                    sIP = string.Format("{0}", HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"]);
                }
                else
                {
                    int nPosition = sForwardedFor.IndexOf(',');
                    if (nPosition >= 0)
                    {
                        sIP = sForwardedFor.Substring(0, nPosition);
                    }
                    else
                    {
                        sIP = sForwardedFor;
                    }
                }
            }
            catch (System.Exception oException)
            {
                throw oException;
            }
            return sIP;
        }
        #endregion

        #region bIsWebConfigKeyExist
        public static bool bIsWebConfigKeyExist(string sKeyName)
        {
            if (string.IsNullOrEmpty(sKeyName))
            {
                throw new System.ArgumentNullException("KeyName is Required.");
            }
            bool result;
            try
            {
                if (string.IsNullOrEmpty(ConfigurationManager.AppSettings[sKeyName]))
                {
                    result = false;
                    return result;
                }
            }
            catch (System.Exception oException)
            {
                throw oException;
            }
            result = true;
            return result;
        }
        #endregion

        #region bIsConnectionStringExist
        public static bool bIsConnectionStringExist(string sConnectionStringName)
        {
            if (string.IsNullOrEmpty(sConnectionStringName))
            {
                throw new System.ArgumentNullException("sConnectionStringName is Required.");
            }
            bool result;
            try
            {
                if (WebConfigurationManager.ConnectionStrings[sConnectionStringName] != null && !string.IsNullOrEmpty(WebConfigurationManager.ConnectionStrings[sConnectionStringName].ToString()))
                {
                    result = true;
                    return result;
                }
            }
            catch (System.Exception oException)
            {
                throw oException;
            }
            result = false;
            return result;
        }
        #endregion

        #region sGetConnectionString
        public static string sGetConnectionString(string sConnectionStringName)
        {
            if (string.IsNullOrEmpty(sConnectionStringName))
            {
                throw new System.ArgumentNullException("ConnectionStringName is Required.");
            }
            string sConnectionString = string.Empty;
            try
            {
                if (CommonHelper.bIsConnectionStringExist(sConnectionStringName))
                {
                    sConnectionString = WebConfigurationManager.ConnectionStrings[sConnectionStringName].ConnectionString;
                }
            }
            catch (System.Exception oException)
            {
                throw oException;
            }
            return sConnectionString;
        }
        #endregion

        #region sGetConfigKeyValue
        public static string sGetConfigKeyValue(string sKeyName)
        {
            if (string.IsNullOrEmpty(sKeyName))
            {
                throw new System.ArgumentNullException("KeyName is Required.");
            }
            string sConfigKeyValue = string.Empty;
            try
            {
                if (CommonHelper.bIsWebConfigKeyExist(sKeyName))
                {
                    sConfigKeyValue = ConfigurationManager.AppSettings[sKeyName];
                }
            }
            catch (System.Exception oException)
            {
                throw oException;
            }
            return sConfigKeyValue;
        }
        #endregion

        #region bIsFileExist
        public static bool bIsFileExist(string sFilePath)
        {
            if (string.IsNullOrEmpty(sFilePath))
            {
                throw new System.ArgumentNullException("FilePath is Required.");
            }
            bool result;
            try
            {
                if (System.IO.File.Exists(sFilePath))
                {
                    result = true;
                    return result;
                }
            }
            catch (System.Exception oException)
            {
                throw oException;
            }
            result = false;
            return result;
        }
        #endregion

        #region oResizeImage
        public static Image oResizeImage(Image oImageToResize, Size oSize)
        {
            Bitmap oBmpImage = new Bitmap(oSize.Width, oSize.Height);
            try
            {
                Graphics oGraphics = Graphics.FromImage(oBmpImage);
                oGraphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                oGraphics.DrawImage(oImageToResize, 0, 0, oSize.Width, oSize.Height);
                oGraphics.Dispose();
            }
            catch (System.Exception oException)
            {
                throw oException;
            }
            return oBmpImage;
        }
        #endregion

        #region oResizeImageWithAutoScale
        public static Image oResizeImageWithAutoScale(Image oImagToResize, Size oSize)
        {
            int intSourceWidth = oImagToResize.Width;
            int intSourceHeight = oImagToResize.Height;
            Bitmap oResizedImage = null;
            try
            {
                float fltPercentW = (float)oSize.Width / (float)intSourceWidth;
                float fltPercentH = (float)oSize.Height / (float)intSourceHeight;
                float fltPercent;
                if (fltPercentH < fltPercentW)
                {
                    fltPercent = fltPercentH;
                }
                else
                {
                    fltPercent = fltPercentW;
                }
                int intResizedImageWidth = (int)((float)intSourceWidth * fltPercent);
                int intResizedtHeight = (int)((float)intSourceHeight * fltPercent);
                oResizedImage = new Bitmap(intResizedImageWidth, intResizedtHeight);
                Graphics oGraphics = Graphics.FromImage(oResizedImage);
                oGraphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                oGraphics.DrawImage(oImagToResize, 0, 0, intResizedImageWidth, intResizedtHeight);
                oGraphics.Dispose();
            }
            catch (System.Exception oException)
            {
                throw oException;
            }
            return oResizedImage;
        }
        #endregion

        #region sGenerateRandomCode
        public static string sGenerateRandomCode(int CodeLength)
        {
            string sValidChar = string.Empty;
            string sGeneratedCode = string.Empty;
            try
            {
                sValidChar = "1234567890";
                System.Random oRandomCharacter = new System.Random();
                for (int intCounter = 0; intCounter < CodeLength; intCounter++)
                {
                    int intSelectedIndex = oRandomCharacter.Next(sValidChar.Length);
                    sGeneratedCode += sValidChar[intSelectedIndex];
                }
            }
            catch (System.Exception oException)
            {
                throw oException;
            }
            return sGeneratedCode;
        }
        #endregion

        #region bIsValidEmail
        public static bool bIsValidEmail(string sEmail)
        {
            bool result;
            if (string.IsNullOrEmpty(sEmail))
            {
                result = false;
            }
            else
            {
                sEmail = sEmail.Trim();
                result = Regex.IsMatch(sEmail, "^(?:[\\w\\!\\#\\$\\%\\&\\'\\*\\+\\-\\/\\=\\?\\^\\`\\{\\|\\}\\~]+\\.)*[\\w\\!\\#\\$\\%\\&\\'\\*\\+\\-\\/\\=\\?\\^\\`\\{\\|\\}\\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\\-](?!\\.)){0,61}[a-zA-Z0-9]?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\\[(?:(?:[01]?\\d{1,2}|2[0-4]\\d|25[0-5])\\.){3}(?:[01]?\\d{1,2}|2[0-4]\\d|25[0-5])\\]))$", RegexOptions.IgnoreCase);
            }
            return result;
        }
        #endregion

        #region sGenerateRandomDigitCode
        public static string sGenerateRandomDigitCode(int nLength)
        {
            System.Random oRandom = new System.Random();
            string sRandomDigitCode = string.Empty;
            for (int nCode = 0; nCode < nLength; nCode++)
            {
                sRandomDigitCode += oRandom.Next(10).ToString();
            }
            return sRandomDigitCode;
        }
        #endregion

        #region nGenerateRandomInteger
        public static int nGenerateRandomInteger(int nMin, int nMax)
        {
            byte[] bytArrRandomNumberBuffer = new byte[10];
            new System.Security.Cryptography.RNGCryptoServiceProvider().GetBytes(bytArrRandomNumberBuffer);
            return new System.Random(System.BitConverter.ToInt32(bytArrRandomNumberBuffer, 0)).Next(nMin, nMax);
        }
        #endregion

        #region bIsArraysEqual
        public static bool bIsArraysEqual<T>(T[] oArr1, T[] oArr2)
        {
            bool result;
            if (object.ReferenceEquals(oArr1, oArr2))
            {
                result = true;
            }
            else if (oArr1 == null || oArr2 == null)
            {
                result = false;
            }
            else if (oArr1.Length != oArr2.Length)
            {
                result = false;
            }
            else
            {
                System.Collections.Generic.EqualityComparer<T> comparer = System.Collections.Generic.EqualityComparer<T>.Default;
                for (int nArryItem = 0; nArryItem < oArr1.Length; nArryItem++)
                {
                    if (!comparer.Equals(oArr1[nArryItem], oArr2[nArryItem]))
                    {
                        result = false;
                        return result;
                    }
                }
                result = true;
            }
            return result;
        }
        #endregion

        #region sValidatPhoneNumber
        public static string sValidatPhoneNumber(object sPhoneNumber)
        {
            string result;
            if (sPhoneNumber != null && sPhoneNumber.ToString().StartsWith("9") && sPhoneNumber.ToString().Length == 8)
            {
                result = sPhoneNumber.ToString();
            }
            else
            {
                result = string.Empty;
            }
            return result;
        }
        #endregion

        #region bytArrConvertHttpPostedFileBaseToBytes
        public static byte[] bytArrConvertHttpPostedFileBaseToBytes(HttpPostedFileBase oCurrentFile)
        {
            byte[] bytArrResult;
            using (System.IO.Stream oInputStream = oCurrentFile.InputStream)
            {
                System.IO.MemoryStream oMemoryStream = oInputStream as System.IO.MemoryStream;
                if (oMemoryStream == null)
                {
                    oMemoryStream = new System.IO.MemoryStream();
                    oInputStream.CopyTo(oMemoryStream);
                }
                bytArrResult = oMemoryStream.ToArray();
            }
            return bytArrResult;
        }
        #endregion

        #region ToMonthName
        public static string ToMonthName(System.DateTime dateTime)
        {
            return System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(dateTime.Month);
        }
        #endregion

        #region dtiParseDateByFormat
        public static System.DateTime dtiParseDateByFormat(string sDate, string sFormat)
        {
            return System.DateTime.ParseExact(sDate, sFormat, System.Globalization.CultureInfo.InvariantCulture);
        }
        #endregion

        #region ConvertToEasternArabicNumerals
        public static string ConvertToEasternArabicNumerals(string input)
        {
            System.Text.UTF8Encoding utf8Encoder = new System.Text.UTF8Encoding();
            System.Text.Decoder utf8Decoder = utf8Encoder.GetDecoder();
            System.Text.StringBuilder convertedChars = new System.Text.StringBuilder();
            char[] convertedChar = new char[1];
            byte[] bytes = new byte[]
            {
                217,
                160
            };
            char[] inputCharArray = input.ToCharArray();
            char[] array = inputCharArray;
            for (int i = 0; i < array.Length; i++)
            {
                char c = array[i];
                if (char.IsDigit(c))
                {
                    bytes[1] = System.Convert.ToByte(160.0 + char.GetNumericValue(c));
                    utf8Decoder.GetChars(bytes, 0, 2, convertedChar, 0);
                    convertedChars.Append(convertedChar[0]);
                }
                else
                {
                    convertedChars.Append(c);
                }
            }
            return convertedChars.ToString();
        } 
        #endregion
    }
}
