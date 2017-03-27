using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Core
{
    public class ApplicationKeys
    {
        #region TakamulConnectionString
        /// <summary>
        /// Takamul Connection Sting 
        /// </summary>
        public static string TakamulConnectionString
        {
            get
            {
                return ConfigurationManager.ConnectionStrings[ConstantNames.TakamulConnectionString].ToString();
            }
        }
        #endregion
    }
}
