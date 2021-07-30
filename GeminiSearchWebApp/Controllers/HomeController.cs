using GeminiSearchWebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

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
        public IActionResult searchCases()
        {
            ViewData["Message"] = "Your Search Page";
            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
            var configuration = builder.Build();

            ViewBag.emptySearch = configuration["Appsettings:emptySearch"];
            ViewBag.emptySearchLevel = configuration["Appsettings:emptySearchLevel"];
            ViewBag.emptySearchPid = configuration["Appsettings:emptySearchPid"];
            ViewBag.emptyAccountID = configuration["Appsettings:emptyAccountId"];
            ViewBag.emptyAdviserID = configuration["Appsettings:emptyAdviserId"];
            ViewBag.emptyCustomerId = configuration["Appsettings:emptyCustomerId"];
            ViewBag.emptyDateRange = configuration["Appsettings:emptyDateRange"];
            ViewBag.fromDateGreaterThanToDate = configuration["Appsettings:fromDateGreaterThanToDate"];
            ViewBag.emptyCaseTypeDate = configuration["Appsettings:emptyCaseTypeDate"];
            ViewBag.rightClick = configuration["Appsettings:rightClick"];

            return View();
        }
    }
}
