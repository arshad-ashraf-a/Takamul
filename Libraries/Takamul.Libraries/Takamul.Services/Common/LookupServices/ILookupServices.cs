using System.Collections.Generic;
using Takamul.Models;

namespace Takamul.Services
{
    public interface ILookupServices
    {
        #region Method :: IlGetAllIncidentStatus
        /// <summary>
        /// Get incident status
        /// </summary>
        /// <returns></returns>
        List<Lookup> IlGetAllIncidentStatus();
        #endregion
    }
}
