using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Core
{
    public class ConstantNames
    {
        #region LDCConnectionName
        /// <summary>
        /// LDC Connection Name
        /// </summary>
        public static string LDCConnectionName
        {
            get
            {
                return "LDCConnection";
            }
        }
        #endregion

        #region TRMStatusSubmitted
        /// <summary>
        /// TRM Submitted Status 
        /// </summary>
        public static string TRMStatusSubmitted
        {
            get
            {
                return "TRMStatusSubmitted";
            }
        }
        #endregion

        #region PreliminaryUploadFolder
        /// <summary>
        /// Preliminary Upload Folder 
        /// </summary>
        public static string PreliminaryUploadFolder
        {
            get
            {
                return "PreliminaryUploadFolder";
            }
        }
        #endregion

        #region TRMUploadFolder
        /// <summary>
        /// TRM Upload Folder 
        /// </summary>
        public static string TRMUploadFolder
        {
            get
            {
                return "TRMUploadFolder";
            }
        }
        #endregion

        #region FinalUploadFolder
        /// <summary>
        /// Final Upload Folder 
        /// </summary>
        public static string FinalUploadFolder
        {
            get
            {
                return "FinalUploadFolder";
            }
        }
        #endregion

        #region DeclarationDueDate
        /// <summary>
        /// TRM Upload Folder 
        /// </summary>
        public static string DeclarationDueDate
        {
            get
            {
                return "DeclarationDueDate";
            }
        }
        #endregion
    }
}
