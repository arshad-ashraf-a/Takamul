using System.Collections.Generic;
using System.Data.Entity;
using Data.Core;
using Takamul.Models;

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

        #region IlGetAllIncidentStatus
        /// <summary>
        /// Get incident status
        /// </summary>
        /// <returns></returns>
        public List<Lookup> IlGetAllIncidentStatus()
        {
            #region ":Get Sp Result:"
            List<Lookup> lookups = this.ExecuteStoredProcedureList<Lookup>("Inc_GetAllIncidentStatusLookUps");
            return lookups;
            #endregion
        }
        #endregion
    }
}
