/****************************************************************************************************/
/* Class Name           : About.cs                                                            */
/* Designed BY          : Samh Khalid                                                             */
/* Created BY           : Samh Khalid                                                               */
/* Creation Date        : 06.17.2017                                                                */
/* Modified BY          : -                                                                         */
/* Last Modified Date   : -                                                                         */
/*                                               */
/****************************************************************************************************/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ApiViewModel
{
   public class About
    {
        public string Title { get; set; }
        public string Content { get; set; }
        public string Howitworks { get; set; }
        public string InstallationInstruction { get; set; }
        public string FAQ { get; set; }
        public string AppGuide { get; set; }
        public string Privacyandpolicies { get; set; }
        public string Termsandcondition { get; set; }
        public string InformationSecurity { get; set; }

        public About()
        {
            this.Title = string.Empty;
            this.Howitworks = string.Empty;
            this.InstallationInstruction = string.Empty;
            this.FAQ = string.Empty;
            this.AppGuide = string.Empty;
            this.Privacyandpolicies = string.Empty;
            this.Termsandcondition = string.Empty;
            this.InformationSecurity = string.Empty;
        }
    } 
}
