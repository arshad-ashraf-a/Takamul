using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
    public class FileDetail
    {
        public Guid Id { get; set; }
        public string FileName { get; set; }
        public string Extension { get; set; }
        public int ApplicationId { get; set; }
        public int NewsId { get; set; }
        public virtual NewsViewModel News { get; set; }

        public FileDetail()
        {
            this.ApplicationId = -99;
            this.FileName = string.Empty;
            this.Extension = string.Empty;
            this.NewsId = -99;
        }
    }
}
