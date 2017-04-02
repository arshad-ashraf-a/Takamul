using MommyAndMe.API.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Cors;

namespace MommyAndMe.API.Controllers
{
    public class ParticipantController : ApiController
    {
        // POST /api/InsertParticipant
        [HttpPut]
        [EnableCors(origins: "http://188.135.13.152", headers: "*", methods: "*")]
        public HttpResponseMessage InsertParticipant(Participants participants)
        {
            if (ModelState.IsValid)
            {

                try
                {
                    MommyAndMe.DAL.Participants oParticipants = new DAL.Participants();

                    oParticipants.BusinessName = participants.BusinessName;
                    oParticipants.ContactNumber = participants.ContactNumber;
                    oParticipants.Instagram = participants.Instagram;
                    oParticipants.Facebook = participants.Facebook;
                    oParticipants.ContactPersonInfo = participants.ContactPersonInfo;
                    oParticipants.Location = participants.Location;
                    oParticipants.WebSiteURL = participants.WebSiteURL;
                    oParticipants.BusinessBriefDesc = participants.BusinessBriefDesc;

                    oParticipants.InsertParticipant();

                    //Created!
                    return Request.CreateResponse(HttpStatusCode.Created, "Successfully inserted.");
                }
                catch (Exception)
                {
                    return Request.CreateResponse(HttpStatusCode.InternalServerError, "Insert failure.");
                }
            }
            throw new HttpResponseException(HttpStatusCode.BadRequest);
        }
    }
}
