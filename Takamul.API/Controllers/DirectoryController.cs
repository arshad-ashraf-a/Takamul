using MommyAndMe.API.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Http.Cors;

namespace MommyAndMe.API.Controllers
{
    public class DirectoryController : ApiController
    {
        // GET: api/GetAllDirectories
        [HttpGet]
        [EnableCors(origins: "http://188.135.13.152", headers: "*", methods: "*")]
        #region GetAllDirectories
        public HttpResponseMessage GetAllDirectories()
        {
            MommyAndMe.DAL.Directories oDirectories = new DAL.Directories();

           var dataTable = oDirectories.dtGetAllDirectories();

            var itemdfdfs = GetTopLevelRows(dataTable)
                            .Select(row => CreateItem(dataTable, row))
                            .OrderBy(row => row.Name)
                            .ToList();

            var formatter = new JsonMediaTypeFormatter();
            var json = formatter.SerializerSettings;

            json.DateFormatHandling = Newtonsoft.Json.DateFormatHandling.MicrosoftDateFormat;
            json.DateTimeZoneHandling = Newtonsoft.Json.DateTimeZoneHandling.Utc;
            json.NullValueHandling = Newtonsoft.Json.NullValueHandling.Ignore;
            json.Formatting = Newtonsoft.Json.Formatting.Indented;
            json.ContractResolver = new CamelCasePropertyNamesContractResolver();
            json.Culture = new CultureInfo("en-US");

            return Request.CreateResponse(HttpStatusCode.OK, itemdfdfs, formatter);
        }
        #endregion

        #region :: Helper Methods ::

        #region GetChildren
        public IEnumerable<DataRow> GetChildren(DataTable dataTable, Int32 parentId)
        {
            return dataTable
              .Rows
              .Cast<DataRow>()
              .Where(row => row.Field<int>("Parent_ID") == parentId);
        }
        #endregion

        #region CreateItem
        public Directory CreateItem(DataTable dataTable, DataRow row)
        {
            var id = row.Field<int>("Directory_ID");
            var parent = row.Field<int>("Parent_ID");
            var name = row.Field<string>("Directory_Name");
            var descripton = row.Field<string>("Descripton");
            var icon = row.Field<string>("Icon");
            var email = row.Field<string>("Email");
            var phoneNumber = row.Field<string>("Phone_Number");
            var webSite = row.Field<string>("WebSite");
            var facebook = row.Field<string>("Facebook");
            var instagram = row.Field<string>("Instagram");
            var latitude = row.Field<string>("Latitude");
            var longitude = row.Field<string>("Longitude");
            var children = GetChildren(dataTable, id)
                           .Select(r => CreateItem(dataTable, r))
                           .OrderBy(r => r.Name)
                           .ToList();

            return new Directory
            {
                ID = id,
                Parent = parent,
                Icon = icon,
                Description = descripton,
                Name = name,
                Email = email,
                PhoneNumber = phoneNumber,
                WebSite = webSite,
                Facebook = facebook,
                Instagram = instagram,
                Latitude = latitude,
                Longitude = longitude,
                Children = children
            };
        }
        #endregion

        #region GetTopLevelRows
        IEnumerable<DataRow> GetTopLevelRows(DataTable dataTable)
        {
            return dataTable
              .Rows
              .Cast<DataRow>()
              .Where(row => row.Field<int>("Parent_ID") == 0);
        }
        #endregion 

        #endregion
    }

   

}
