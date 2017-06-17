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
    
    public partial class USERS
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public USERS()
        {
            this.APPLICATION_PRIVILLAGES = new HashSet<APPLICATION_PRIVILLAGES>();
            this.USER_DETAILS = new HashSet<USER_DETAILS>();
        }
    
        public int ID { get; set; }
        public string USER_NAME { get; set; }
        public string PASSWORD { get; set; }
        public Nullable<int> USER_TYPE_ID { get; set; }
        public string PHONE_NUMBER { get; set; }
        public string EMAIL { get; set; }
        public Nullable<int> APPLICATION_ID { get; set; }
        public Nullable<bool> IS_ACTIVE { get; set; }
        public Nullable<bool> IS_BLOCKED { get; set; }
        public string BLOCKED_REMARKS { get; set; }
        public Nullable<int> CREATED_BY { get; set; }
        public Nullable<System.DateTime> CREATED_DATE { get; set; }
        public Nullable<int> MODIFIED_BY { get; set; }
        public Nullable<System.DateTime> MODIFIED_DATE { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<APPLICATION_PRIVILLAGES> APPLICATION_PRIVILLAGES { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<USER_DETAILS> USER_DETAILS { get; set; }
    }
}
