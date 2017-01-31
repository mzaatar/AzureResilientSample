using System;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Http;
using Serilog;
using System.Configuration;

namespace WinningCards
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            RouteConfig.RegisterRoutes(RouteTable.Routes);


            var connectionString = ConfigurationManager.ConnectionStrings["seqmssql"].ConnectionString;
            var tableName = "Logs";

            var log = new LoggerConfiguration()
                .WriteTo.MSSqlServer(connectionString, tableName)
                .CreateLogger();
        }
    }
}