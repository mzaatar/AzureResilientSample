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

                Global.Logger.Debug($"Am I Alive Ctrl - {Config.AppEnvironment}");
                return Ok( new { message = "I'm alive, what about you?" });
            }
            catch(Exception ex)
            {
                Global.Logger.Error($"Exception: {Config.AppEnvironment} {ex.Message}");
                return new ResponseMessageResult( new HttpResponseMessage( HttpStatusCode.InternalServerError)); // new string[] { "Error, please check the logs" };
            }
        }
    }
}
