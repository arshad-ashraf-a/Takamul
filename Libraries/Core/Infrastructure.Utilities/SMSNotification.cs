using Infrastructure.Utilities.SMSService;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Takamul.Models.ViewModel;

namespace Infrastructure.Utilities
{
    public class SMSNotification
    {
         
        public bool SendOTPviaSMS(SMSClass _cls)
        {
            bool flg = false;
            try
            {
                SMSService.PushMessageRequestBody MsgBodyobj = new SMSService.PushMessageRequestBody();
                MsgBodyobj.Language = _cls.Language;
                MsgBodyobj.Message = _cls.Message;
                ArrayOfString arrPhoneNos = new ArrayOfString();
                arrPhoneNos[0] = _cls.Recipient;
                MsgBodyobj.Recipients = arrPhoneNos;
                MsgBodyobj.RecipientType = _cls.RecipientType;
                MsgBodyobj.UserID = "sawawebs"; //Needs to push to configuration with encryption.
                MsgBodyobj.Password = "Sawaweb@123";
                SMSService.PushMessageRequest req = new PushMessageRequest(MsgBodyobj);
            }
            catch (Exception ex)
            {

            }
            return flg;
        }
    }
}
