using Data.Core;
using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using Newtonsoft.Json.Linq;
using System.Runtime.Serialization.Formatters.Binary;

namespace Takamul.Portal.Helpers
{
    public static class PushNotification
    {
        public static bool SendPushNotificationTest(enmNotificationType NotificationType, string sHeadings, string sContent, Languages enmLanguage, string sRecordID = "", string sDeviceID = "")
        {
            string sLanguageCode = string.Empty;
            bool flg = false;
            if (enmLanguage == Languages.Arabic)
            {
                sLanguageCode = ConstantNames.ArabicLanguageCode;
            }
            else
            {
                sLanguageCode = ConstantNames.EnglishLanguageCode;
            }

            var oWebRequest = WebRequest.Create(CommonHelper.sGetConfigKeyValue(ConstantNames.OneSignalServiceURL)) as HttpWebRequest;
            oWebRequest.KeepAlive = true;
            oWebRequest.Method = "POST";
            oWebRequest.ContentType = "application/json; charset=utf-8";

            string sAutherizationKey = string.Format("Basic {0}", CommonHelper.sGetConfigKeyValue(ConstantNames.OneSignalAuthKey));
            oWebRequest.Headers.Add("authorization", sAutherizationKey);

            var oSerializer = new JavaScriptSerializer();

            try
            {
                if (sDeviceID != "")
                {

                    var obj = new
                    {
                        app_id = CommonHelper.sGetConfigKeyValue(ConstantNames.MobileAppID),
                        headings = new { en = sHeadings },
                        contents = new { en = sContent },
                        data = new { NewsID = sRecordID },
                        include_player_ids = new string[] { sDeviceID }
                    };
                    var param = oSerializer.Serialize(obj);
                    byte[] byteArray = Encoding.UTF8.GetBytes(param);
                    string responseContent = null;

                    using (var writer = oWebRequest.GetRequestStream())
                    {
                        writer.Write(byteArray, 0, byteArray.Length);
                    }

                    using (var response = oWebRequest.GetResponse() as HttpWebResponse)
                    {
                        using (var reader = new StreamReader(response.GetResponseStream()))
                        {
                            responseContent = reader.ReadToEnd();
                            flg = true;
                        }
                    }
                    System.Diagnostics.Debug.WriteLine(responseContent);

                }
                else
                {
                    dynamic JObjectData = new JObject();
                    JObjectData.app_id = CommonHelper.sGetConfigKeyValue(ConstantNames.MobileAppID);
                    JObjectData.headings = new JObject(new JProperty(sLanguageCode, sHeadings));
                    JObjectData.contents = new JObject(new JProperty(sLanguageCode, sContent));
                    JObjectData.data = new JObject(
                        new JProperty(NotificationType == enmNotificationType.News ? "NewsID" : "EventID", sRecordID),
                        new JProperty("LanguageID", sLanguageCode)
                        );
                    JObjectData.included_segments = new JArray("All");



                    var obj = new
                    {
                        app_id = CommonHelper.sGetConfigKeyValue(ConstantNames.MobileAppID),
                        headings = new { en = sHeadings },
                        contents = new { en = sContent },
                        data = new { NewsID = sRecordID, LanguageID = sLanguageCode },
                        included_segments = new string[] { "All" }
                    };
                    var param1 = oSerializer.Serialize(obj);
                    var param = oSerializer.Serialize(JObjectData.ToString(Newtonsoft.Json.Formatting.None));
                    byte[] byteArray = Encoding.UTF8.GetBytes(param1);

                    byte[] bytes = Encoding.UTF8.GetBytes(Newtonsoft.Json.JsonConvert.SerializeObject(JObjectData));
                    
                    string responseContent = null;

                    using (var writer = oWebRequest.GetRequestStream())
                    {
                        writer.Write(bytes, 0, bytes.Length);
                    }

                    using (var response = oWebRequest.GetResponse() as HttpWebResponse)
                    {
                        using (var reader = new StreamReader(response.GetResponseStream()))
                        {
                            responseContent = reader.ReadToEnd();
                            flg = true;
                        }
                    }
                    System.Diagnostics.Debug.WriteLine(responseContent);

                }

            }
            catch (WebException ex)
            {
                System.Diagnostics.Debug.WriteLine(ex.Message);
                System.Diagnostics.Debug.WriteLine(new StreamReader(ex.Response.GetResponseStream()).ReadToEnd());

            }

            return flg;
        }
    }
}