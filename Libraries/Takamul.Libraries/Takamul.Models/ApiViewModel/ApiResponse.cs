using Infrastructure.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Takamul.Models.ApiViewModel
{
    public class ApiResponse
    {
        public int OperationResult { get; set; }
        public string OperationResultMessage { get; set; }
        public int ResponseID { get; set; }
        public string ResponseCode { get; set; }

        public ApiResponse()
        {
            this.OperationResultMessage = string.Empty;
            this.ResponseID = 99;
            this.OperationResult = -99;
            this.ResponseCode = "-99";
        }
    }
}
