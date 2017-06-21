/****************************************************************************************************/
/* Class Name           : HomPageRepo.cs                                                            */
/* Designed BY          : Arshad Ashraf                                                             */
/* Created BY           : Arshad Ashraf                                                             */
/* Creation Date        : 31.03.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/* Description          : used for hold of home page data                                          */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ApiViewModel
{
    public class HomePageRepo
    {
        public List<TakamulNews> TakamulNewsList { get; set; }
        public List<TakamulEvents> TakamulEventList { get; set; }
        public List<TakamulTicket> TakamulTicketList { get; set; }

        #region :: Constructor ::
        public HomePageRepo()
        {
            this.TakamulNewsList = new List<TakamulNews>();
            this.TakamulEventList = new List<TakamulEvents>();
            this.TakamulTicketList = new List<TakamulTicket>();
        }
        #endregion
    }
}
