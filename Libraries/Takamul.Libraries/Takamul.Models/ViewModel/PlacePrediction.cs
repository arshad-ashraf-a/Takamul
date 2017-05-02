using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Takamul.Models.ViewModel
{
    public class PlacePrediction
    {
        public string description { get; set; }
        public string id { get; set; }
        public string place_id { get; set; }
        public string reference { get; set; }
        public List<string> types { get; set; }
    }

    public class RootObject
    {
        public List<PlacePrediction> predictions { get; set; }
        public string status { get; set; }
    }

    public class Venue
    {
        #region Properties  
        public int Id { get; set; }
        public string Country { get; set; }
        public string CountryName { get; set; }
        public string City { get; set; }
        public float Latitude { get; set; }
        public float Longitude { get; set; }
        public string CountryCode { get; set; }
        #endregion
    }
}
