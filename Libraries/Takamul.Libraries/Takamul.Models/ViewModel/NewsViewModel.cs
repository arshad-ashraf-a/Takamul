/****************************************************************************************************/
/* Class Name           : NewsViewModel.cs                                                          */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of news data                                                */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
    public class NewsViewModel
    {
        
        public int ID { get; set; }
        public int APPLICATION_ID { get; set; }
        public string NEWS_TITLE { get; set; }
        public string NEWS_CONTENT { get; set; }
        public string NEWS_IMG_FILE_PATH { get; set; }
        public bool IS_ACTIVE { get; set; }
        public bool IS_NOTIFY_USER { get; set; }
        public int TotalCount { get; set; }
        public DateTime CREATED_DATE { get; set; }
        public DateTime PUBLISHED_DATE { get; set; }
        public int CREATED_BY { get; set; }
        public Guid FileId { get; set; }
        public string FileName { get; set; }
        public string FileExtension { get; set; }

        public virtual ICollection<FileDetail> FileDetails { get; set; }

        #region :: Constructor ::
        public NewsViewModel()
        {
            this.ID = -99;
            this.APPLICATION_ID = -99;
            this.NEWS_TITLE = string.Empty;
            this.NEWS_CONTENT = string.Empty;
            this.NEWS_IMG_FILE_PATH = string.Empty;
            this.IS_ACTIVE = false;
            this.IS_NOTIFY_USER = false;
            this.TotalCount = -99;
            this.CREATED_BY = -99;
            this.FileName = string.Empty;
            this.FileExtension = string.Empty;
            this.PUBLISHED_DATE = DateTime.MinValue;
            //this.FileId = string.Empty;
        } 
        #endregion
    }
}
