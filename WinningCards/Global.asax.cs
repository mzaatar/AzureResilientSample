﻿using System;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Http;
using Serilog;
using Serilog.Core;
using WinningCards.Models;

namespace WinningCards
{
    public class Global : HttpApplication
    {
        public static Logger Logger;
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            RouteConfig.RegisterRoutes(RouteTable.Routes);

            var connectionString = Config.DefaultConenctionString;
            var tableName = "Logs";

            Logger = new LoggerConfiguration()
                .MinimumLevel.Verbose()
                .WriteTo.MSSqlServer(connectionString, tableName, autoCreateSqlTable: true)
                .CreateLogger();
        }
    }
}