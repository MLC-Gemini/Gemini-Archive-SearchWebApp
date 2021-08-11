using Microsoft.Extensions.Configuration;
using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace GeminiSearchWebApp
{
    public class geminiLogger
    {
        private static void CreateAppLogger()
        {
            try
            {
                var config = new ConfigurationBuilder().AddJsonFile("appsettings.json").Build();
                Log.Logger = new LoggerConfiguration().ReadFrom.Configuration(config).CreateLogger();
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }
    }
}
