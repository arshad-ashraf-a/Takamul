using Infrastructure.Core;
using Infrastructure.Utilities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class CommonController : BaseController
    {
        #region ::  State ::
        #region Private Members
        private ICommonServices oICommonServices;
        private ILookupServices oILookupServices;
        private IUserServices oIUserServices;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// UsersController Constructor 
        /// </summary>
        /// <param name="oICommonServicesInitializer"></param>
        public CommonController(
                                IUserServices oIUserServicesInitializer,
                                ICommonServices oICommonServicesInitializer,
                                ILookupServices oILookupServicesInitializer
            )
        {
            this.oIUserServices = oIUserServicesInitializer;
            this.oICommonServices = oICommonServicesInitializer;
            this.oILookupServices = oILookupServicesInitializer;
        }
        #endregion

        #region :: Behaviour ::


        #endregion

        #region ::  Methods ::

        #region Method :: JsonResult :: JGetAllTicketStatus
        /// <summary>
        /// Get all ticket status
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllTicketStatus()
        {
            var lstTicketStatus = this.oILookupServices.lGetAllTicketStatus();
            return Json(lstTicketStatus, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: JGetAllAreas
        /// <summary>
        /// Get all areas list
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllAreas()
        {
            var lstAreas = this.oICommonServices.oGetAllAreas();
            return Json(lstAreas, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: JGetAllWilayat
        /// <summary>
        /// Get all wilayat list
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllWilayat(string sAreaCode)
        {
            var lstWilayats = this.oICommonServices.oGetAllWilayats(sAreaCode);
            return Json(lstWilayats, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: JGetAllVillages
        /// <summary>
        /// Get all village list
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllVillages(string sAreaCode,string sWilayatCode)
        {
            var lstVillages = this.oICommonServices.oGetAllVillages(sAreaCode,sWilayatCode);
            return Json(lstVillages, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: JGetAllMemberUsers
        /// <summary>
        /// Get all member users
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JGetAllMemberUsers()
        {
            var lstMemberUsers = this.oIUserServices.lGetAllMembers(string.Empty, 1, int.MaxValue);
            return Json(lstMemberUsers, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #endregion
    }
}