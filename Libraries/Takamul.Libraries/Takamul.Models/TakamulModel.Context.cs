﻿//------------------------------------------------------------------------------
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
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    
    public partial class TakamulConnection : DbContext
    {
        public TakamulConnection()
            : base("name=TakamulConnection")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<APPLICATIONS> APPLICATIONS { get; set; }
        public virtual DbSet<TICKETS> TICKETS { get; set; }
        public virtual DbSet<MEMBER_INFO> MEMBER_INFO { get; set; }
        public virtual DbSet<NEWS> NEWS { get; set; }
        public virtual DbSet<EVENTS> EVENTS { get; set; }
        public virtual DbSet<ABOUT_APP> ABOUT_APP { get; set; }
        public virtual DbSet<ABOUTAPP_LINKS> ABOUTAPP_LINKS { get; set; }
        public virtual DbSet<APPLICATION_ENTITIES> APPLICATION_ENTITIES { get; set; }
        public virtual DbSet<APPLICATION_PRIVILLAGES> APPLICATION_PRIVILLAGES { get; set; }
        public virtual DbSet<APPLICATION_USERS> APPLICATION_USERS { get; set; }
        public virtual DbSet<DB_LOGS> DB_LOGS { get; set; }
        public virtual DbSet<TICKET_CHAT_DETAILS> TICKET_CHAT_DETAILS { get; set; }
        public virtual DbSet<TICKET_CHAT_TYPES> TICKET_CHAT_TYPES { get; set; }
        public virtual DbSet<TICKET_PARTICIPANTS> TICKET_PARTICIPANTS { get; set; }
        public virtual DbSet<TICKET_STATUS> TICKET_STATUS { get; set; }
        public virtual DbSet<USER_DETAILS> USER_DETAILS { get; set; }
        public virtual DbSet<USER_TYPES> USER_TYPES { get; set; }
        public virtual DbSet<USERS> USERS { get; set; }
        public virtual DbSet<APPLICATION_SETTINGS> APPLICATION_SETTINGS { get; set; }
    }
}
