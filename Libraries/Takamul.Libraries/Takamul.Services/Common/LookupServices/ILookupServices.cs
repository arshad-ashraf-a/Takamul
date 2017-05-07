using System.Collections.Generic;
using Takamul.Models;

namespace Takamul.Services
{
    public interface ILookupServices
    {
        #region Method :: lGetAllTicketStatus
        /// <summary>
        /// Get ticket status
        /// </summary>
        /// <returns></returns>
        List<Lookup> lGetAllTicketStatus();
        #endregion
    }
}
