using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Core
{
    #region Enum :: OperationResult
    /// <summary>
    /// Enum Operation Result
    /// </summary>
    public enum enumOperationResult
    {
        /// <summary>
        /// Operation has been faild 
        /// </summary>
        Faild = 0,
        /// <summary>
        /// Operation has been success
        /// </summary>
        Success = 1,
        /// <summary>
        /// The related record faild
        /// </summary>
        RelatedRecordFaild = -2,
        /// <summary>
        /// Already exist record faild
        /// </summary>
        AlreadyExistRecordFaild = -3,
        /// <summary>
        /// Can Not Insert In This Date
        /// </summary>
        CanNotInsertInThisDate = -4
    }
    #endregion

    #region Enum :: FileTypes
    /// <summary>
    /// Enum Operation Result
    /// </summary>
    public enum enumFileTypes
    {
        /// <summary>
        /// Default Text Type 
        /// </summary>
        Text = 1,
        /// <summary>
        /// PNG Type
        /// </summary>
        png = 2,
        /// <summary>
        /// JPG Type
        /// </summary>
        jpg = 3,
        /// <summary>
        /// JPEG Type
        /// </summary>
        jpeg = 4,
        /// <summary>
        /// DOC Type
        /// </summary>
        doc = 5,
        /// <summary>
        /// DOCX Type
        /// </summary>
        docx = 6,
        /// <summary>
        /// PDF Type
        /// </summary>
        pdf = 7,
    }
    #endregion

    public class EnumHandler
    {
        
    }
}
