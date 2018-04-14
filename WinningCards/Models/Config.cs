using System;
using System.Configuration;
using System.Data.SqlClient;

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

        public static string DefaultConenctionString
        {
            get { return ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString; }
        }

        public static SqlConnection DbServerConnection
        {
            get
            {
                var connectString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ToString();
                SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connectString);
                return new SqlConnection(builder.ConnectionString);
            }
        }

        public static string DbServer
        {
            get
            {
                var connectString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ToString();
                SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connectString);
                return builder.DataSource;
            }
        }

        public static string DbName
        {
            get {
                var connectString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ToString();
                SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder(connectString);
                return builder.InitialCatalog;
            }
        }
    }
}