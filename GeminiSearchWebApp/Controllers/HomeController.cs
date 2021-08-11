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


namespace GeminiSearchWebApp.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        List<Case> cases = new List<Case>();
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

       
        public string GetSearchDoc(string fLevel, string uId, DateTime fDate, DateTime tDate, string caseType)
        {
            DataSet ds = new DataSet();
            DataTable dt = new DataTable();
          
            try
            {
                UserInput userInput = new UserInput();
                userInput.FilterLevel = fLevel;
                userInput.UserId = uId;
                userInput.FromDate = fDate;
                userInput.ToDate = tDate;
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



        public string GetCasesRecord(string filterLevel, string userId, DateTime fromDate, DateTime toDate, string caseDateType)
        {
            DataSet ds = new DataSet();
            DataTable dt = new DataTable();

            try
            {
                UserInput userInput = new UserInput();
                userInput.FilterLevel = filterLevel;
                userInput.UserId = userId;
                userInput.FromDate = fromDate;
                userInput.ToDate = toDate;
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
