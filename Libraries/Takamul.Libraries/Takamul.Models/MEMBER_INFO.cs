//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Takamul.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class MEMBER_INFO
    {
        public int ID { get; set; }
        public Nullable<int> APPLICATION_ID { get; set; }
        public string MEMBER_INFO_TITLE { get; set; }
        public string MEMBER_INFO_DESCRIPTION { get; set; }
        public Nullable<int> LANGUAGE_ID { get; set; }
        public Nullable<int> CREATED_BY { get; set; }
        public Nullable<System.DateTime> CREATED_DATE { get; set; }
        public Nullable<int> MODIFIED_BY { get; set; }
        public Nullable<System.DateTime> MODIFIED_DATE { get; set; }
    
        public virtual APPLICATIONS APPLICATIONS { get; set; }
    }
}
