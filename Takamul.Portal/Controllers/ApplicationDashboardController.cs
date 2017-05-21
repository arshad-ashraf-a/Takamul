using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Models.ViewModel;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class ApplicationDashboardController : DomainController
    {
        #region ::  State ::
        #region Private Members
        private IApplicationService oIApplicationService;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// ApplicationDashboardController Constructor 
        /// </summary>
        /// <param name="oIApplicationServiceInitializer"></param>
        public ApplicationDashboardController(IApplicationService oIApplicationServiceInitializer)
        {
            this.oIApplicationService = oIApplicationServiceInitializer;
        }
        #endregion

        #region :: Behaviour ::

        #region View :: AppDashboard
        public ActionResult AppDashboard()
        {
            this.TitleHead = "Application DashBoard";
           
          
            ApplicationViewModel oApplicationViewModel = this.oIApplicationService.oGetApplicationStatistics(this.CurrentApplicationID);
            this.CurrentApplicationName = oApplicationViewModel.APPLICATION_NAME;
            return View(oApplicationViewModel);
        }
        #endregion

        #endregion
    }
}