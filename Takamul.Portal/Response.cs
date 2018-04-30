using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApplication1.Models
{
    public class Response
    {
        public OperationResult OperationResult { get; set; }
        public string OperationResultMessage { get; set; }

    }
    public enum OperationResult
    {
        Success = 1,
        Failed = 0
    }
}