using System.Collections.Generic;
using System.Data.Entity;
using Data.Core;
using Takamul.Models;
using System.Data.Common;

namespace Takamul.Services
{
    public class LookupServices : EntityService<Lookup>, ILookupServices
    {
        #region Members
        private readonly TakamulConnection oTakamulConnection;

        public LookupServices(DbContext oDataBaseContextIntialization) :
            base(oDataBaseContextIntialization)
        {
            oTakamulConnection = (oTakamulConnection ?? (TakamulConnection)oDataBaseContextIntialization);

        }
        #endregion

        #region lGetAllTicketStatus
        /// <summary>
        /// Get incident status
        /// </summary>
        /// <returns></returns>
        public List<Lookup> lGetAllTicketStatus()
        {
            #region ":Get Sp Result:"

            List<Lookup> lookups = this.ExecuteStoredProcedureList<Lookup>("GetAllTicketStatusLookup");
            return lookups;
            #endregion
        }
        #endregion
    }
}
