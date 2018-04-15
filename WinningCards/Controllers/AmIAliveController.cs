using System;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Results;
using WinningCards.Models;

namespace WinningCards.Controllers
{
    public class AmIAliveController : ApiController
    {
        // GET: api/AmIAlive
        public IHttpActionResult Get()
        {
            try
            {
                using (var sqlCon = Config.DbServerConnection)
                {
                    sqlCon.Open();
                    sqlCon.Close();
                }

                Global.Logger.Debug("Get Method");
                return Ok( new { message = "I'm alive, what about you?" });
            }
            catch(Exception ex)
            {
                Global.Logger.Error($"Exception: {ex.Message}");
                return new ResponseMessageResult( new HttpResponseMessage( HttpStatusCode.InternalServerError)); // new string[] { "Error, please check the logs" };
            }
        }

        // GET: api/AmIAlive/5
        public string Get(int id)
        {
            Global.Logger.Debug($"Get Method called with id {id}");
            return id.ToString();
        }
    }
}
