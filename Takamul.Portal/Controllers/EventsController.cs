using Infrastructure.Core;
using Infrastructure.Utilities;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Xml.Linq;
using Takamul.Models;
using Takamul.Models.ViewModel;
using Takamul.Portal.Resources.Common;
using Takamul.Services;

namespace LDC.eServices.Portal.Controllers
{
    public class EventsController : DomainController
    {
        #region ::  State ::
        #region Private Members
        private IEventService oIEventService;
        #endregion
        #endregion

        #region Constructor
        /// <summary>
        /// EventsController Constructor 
        /// </summary>
        /// <param name="oIEventServiceInitializer"></param>
        public EventsController(IEventService oIEventServiceInitializer)
        {
            this.oIEventService = oIEventServiceInitializer;
        }
        #endregion

        #region :: Behaviour ::

        #region View :: EventsList
        public ActionResult EventsList()
        {
            this.PageTitle = "Events List";
            this.TitleHead = "Events List";

            return View();
        }
        #endregion

        #region View :: AddNewEvent
        public ActionResult AddNewEvent()
        {
            this.PageTitle = "Add Event";
            this.TitleHead = "Add Event";

            EventViewModel oEventViewModel = new EventViewModel();
            oEventViewModel.EVENT_DATE = DateTime.Now;
            return View("_AddNewEvent",oEventViewModel);
        }
        #endregion

        #region View :: EditEvent
        public ActionResult EditEvent(int nEventID)
        {
            EventViewModel oEventViewModel = this.oIEventService.oGetEventDetails(nEventID);
            this.PageTitle = "Edit Event";
            this.TitleHead = "Edit Event";
            return View("_EditEvent", oEventViewModel);
        }
        #endregion

        #endregion

        #region ::  Methods ::

