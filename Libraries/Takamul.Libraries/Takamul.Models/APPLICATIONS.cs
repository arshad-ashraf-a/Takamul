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
    
    public partial class APPLICATIONS
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public APPLICATIONS()
        {
            this.EVENTS = new HashSet<EVENTS>();
            this.TICKETS = new HashSet<TICKETS>();
            this.MEMBER_INFO = new HashSet<MEMBER_INFO>();
            this.NEWS = new HashSet<NEWS>();
        }
    
        public int ID { get; set; }
        public string APPLICATION_NAME { get; set; }
        public string APPLICATION_LOGO_PATH { get; set; }
        public string DEFAULT_THEME_COLOR { get; set; }
        public Nullable<System.DateTime> APPLICATION_EXPIRY_DATE { get; set; }
        public string APPLICATION_TOKEN { get; set; }
        public Nullable<bool> IS_ACTIVE { get; set; }
        public Nullable<int> CREATED_BY { get; set; }
        public Nullable<System.DateTime> CREATED_DATE { get; set; }
        public Nullable<int> MODIFIED_BY { get; set; }
        public Nullable<System.DateTime> MODIFIED_DATE { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<EVENTS> EVENTS { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<TICKETS> TICKETS { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<MEMBER_INFO> MEMBER_INFO { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<NEWS> NEWS { get; set; }
    }
}
