using Infrastructure.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;


namespace Takamul.Models
{
    public class Response
    {
        public enumOperationResult OperationResult { get; set; }

        public string OperationResultMessage { get; set; }

        public string ResponseID { get; set; }

        public string ResponseChildID { get; set; }

        public string ResponseText { get; set; }

        public Response()
        {
            this.OperationResultMessage = string.Empty;
            this.ResponseText = string.Empty;
            this.ResponseID = "-99";
            this.ResponseChildID = "-99";
        }
    }
}
