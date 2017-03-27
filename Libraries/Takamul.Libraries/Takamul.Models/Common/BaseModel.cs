using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.Models
{
    public class BaseModel
    {
        public int TotalCount { get; set; }
        public int PageNumber { get; set; }
        public int RowspPage { get; set; }

        public BaseModel()
        {
            this.TotalCount = -99;
            this.PageNumber = 1;
            this.RowspPage = 10;
        }
    }
}
