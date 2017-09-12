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
            bool flg = false;
            try
            {
                SMSService.PushMessageRequestBody MsgBodyobj = new SMSService.PushMessageRequestBody();
                MsgBodyobj.Language = oSMSViewModel.Language;
                MsgBodyobj.Message = oSMSViewModel.Message;
                ArrayOfString arrPhoneNos = new ArrayOfString();
                arrPhoneNos[0] = oSMSViewModel.Recipient;
                MsgBodyobj.Recipients = arrPhoneNos;
                MsgBodyobj.RecipientType = oSMSViewModel.RecipientType;
                MsgBodyobj.UserID = CommonHelper.sGetConfigKeyValue(ConstantNames.SMSServiceUserName);
                MsgBodyobj.Password = CommonHelper.sGetConfigKeyValue(ConstantNames.SMSServicPassword);
                SMSService.PushMessageRequest req = new PushMessageRequest(MsgBodyobj);
            }
            catch (Exception ex)
            {

            }
            return flg;
        }
    }
}