        #region JsonResult :: Bind Grid All Events
        /// <summary>
        /// Bind all application events
        /// </summary>
        /// <param name="sSearchByEventName"></param>
        /// <param name="nPage"></param>
        /// <param name="nRows"></param>
        /// <param name="sColumnName"></param>
        /// <param name="sColumnOrder"></param>
        /// <returns></returns>
        public JsonResult JBindAllEvents(string sSearchByEventName, int nPage, int nRows, string sColumnName, string sColumnOrder)
        {
            var lstEvents = this.oIEventService.IlGetAllEvents(CurrentApplicationID,sSearchByEventName, nPage, nRows, sColumnName, sColumnOrder);
            return Json(lstEvents, JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region JsonResult :: JGetEventVenuesList
        /// <summary>  
        /// This method is used to get the place list  
        /// </summary>  
        /// <param name="SearchText"></param>  
        /// <returns></returns>  
        [HttpGet, ActionName("JGetEventVenuesList")]
        public JsonResult JGetEventVenuesList(string SearchText)
        {
            string placeApiUrl = CommonHelper.sGetConfigKeyValue(ConstantNames.GooglePlaceAPIUrl);

            try
            {
                placeApiUrl = placeApiUrl.Replace("{0}", SearchText);
                placeApiUrl = placeApiUrl.Replace("{1}", CommonHelper.sGetConfigKeyValue(ConstantNames.TakamulGoogleMapApIKey));

                var result = new System.Net.WebClient().DownloadString(placeApiUrl);
                var Jsonobject = JsonConvert.DeserializeObject<RootObject>(result);

                List<PlacePrediction> list = Jsonobject.predictions;

                return Json(list, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(ex.Message, JsonRequestBehavior.AllowGet);
            }
        }
        #endregion

        #region JsonResult :: GetVenueDetailsByPlace
        /// <summary>  
        /// This method is used to get place details on the basis of PlaceID  
        /// </summary>  
        /// <param name="placeId"></param>  
        /// <returns></returns>  
        [HttpGet, ActionName("GetVenueDetailsByPlace")]
        public JsonResult GetVenueDetailsByPlace(string placeId)
        {
            string placeDetailsApi = CommonHelper.sGetConfigKeyValue(ConstantNames.GooglePlaceDetailsAPIUrl);
            try
            {
                Venue ven = new Venue();
                placeDetailsApi = placeDetailsApi.Replace("{0}", placeId);
                placeDetailsApi = placeDetailsApi.Replace("{1}", CommonHelper.sGetConfigKeyValue(ConstantNames.TakamulGoogleMapApIKey));

                var result = new System.Net.WebClient().DownloadString(placeDetailsApi);

                var xmlElm = XElement.Parse(result);
                ven = GetAllVenueDetails(xmlElm);

                return Json(ven, JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                return Json(ex.Message, JsonRequestBehavior.AllowGet);
            }
        }
        #endregion

        #region Venue :: GetAllVenueDetails
        /// <summary>  
        /// This method is creted to get the place details from xml  
        /// </summary>  
        /// <param name="xmlElm"></param>  
        /// <returns></returns>  
        private Venue GetAllVenueDetails(XElement xmlElm)
        {
            Venue ven = new Venue();
            List<string> c = new List<string>();
            List<string> d = new List<string>();
            //get the status of download xml file  
            var status = (from elm in xmlElm.Descendants()
                          where
                              elm.Name == "status"
                          select elm).FirstOrDefault();

            //if download xml file status is ok  
            if (status.Value.ToLower() == "ok")
            {

                //get the address_component element  
                var addressResult = (from elm in xmlElm.Descendants()
                                     where
                                         elm.Name == "address_component"
                                     select elm);
                //get the location element  
                var locationResult = (from elm in xmlElm.Descendants()
                                      where
                                          elm.Name == "location"
                                      select elm);

                foreach (XElement item in locationResult)
                {
                    ven.Latitude = float.Parse(item.Elements().Where(e => e.Name.LocalName == "lat").FirstOrDefault().Value);
                    ven.Longitude = float.Parse(item.Elements().Where(e => e.Name.LocalName == "lng").FirstOrDefault().Value);
                }
                //loop through for each address_component  
                foreach (XElement element in addressResult)
                {
                    string type = element.Elements().Where(e => e.Name.LocalName == "type").FirstOrDefault().Value;

                    if (type.ToLower().Trim() == "locality") //if type is locality the get the locality  
                    {
                        ven.City = element.Elements().Where(e => e.Name.LocalName == "long_name").Single().Value;
                    }
                    else
                    {
                        if (type.ToLower().Trim() == "administrative_area_level_2" && string.IsNullOrEmpty(ven.City))
                        {
                            ven.City = element.Elements().Where(e => e.Name.LocalName == "long_name").Single().Value;
                        }
                    }
                    if (type.ToLower().Trim() == "country") //if type is locality the get the locality  
                    {
                        ven.Country = element.Elements().Where(e => e.Name.LocalName == "long_name").Single().Value;
                        ven.CountryCode = element.Elements().Where(e => e.Name.LocalName == "short_name").Single().Value;
                        if (ven.Country == "United States") { ven.Country = "USA"; }
                    }
                }
            }
            xmlElm.RemoveAll();
            return ven;
        }
        #endregion

        #region Method :: JsonResult :: Save event
        /// <summary>
        /// Save event
        /// </summary>
        /// <param name="oEventViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JSaveEvent(EventViewModel oEventViewModel)
        {
            Response oResponseResult = null;
            string sRealFileName = string.Empty;
            string sModifiedFileName = string.Empty;
            HttpPostedFileBase filebase = null;
            var oFile = System.Web.HttpContext.Current.Request.Files["EventImage"];
            if (oFile != null)
            {
                filebase = new HttpPostedFileWrapper(oFile);
                if (filebase.ContentLength > 0)
                {
                    sRealFileName = filebase.FileName;
                    sModifiedFileName = CommonHelper.AppendTimeStamp(filebase.FileName);
                    oEventViewModel.EVENT_IMG_FILE_PATH = Path.Combine(this.CurrentApplicationID.ToString(), "Events", sModifiedFileName).Replace('\\', '/');
                }
            }

            oEventViewModel.CREATED_BY = Convert.ToInt32(CurrentUser.nUserID);
            oEventViewModel.APPLICATION_ID = CurrentApplicationID;

            oResponseResult = this.oIEventService.oInsertEvent(oEventViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    if (oFile != null)
                    {
                        FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));

                        //DirectoryPath = Saved Application ID + Evemts Folder
                        string sDirectoryPath = Path.Combine(this.CurrentApplicationID.ToString(), "Events");
                        string sFullFilePath = Path.Combine(sDirectoryPath, sModifiedFileName);
                        oFileAccessService.CreateDirectory(sDirectoryPath);
                        byte[] fileData = null;
                        using (var binaryReader = new BinaryReader(filebase.InputStream))
                        {
                            fileData = binaryReader.ReadBytes(filebase.ContentLength);
                        }
                        oFileAccessService.WirteFileByte(sFullFilePath, fileData);
                    }
                    this.OperationResultMessages = CommonResx.MessageAddSuccess;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageAddFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Edit event
        /// <summary>
        /// Save event
        /// </summary>
        /// <param name="oEventViewModel"></param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken()]
        public JsonResult JEditEvent(EventViewModel oEventViewModel)
        {
            Response oResponseResult = null;
            string sRealFileName = string.Empty;
            string sModifiedFileName = string.Empty;
            HttpPostedFileBase filebase = null;
            var oFile = System.Web.HttpContext.Current.Request.Files["EventImage"];
            if (oFile != null)
            {
                filebase = new HttpPostedFileWrapper(oFile);
                if (filebase.ContentLength > 0)
                {
                    sRealFileName = filebase.FileName;
                    sModifiedFileName = CommonHelper.AppendTimeStamp(filebase.FileName);
                    oEventViewModel.EVENT_IMG_FILE_PATH = Path.Combine(this.CurrentApplicationID.ToString(), "Events", sModifiedFileName).Replace('\\', '/');
                }
            }
            oEventViewModel.CREATED_BY = Convert.ToInt32(CurrentUser.nUserID);
            oEventViewModel.APPLICATION_ID = CurrentApplicationID;

            oResponseResult = this.oIEventService.oUpdateEvent(oEventViewModel);
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    if (oFile != null)
                    {
                        FileAccessService oFileAccessService = new FileAccessService(CommonHelper.sGetConfigKeyValue(ConstantNames.FileAccessURL));

                        //DirectoryPath = Saved Application ID + Evemts Folder
                        string sDirectoryPath = Path.Combine(this.CurrentApplicationID.ToString(), "Events");
                        string sFullFilePath = Path.Combine(sDirectoryPath, sModifiedFileName);
                        oFileAccessService.CreateDirectory(sDirectoryPath);
                        byte[] fileData = null;
                        using (var binaryReader = new BinaryReader(filebase.InputStream))
                        {
                            fileData = binaryReader.ReadBytes(filebase.ContentLength);
                        }
                        oFileAccessService.WirteFileByte(sFullFilePath, fileData);
                    }
                    this.OperationResultMessages = CommonResx.MessageAddSuccess;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageAddFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #region Method :: JsonResult :: Delete Event
        /// <summary>
        ///  Delete event
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult JDeleteEvent(string ID)
        {
            Response oResponseResult = null;

            oResponseResult = this.oIEventService.oDeleteEvent(Convert.ToInt32(ID));
            this.OperationResult = oResponseResult.OperationResult;

            switch (this.OperationResult)
            {
                case enumOperationResult.Success:
                    this.OperationResultMessages = CommonResx.MessageDeleteSuccess;
                    break;
                case enumOperationResult.Faild:
                    this.OperationResultMessages = CommonResx.MessageDeleteFailed;
                    break;
            }
            return Json(
                new
                {
                    nResult = this.OperationResult,
                    sResultMessages = this.OperationResultMessages
                },
                JsonRequestBehavior.AllowGet);
        }
        #endregion

        #endregion



    }
}