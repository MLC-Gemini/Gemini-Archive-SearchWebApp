﻿using GeminiSearchWebApp.Models;
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
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
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

            viewBag.emptySearch = configuration["Appsettings:emptySearch"];
            viewBag.emptySearchLevel = configuration["Appsettings:emptySearchLevel"];
            viewBag.emptySearchPid = configuration["Appsettings:emptySearchPid"];
            viewBag.emptyDateRange = configuration["Appsettings:emptyDateRange"];
            viewBag.fromDateGreaterThanToDate = configuration["Appsettings:fromDateGreaterThanToDate"];
            viewBag.emptyCaseTypeDate = configuration["Appsettings:emptyCaseTypeDate"];
            viewBag.rightClick = configuration["Appsettings:rightClick"];

            return View();
        }
    }
}
