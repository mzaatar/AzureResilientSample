using System;
using System.Configuration;

namespace WinningCards.Models
{
    public class Config
    {
        public static string AppVersion
        {
            get { return ConfigurationManager.AppSettings["app.version"]; }
        }

        public static string AppEnvironment
        {
            get { return ConfigurationManager.AppSettings["app.environment"]; }
        }
        public static string AppMachineName
        {
            get { return Environment.MachineName; }
        }
    }
}