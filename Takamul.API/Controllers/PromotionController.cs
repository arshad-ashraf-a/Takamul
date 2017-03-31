using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Http.Cors;

namespace MommyAndMe.API.Controllers
{
    public class PromotionController : ApiController
    {
        // GET: api/GetAllPromotions
        [HttpGet]
        [EnableCors(origins: "http://188.135.13.152", headers: "*", methods: "*")]
        #region GetAllPromotions
        public HttpResponseMessage GetAllPromotions()
        {
            MommyAndMe.DAL.Promotions oPromotions = new MommyAndMe.DAL.Promotions();
            oPromotions.IsActive = 1;
            MommyAndMe.DAL.Promotions[] oArrPromotions = oPromotions.oArrGetAllPromotions();
            
            List<MommyAndMe.API.Models.Promotions> oArrApiPromotions = new List<Models.Promotions>();
            if (oArrPromotions.Length > 0)
            {
                
                for (int index = 0; index < oArrPromotions.Length; index++)
                {
                    MommyAndMe.API.Models.Promotions oApiPromotions = new Models.Promotions();
                    oApiPromotions.PromotionID = oArrPromotions[index].PromotionID;
                    oApiPromotions.PromotionTitle = oArrPromotions[index].PromotionTitle;
                    oApiPromotions.PromotionDescription = oArrPromotions[index].PromotionDescription;
                    oApiPromotions.PromotionSite = oArrPromotions[index].PromotionSite;

                    oArrApiPromotions.Add(oApiPromotions);

                }
            }

            var formatter = new JsonMediaTypeFormatter();
            var json = formatter.SerializerSettings;
            json.DateFormatHandling = Newtonsoft.Json.DateFormatHandling.MicrosoftDateFormat;
            json.DateTimeZoneHandling = Newtonsoft.Json.DateTimeZoneHandling.Utc;
            json.NullValueHandling = Newtonsoft.Json.NullValueHandling.Ignore;
            json.Formatting = Newtonsoft.Json.Formatting.Indented;
            json.ContractResolver = new CamelCasePropertyNamesContractResolver();
            json.Culture = new CultureInfo("en-US");

            return Request.CreateResponse(HttpStatusCode.OK, oArrApiPromotions, formatter);
        }
        #endregion
    }
}
