using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Takamul.API.Models;

namespace Takamul.API.Controllers
{
    public class MemberRegistrationController : ApiController
    {
        IList<Members> memebers = new List<Members>()
        {
            new Members()
                {
                    MemberID = 1, MemberUsername = "Samh ", Address = "New Delhi", MemberPassword = "123",AppId="787po"
                },
               new Members()
                {
                    MemberID = 2, MemberUsername = "Arshad ", Address = "Mumbai", MemberPassword = "123",AppId="745po"
                },
               new Members()
                {
                    MemberID = 3, MemberUsername = "Sulaiman ", Address = "Cochi", MemberPassword = "123",AppId="725po"
                },
                
        };

        public IList<Members> GetAllMembers()
        {
             
            return memebers;
        }
        public Members GetMemberDetails(int id)
        {
            //Return a single member detail  
            var members = memebers.FirstOrDefault(e => e.MemberID == id);
            if (members == null)
            {
                throw new HttpResponseException(Request.CreateResponse(HttpStatusCode.NotFound));
            }
            return members;
        }
    }
}
