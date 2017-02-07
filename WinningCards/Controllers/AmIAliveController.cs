using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace WinningCards.Controllers
{
    public class AmIAliveController : ApiController
    {
        // GET: api/AmIAlive
        public IEnumerable<string> Get()
        {
            Global.Logger.Debug("Get Method");
            return new string[] { "I'm alive, what about you?"};
        }

        // GET: api/AmIAlive/5
        public string Get(int id)
        {
            Global.Logger.Debug($"Get Method called with id {id}");
            return id.ToString();
        }
    }
}
