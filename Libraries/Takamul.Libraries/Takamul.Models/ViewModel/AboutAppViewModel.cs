using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
   public class AboutAppViewModel
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

        public AboutAppViewModel()
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
