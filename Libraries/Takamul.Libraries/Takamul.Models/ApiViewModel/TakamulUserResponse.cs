/****************************************************************************************************/
/* Class Name           : TakamulUser.cs                                                            */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of user data                                                */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ApiViewModel
{
    public class TakamulUserResponse
    {
        public TakamulUser TakamulUser { get; set; }

        public ApiResponse ApiResponse { get; set; }
        #region :: Constructor ::
        public TakamulUserResponse()
        {
            TakamulUser = new TakamulUser();
            ApiResponse = new ApiResponse();
        }
        #endregion
    }
}
