﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Infrastructure.Utilities.SMSService {
    using System.Runtime.Serialization;
    using System;
    
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.Runtime.Serialization", "4.0.0.0")]
    [System.Runtime.Serialization.CollectionDataContractAttribute(Name="ArrayOfString", Namespace="http://tempuri.org/", ItemName="string")]
    [System.SerializableAttribute()]
    public class ArrayOfString : System.Collections.Generic.List<string> {
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ServiceModel.ServiceContractAttribute(ConfigurationName="SMSService.IBulkSMSSoap")]
    public interface IBulkSMSSoap {
        
        // CODEGEN: Generating message contract since element name UserID from namespace http://tempuri.org/ is not marked nillable
        [System.ServiceModel.OperationContractAttribute(Action="http://tempuri.org/PushMessage", ReplyAction="*")]
        Infrastructure.Utilities.SMSService.PushMessageResponse PushMessage(Infrastructure.Utilities.SMSService.PushMessageRequest request);
        
        [System.ServiceModel.OperationContractAttribute(Action="http://tempuri.org/PushMessage", ReplyAction="*")]
        System.Threading.Tasks.Task<Infrastructure.Utilities.SMSService.PushMessageResponse> PushMessageAsync(Infrastructure.Utilities.SMSService.PushMessageRequest request);
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(IsWrapped=false)]
    public partial class PushMessageRequest {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Name="PushMessage", Namespace="http://tempuri.org/", Order=0)]
        public Infrastructure.Utilities.SMSService.PushMessageRequestBody Body;
        
        public PushMessageRequest() {
        }
        
        public PushMessageRequest(Infrastructure.Utilities.SMSService.PushMessageRequestBody Body) {
            this.Body = Body;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.Runtime.Serialization.DataContractAttribute(Namespace="http://tempuri.org/")]
    public partial class PushMessageRequestBody {
        
        [System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue=false, Order=0)]
        public string UserID;
        
        [System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue=false, Order=1)]
        public string Password;
        
        [System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue=false, Order=2)]
        public string Message;
        
        [System.Runtime.Serialization.DataMemberAttribute(Order=3)]
        public int Language;
        
        [System.Runtime.Serialization.DataMemberAttribute(Order=4)]
        public System.DateTime ScheddateTime;
        
        [System.Runtime.Serialization.DataMemberAttribute(EmitDefaultValue=false, Order=5)]
        public Infrastructure.Utilities.SMSService.ArrayOfString Recipients;
        
        [System.Runtime.Serialization.DataMemberAttribute(Order=6)]
        public int RecipientType;
        
        public PushMessageRequestBody() {
        }
        
        public PushMessageRequestBody(string UserID, string Password, string Message, int Language, System.DateTime ScheddateTime, Infrastructure.Utilities.SMSService.ArrayOfString Recipients, int RecipientType) {
            this.UserID = UserID;
            this.Password = Password;
            this.Message = Message;
            this.Language = Language;
            this.ScheddateTime = ScheddateTime;
            this.Recipients = Recipients;
            this.RecipientType = RecipientType;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.ServiceModel.MessageContractAttribute(IsWrapped=false)]
    public partial class PushMessageResponse {
        
        [System.ServiceModel.MessageBodyMemberAttribute(Name="PushMessageResponse", Namespace="http://tempuri.org/", Order=0)]
        public Infrastructure.Utilities.SMSService.PushMessageResponseBody Body;
        
        public PushMessageResponse() {
        }
        
        public PushMessageResponse(Infrastructure.Utilities.SMSService.PushMessageResponseBody Body) {
            this.Body = Body;
        }
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
    [System.Runtime.Serialization.DataContractAttribute(Namespace="http://tempuri.org/")]
    public partial class PushMessageResponseBody {
        
        [System.Runtime.Serialization.DataMemberAttribute(Order=0)]
        public int PushMessageResult;
        
        public PushMessageResponseBody() {
        }
        
        public PushMessageResponseBody(int PushMessageResult) {
            this.PushMessageResult = PushMessageResult;
        }
    }
    
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public interface IBulkSMSSoapChannel : Infrastructure.Utilities.SMSService.IBulkSMSSoap, System.ServiceModel.IClientChannel {
    }
    
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.CodeDom.Compiler.GeneratedCodeAttribute("System.ServiceModel", "4.0.0.0")]
    public partial class BulkSMSSoapClient : System.ServiceModel.ClientBase<Infrastructure.Utilities.SMSService.IBulkSMSSoap>, Infrastructure.Utilities.SMSService.IBulkSMSSoap {
        
        public BulkSMSSoapClient() {
        }
        
        public BulkSMSSoapClient(string endpointConfigurationName) : 
                base(endpointConfigurationName) {
        }
        
        public BulkSMSSoapClient(string endpointConfigurationName, string remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public BulkSMSSoapClient(string endpointConfigurationName, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(endpointConfigurationName, remoteAddress) {
        }
        
        public BulkSMSSoapClient(System.ServiceModel.Channels.Binding binding, System.ServiceModel.EndpointAddress remoteAddress) : 
                base(binding, remoteAddress) {
        }
        
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
        Infrastructure.Utilities.SMSService.PushMessageResponse Infrastructure.Utilities.SMSService.IBulkSMSSoap.PushMessage(Infrastructure.Utilities.SMSService.PushMessageRequest request) {
            return base.Channel.PushMessage(request);
        }
        
        public int PushMessage(string UserID, string Password, string Message, int Language, System.DateTime ScheddateTime, Infrastructure.Utilities.SMSService.ArrayOfString Recipients, int RecipientType) {
            Infrastructure.Utilities.SMSService.PushMessageRequest inValue = new Infrastructure.Utilities.SMSService.PushMessageRequest();
            inValue.Body = new Infrastructure.Utilities.SMSService.PushMessageRequestBody();
            inValue.Body.UserID = UserID;
            inValue.Body.Password = Password;
            inValue.Body.Message = Message;
            inValue.Body.Language = Language;
            inValue.Body.ScheddateTime = ScheddateTime;
            inValue.Body.Recipients = Recipients;
            inValue.Body.RecipientType = RecipientType;
            Infrastructure.Utilities.SMSService.PushMessageResponse retVal = ((Infrastructure.Utilities.SMSService.IBulkSMSSoap)(this)).PushMessage(inValue);
            return retVal.Body.PushMessageResult;
        }
        
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Advanced)]
        System.Threading.Tasks.Task<Infrastructure.Utilities.SMSService.PushMessageResponse> Infrastructure.Utilities.SMSService.IBulkSMSSoap.PushMessageAsync(Infrastructure.Utilities.SMSService.PushMessageRequest request) {
            return base.Channel.PushMessageAsync(request);
        }
        
        public System.Threading.Tasks.Task<Infrastructure.Utilities.SMSService.PushMessageResponse> PushMessageAsync(string UserID, string Password, string Message, int Language, System.DateTime ScheddateTime, Infrastructure.Utilities.SMSService.ArrayOfString Recipients, int RecipientType) {
            Infrastructure.Utilities.SMSService.PushMessageRequest inValue = new Infrastructure.Utilities.SMSService.PushMessageRequest();
            inValue.Body = new Infrastructure.Utilities.SMSService.PushMessageRequestBody();
            inValue.Body.UserID = UserID;
            inValue.Body.Password = Password;
            inValue.Body.Message = Message;
            inValue.Body.Language = Language;
            inValue.Body.ScheddateTime = ScheddateTime;
            inValue.Body.Recipients = Recipients;
            inValue.Body.RecipientType = RecipientType;
            return ((Infrastructure.Utilities.SMSService.IBulkSMSSoap)(this)).PushMessageAsync(inValue);
        }
    }
}
