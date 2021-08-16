using GeminiSearchWebApp.DAL;
using GeminiSearchWebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using Gemini.Models;
using System.Data.SqlClient;
using System.Collections.Generic;
using Newtonsoft.Json;
using System.Globalization;

namespace GeminiSearchWebApp.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        private IConfiguration configuration;
        
        //private readonly ILogger<HomeController> _logger;

        //public HomeController(ILogger<HomeController> logger)
        //{
        //    _logger = logger;
        //}
        public HomeController(IConfiguration _configuration)
        {
            configuration = _configuration;
        }

        public IActionResult Index()
        {
            var lstClaim = User.Claims.ToList();
            //if(User.IsInRole("Users"))
            //{
            //    Content("i belongs to admin");
            //}
            return View();
        }
        public IActionResult About()
        {
            ViewData["Message"] = "Your application description page.";

            return View();
        }

        public IActionResult Contact()
        {
            ViewData["Message"] = "Your contact page.";

            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        public IActionResult SearchCases()
        {
            ViewData["Message"] = "Your Search Page";
            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
            var config = builder.Build();

            ViewBag.emptySearch = config["Appsettings:emptySearch"];
            ViewBag.emptySearchLevel = config["Appsettings:emptySearchLevel"];
            ViewBag.emptySearchPid = config["Appsettings:emptySearchPid"];
            ViewBag.emptyAccountID = config["Appsettings:emptyAccountId"];
            ViewBag.emptyAdviserID = config["Appsettings:emptyAdviserId"];
            ViewBag.emptyCustomerId = config["Appsettings:emptyCustomerId"];
            ViewBag.emptyDateRange = config["Appsettings:emptyDateRange"];
            ViewBag.fromDateGreaterThanToDate = config["Appsettings:fromDateGreaterThanToDate"];
            ViewBag.emptyCaseTypeDate = config["Appsettings:emptyCaseTypeDate"];
            ViewBag.rightClick = config["Appsettings:rightClick"];
            return View();
        }

       
        public string GetSearchDoc(string fLevel, string uId, string fDate, string tDate, string caseType)
        {
            DataTable dt = new DataTable();
            string format;
            format = "dd/MM/yyyy";
            CultureInfo provider = CultureInfo.InvariantCulture;

            try
            {
                UserInput userInput = new UserInput();
                userInput.FilterLevel = fLevel;
                userInput.UserId = uId;
                if (fDate == null || tDate == null)
                {
                    userInput.FromDate = DateTime.MinValue;
                    userInput.ToDate = DateTime.MinValue;
                }
                else
                {
                    userInput.FromDate = DateTime.ParseExact(fDate, format, provider);
                    userInput.ToDate = DateTime.ParseExact(tDate, format, provider);
                }
                userInput.CaseTypeDate = caseType;
                ConnectionClass connectionClass = new ConnectionClass(configuration);
                dt = connectionClass.Getrecord(userInput);
               
            }
            catch (Exception)
            {

                Console.WriteLine("error");
            }

           return DataTableToJSONWithJSONNet(dt);

        }

        public string DataTableToJSONWithJSONNet(DataTable table)
        {
            string JSONString = string.Empty;
            JSONString = JsonConvert.SerializeObject(table);
            return JSONString;
        }



        public string GetCasesRecord(string filterLevel, string userId, string fromDate, string toDate, string caseDateType)
        {
            DataTable dt = new DataTable();
            string format;
            format = "dd/MM/yyyy";
            CultureInfo provider = CultureInfo.InvariantCulture;

            try
            {
                UserInput userInput = new UserInput();
                userInput.FilterLevel = filterLevel;
                userInput.UserId = userId;
                if (fromDate==null || toDate==null)
                {
                    userInput.FromDate = DateTime.MinValue;
                    userInput.ToDate = DateTime.MinValue;
                }
                else
                {
                    userInput.FromDate = DateTime.ParseExact(fromDate, format, provider);
                    userInput.ToDate = DateTime.ParseExact(toDate, format, provider);
                }
                userInput.CaseTypeDate = caseDateType;
                ConnectionClass connectionClass = new ConnectionClass(configuration);
                dt = connectionClass.GetCasesRecord(userInput);

            }
            catch (Exception)
            {

                Console.WriteLine("error");
            }

            return CasesToJson(dt);

        }

        public string CasesToJson(DataTable table)
        {
            string JSONString = string.Empty;
            JSONString = JsonConvert.SerializeObject(table);
            return JSONString;
        }


    }
}
