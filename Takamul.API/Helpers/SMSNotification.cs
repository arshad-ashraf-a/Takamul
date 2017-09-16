using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Takamul.API.SMSService;
using Takamul.Models.ViewModel;

namespace Takamul.API.Helpers
{
    public class SMSNotification
    {
        public bool bSendOTPSMS(SMSViewModel oSMSViewModel)
        {
            try
            {
                ArrayOfString arrPhoneNos = new ArrayOfString();
                arrPhoneNos.Add("968" + oSMSViewModel.Recipient.ToString());
                SMSService.BulkSMSSoapClient client = new BulkSMSSoapClient();
                int nResult = client.PushMessage(CommonHelper.sGetConfigKeyValue(ConstantNames.SMSServiceUserName), CommonHelper.sGetConfigKeyValue(ConstantNames.SMSServicPassword),
                    oSMSViewModel.Message, oSMSViewModel.Language, DateTime.Now, arrPhoneNos, 1);

                return nResult == 1;
            }
            catch (Exception ex)
            {
                return false;
            }
            
        }
    }
}