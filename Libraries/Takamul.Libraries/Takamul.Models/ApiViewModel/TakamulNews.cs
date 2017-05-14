/****************************************************************************************************/
/* Class Name           : TakamulNews.cs                                                            */
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

namespace Takamul.Models.ApiViewModel
{
    public class TakamulNews
    {
        public int NewsID { get; set; }
        public int ApplicationID { get; set; }
        public string NewsTitle { get; set; }
        public string NewsContent { get; set; }
        public string Base64NewsImage { get; set; }
        public DateTime PublishedDate { get; set; }

        #region :: Constructor ::
        public TakamulNews()
        {
            this.NewsID = -99;
            this.ApplicationID = -99;
            this.NewsTitle = string.Empty;
            this.NewsContent = string.Empty;
            this.Base64NewsImage = string.Empty;
            this.PublishedDate = DateTime.MinValue;
        } 
        #endregion
    }
}
