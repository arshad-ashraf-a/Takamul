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
    
    public partial class EVENTS
    {
        public int ID { get; set; }
        public Nullable<int> APPLICATION_ID { get; set; }
        public string EVENT_NAME { get; set; }
        public string EVENT_DESCRIPTION { get; set; }
        public Nullable<System.DateTime> EVENT_DATE { get; set; }
        public string EVENT_LOCATION_NAME { get; set; }
        public string EVENT_LATITUDE { get; set; }
        public string EVENT_LONGITUDE { get; set; }
        public Nullable<bool> IS_ACTIVE { get; set; }
        public string EVENT_IMG_FILE_PATH { get; set; }
        public Nullable<int> LANGUAGE_ID { get; set; }
        public Nullable<int> CREATED_BY { get; set; }
        public Nullable<System.DateTime> CREATED_DATE { get; set; }
        public Nullable<int> MODIFIED_BY { get; set; }
        public Nullable<System.DateTime> MODIFIED_DATE { get; set; }
    }
}
