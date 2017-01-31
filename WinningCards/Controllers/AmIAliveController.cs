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
            return new string[] { "value1", "value2" };
        }

        // GET: api/AmIAlive/5
        public string Get(int id)
        {
            Global.Logger.Debug($"Get Method with id {id}");
            return "value";
        }

        // POST: api/AmIAlive
        public void Post([FromBody]string value)
        {
        }

        // PUT: api/AmIAlive/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE: api/AmIAlive/5
        public void Delete(int id)
        {
        }
    }
}
