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
    
    public partial class NEWS
    {
        public int ID { get; set; }
        public Nullable<int> APPLICATION_ID { get; set; }
        public string NEWS_TITLE { get; set; }
        public string NEWS_IMG_FILE_PATH { get; set; }
        public string NEWS_CONTENT { get; set; }
        public Nullable<bool> IS_NOTIFY_USER { get; set; }
        public Nullable<bool> IS_ACTIVE { get; set; }
        public Nullable<System.DateTime> PUBLISHED_DATE { get; set; }
        public Nullable<int> CREATED_BY { get; set; }
        public Nullable<System.DateTime> CREATED_DATE { get; set; }
        public Nullable<int> MODIFIED_BY { get; set; }
        public Nullable<System.DateTime> MODIFIED_DATE { get; set; }
        public Nullable<System.Guid> FileId { get; set; }
        public string FileName { get; set; }
        public string FileExtension { get; set; }
    
        public virtual APPLICATIONS APPLICATIONS { get; set; }
    }
}