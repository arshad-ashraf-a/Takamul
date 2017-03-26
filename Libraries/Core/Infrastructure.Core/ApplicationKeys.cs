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
        #region LDCConnectionString
        /// <summary>
        /// LDC Connection Sting 
        /// </summary>
        public static string LDCConnectionString
        {
            get
            {
                return ConfigurationManager.ConnectionStrings[ConstantNames.LDCConnectionName].ToString();
            }
        }
        #endregion
    }
}
