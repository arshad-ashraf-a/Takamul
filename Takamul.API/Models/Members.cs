using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Takamul.API.Models
{
    public class Members
    {
        public int MemberID
        {
            get;
            set;
        }
        public string AppId
        {
            get;
            set;
        }
        public string MemberUsername
        {
            get;
            set;
        }
        public string MemberPassword
        {
            get;
            set;
        }
        public string Address
        {
            get;
            set;
        }
    }
}