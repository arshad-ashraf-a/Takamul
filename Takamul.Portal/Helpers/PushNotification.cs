﻿using Data.Core;
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
using System.Threading.Tasks;

namespace Takamul.Portal.Helpers
{
    public class PushNotification
    {
        #region :: Properties ::
        public enmNotificationType NotificationType { get; set; }
        public string sHeadings { get; set; }
        public string sContent { get; set; }
        public Languages enmLanguage { get; set; }
        public string sRecordID { get; set; }
        public string sDeviceID { get; set; }
        public string sRequestJSON { get; set; }
        public bool bIsSentNotification { get; set; }
        public string sResponseResult { get; set; }
        #endregion

        #region :: Constructor :: PushNotification ::
        public PushNotification()
        {
            this.NotificationType = enmNotificationType.Undefined;
            this.sHeadings = string.Empty;
            this.sContent = string.Empty;
            this.enmLanguage = Languages.English;
            this.sRecordID = string.Empty;
            this.sDeviceID = string.Empty;
            this.sRequestJSON = string.Empty;
            this.bIsSentNotification = false;
            this.sResponseResult = string.Empty;
        } 
        #endregion

        public void SendPushNotification()
        {
            string sLanguageCode = string.Empty;
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
                dynamic JObjectData = new JObject();
                JObjectData.app_id = CommonHelper.sGetConfigKeyValue(ConstantNames.MobileAppID);
                if (enmLanguage == Languages.Arabic)
                {
                    JObjectData.headings = new JObject(
                        new JProperty("en", sHeadings),
                        new JProperty(sLanguageCode, sHeadings)
                        );
                }
                else
                {
                    JObjectData.headings = new JObject(
                      new JProperty(sLanguageCode, sHeadings)
                      );
                }
                if (enmLanguage == Languages.Arabic)
                {
                    JObjectData.contents = new JObject(
                        new JProperty("en", sHeadings),
                        new JProperty(sLanguageCode, sContent)
                        );
                }
                else
                {
                    JObjectData.contents = new JObject(
                      new JProperty(sLanguageCode, sContent)
                      );
                }
                switch (NotificationType)
                {
                    case enmNotificationType.News:
                        JObjectData.data = new JObject(
                                                   new JProperty("NewsID", sRecordID),
                                                   new JProperty("LanguageID", (int)enmLanguage)
                                           );
                        break;
                    case enmNotificationType.Events:
                        JObjectData.data = new JObject(
                                                  new JProperty("EventID", sRecordID),
                                                  new JProperty("LanguageID", (int)enmLanguage)
                                          );
                        break;
                    case enmNotificationType.Tickets:
                        JObjectData.data = new JObject(
                                               new JProperty("TicketID", sRecordID),
                                               new JProperty("LanguageID", (int)enmLanguage)
                                       );
                        break;
                }

                if (sDeviceID != "")
                {
                    JObjectData.include_player_ids = sDeviceID.Split(',').ToArray();
                }
                else
                {
                    JObjectData.included_segments = new JArray("All");
                }

                sRequestJSON = JObjectData.ToString(Newtonsoft.Json.Formatting.None);
                byte[] arrBytes = Encoding.UTF8.GetBytes(JObjectData.ToString(Newtonsoft.Json.Formatting.None));
                
                using (var writer = oWebRequest.GetRequestStream())
                {
                    writer.Write(arrBytes, 0, arrBytes.Length);
                }

                using (var response = oWebRequest.GetResponse() as HttpWebResponse)
                {
                    using (var reader = new StreamReader(response.GetResponseStream()))
                    {
                        this.bIsSentNotification = true;
                        this.sResponseResult = reader.ReadToEnd();
                    }
                }
            }
            catch (WebException ex)
            {
                Elmah.ErrorLog.GetDefault(System.Web.HttpContext.Current).Log(new Elmah.Error(ex));
            }
        }
    }
}