using Amazon;
using Amazon.Extensions.NETCore.Setup;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace GeminiSearchWebApp
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
           
        }
        //public static IWebHostBuilder CreateHostBuilder(string[] args) =>
        //    WebHost.CreateDefaultBuilder(args)
        //        .ConfigureAppConfiguration(webBuilder =>
        //        {
        //            webBuilder.AddSystemsManager("/GeminiSearchWebApp", new AWSOptions {
        //                Region = RegionEndpoint.APSoutheast2
        //            });
        //        }).UseStartup<Startup>();

        //public static IWebHostBuilder CreateHostBuilder(string[] args) =>
        //    WebHost.CreateDefaultBuilder(args)
        //        .ConfigureAppConfiguration(webBuilder =>
        //        {
        //            webBuilder.AddSystemsManager(configureSource =>
        //            {
        //                configureSource.Path = "/GeminiSearchWebApp";
        //                configureSource.ReloadAfter = TimeSpan.FromMinutes(5);
        //                    //configureSource.AwsOptions = awsOptions;
        //                    configureSource.Optional = true;
        //                    //configureSource.OnLoadException += exceptionContext =>
        //                    //  {

        //                    //  };
        //                    //configureSource.ParameterProcessor = customerProcess;
        //                }
        //            );
        //        }).UseStartup<Startup>();

        //public static IWebHostBuilder CreateHostBuilder(string[] args) =>
        //    WebHost.CreateDefaultBuilder(args)
        //        .ConfigureAppConfiguration(webBuilder =>
        //        {
        //            webBuilder.AddSystemsManager("/GeminiSearchWebApp");
        //        }).UseStartup<Startup>();

        //public static IConfiguration Configuration { get; } = new ConfigurationBuilder()
        //.SetBasePath(Directory.GetCurrentDirectory())
        //.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
        //.AddJsonFile($"appsettings.{Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development"}.json", optional: true)
        //.Build();

        public static IHostBuilder CreateHostBuilder(string[] args) =>
              Host.CreateDefaultBuilder(args).UseSystemd()
         .ConfigureWebHostDefaults(webBuilder =>
         {
             webBuilder.UseStartup<Startup>();
         });


    }
}
