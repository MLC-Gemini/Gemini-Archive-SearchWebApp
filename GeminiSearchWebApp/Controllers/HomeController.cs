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
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Text;
using System.Globalization;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace GeminiSearchWebApp.Controllers
{
   
    public class HomeController : Controller
    {
        private IConfiguration configuration;
        private ConnectionClass connectionClass;
        public LdapConnect ldapConnect;
        public string loggedInUserName { get; set; }
        public HomeController(IConfiguration _configuration)
        {
           
            configuration = _configuration;
            connectionClass = new ConnectionClass(configuration);
            ldapConnect = new LdapConnect(_configuration);
        }
        public IActionResult Index()
        {
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

        public IActionResult Login()
        {
            ViewData["Message"] = "Your login page.";
            return View();
        }

        public string ValidateLogin(string userName, string password)
        {
            loggedInUserName = ldapConnect.ValidateUsernameAndPassword(userName, password, "AURDEV");
            if (!string.IsNullOrEmpty(loggedInUserName))
            {
                return loginUserNameToJson(loggedInUserName);
            }
            return null;
        }

        public string loginUserNameToJson(string name)
        {
            string JSONString = string.Empty;
            JSONString = JsonConvert.SerializeObject(name);
            return JSONString;
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
        //public IActionResult Login()
        //{
        //    ViewData["Message"] = "Your login page.";

        //    return View();
        //}

       
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
                if (fLevel!=null && uId!=null && caseType!=null)
                {
                    userInput.FilterLevel = fLevel;
                    userInput.UserId = uId;
                    userInput.CaseTypeDate = caseType;
                }
                else
                {
                    connectionClass.CreateMessageLog("HomeController GetSearchDoc method variables are null");
                }
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
                dt = connectionClass.Getrecord(userInput);
               
            }
            catch (Exception ex)
            {
                connectionClass.CreateMessageLog(ex.Message);
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
                if (filterLevel!=null && User!=null && caseDateType!=null)
                {
                    userInput.FilterLevel = filterLevel;
                    userInput.UserId = userId;
                    userInput.CaseTypeDate = caseDateType;
                }
                else
                {
                    connectionClass.CreateMessageLog("HomeController GetCasesRecord method variables are null");
                }
                
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
                dt = connectionClass.GetCasesRecord(userInput);

            }
            catch (Exception ex)
            {
                connectionClass.CreateMessageLog(ex.Message);
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


        public string GetActionRecord(int selectedCaseId)
        {
            DataTable dt = new DataTable();
            if (selectedCaseId!=0)
            {
                try
                {
                    dt = connectionClass.GetActionRecord(selectedCaseId);

                }
                catch (Exception ex)
                {
                    connectionClass.CreateMessageLog(ex.Message);
                    Console.WriteLine("error");
                }
            }
            else
            {
                connectionClass.CreateMessageLog("CaseId passed to GetActionRecord method in HomeController is null");
            }

            return ActionToJson(dt);

        }

        public string ActionToJson(DataTable table)
        {
            string JSONString = string.Empty;
            JSONString = JsonConvert.SerializeObject(table);
            return JSONString;
        }

        public void ExceptionMessageFromView(string exView)
        {
            connectionClass.CreateMessageLog(exView);
        }

        // code for PI tower service call

        [HttpPost]
        public async Task<IActionResult> GetDoc(int id)
        {
            Documents documents = new Documents();

            using (var httpClient = new HttpClient())
            {
                // httpClient.DefaultRequestHeaders.Add("Key", "Secret@123");
                httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", "username:password");
                StringContent content = new StringContent(JsonConvert.SerializeObject(documents), Encoding.UTF8, "application/json");
                using (var response = await httpClient.GetAsync("" + id))
                {
                    if (response.StatusCode == System.Net.HttpStatusCode.OK)
                    {
                        string apiResponse = await response.Content.ReadAsStringAsync();
                        documents = JsonConvert.DeserializeObject<Documents>(apiResponse);
                    }
                    else
                        ViewBag.StatusCode = response.StatusCode;
                }
            }
            return View(documents);
        }





    }
}
