using Gemini.Models;
using GeminiSearchWebApp.DAL;
using GeminiSearchWebApp.Models;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using System;
using System.Data;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Net;
using System.Xml;
using System.Threading.Tasks;

namespace GeminiSearchWebApp.Controllers
{

    public class HomeController : Controller
    {
        private IConfiguration configuration;
        private ConnectionClass connectionClass;
        public LdapConnect ldapConnect;
        public string loggedInUserName { get; set; }
        public static bool loginResult = false;
        private readonly IWebHostEnvironment _env;
        public HomeController(IConfiguration _configuration , IWebHostEnvironment env)
        {           
            configuration = _configuration;
            connectionClass = new ConnectionClass(configuration);
            ldapConnect = new LdapConnect(_configuration);
            _env = env;
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

        public IActionResult SearchLayout()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        public IActionResult Login()
        {
            ViewData["Message"] = "Your login page.";
            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
            var config = builder.Build();

            ViewBag.emptyLogin = config["Appsettings:emptyLogin"];
            ViewBag.emptyPwd = config["Appsettings:emptyPwd"];
            ViewBag.emptyCredentials = config["Appsettings:emptyCredentials"];
            return View();
        }

       

        public IActionResult LogOut()
        {
            loginResult = false;
            return RedirectToAction("Login");
        }

        public string ValidateLogin(string userName, string password)
        {
            string result = string.Empty;
            connectionClass.CreateLog(userName);
            try
            {
                var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
                var config = builder.Build();
                var domain = config["SecuritySettings:domain"];
                if (userName != null && password != null)
                {
                    loggedInUserName = ldapConnect.ValidateUsernameAndPassword(userName, password, domain);
                        if (!string.IsNullOrEmpty(loggedInUserName))
                        {
                            result = JsonConvert.SerializeObject(loggedInUserName);
                            return result;
                        }
                        else
                        {
                            result = null;
                            connectionClass.CreateMessageLog("Login Username is null");
                        }                    
                }
                else
                {
                    connectionClass.CreateMessageLog("Login Username or Password is null");
                }
            }
            catch (Exception ex)
            {
                connectionClass.CreateMessageLog(ex.Message);
            }
            return result;
        }
        public bool LoginCheck(bool loginStatus)
        {
            loginResult = loginStatus;
            bool result = false;
            try
            {
                if (loginStatus == true)
                {
                    loginResult = loginStatus;
                    return loginResult;
                }
                else
                {
                    result = false;
                    loginResult = result;
                }
            }
            catch (Exception ex)
            {
                connectionClass.CreateMessageLog(ex.Message);
            }
            return result;
        }

        public IActionResult SearchCases()
        {
            bool loginValue = loginResult;
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
            ViewBag.emptyFromDate = config["Appsettings:emptyFromDate"];
            ViewBag.emptyToDate = config["Appsettings:emptyToDate"];
            ViewBag.loginFinalStatus = loginValue;
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
            }
                     
            return TableToJson(dt);

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
            }

            return TableToJson(dt);

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
                }
            }
            else
            {
                connectionClass.CreateMessageLog("CaseId passed to GetActionRecord method in HomeController is null");
            }

            return TableToJson(dt);

        }

        public string TableToJson(DataTable table)
        {
            string JSONString = string.Empty;
            try
            {
                JSONString = JsonConvert.SerializeObject(table);
            }
            catch (Exception ex)
            {
                connectionClass.CreateMessageLog(ex.Message);
            }
            return JSONString;
        }

        public void ExceptionMessageFromView(string exView)
        {
            connectionClass.CreateMessageLog(exView);
        }

        public string GetDocId(int caseId)
        {
            string docId = string.Empty;
            try
            {
                docId = JsonConvert.SerializeObject(connectionClass.GetDocumentId(caseId));
            }
            catch (Exception ex)
            {
                connectionClass.CreateMessageLog(ex.Message);
            }
            return docId;
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

        public void Execute()
        {
            try
            {
                string path = @"Docs/ImageTestSoap.xml";
                string webRootPath = _env.WebRootPath;
                string finaldocPath = Path.Combine(webRootPath, path);
                HttpWebRequest request = CreateWebRequest();
                XmlDocument soapEnvelopeXml = new XmlDocument();
                soapEnvelopeXml.Load(finaldocPath);
                using (Stream stream = request.GetRequestStream())
                {
                    soapEnvelopeXml.Save(stream);
                }
                using (WebResponse response = request.GetResponse())
                {
                    using (StreamReader rd = new StreamReader(response.GetResponseStream()))
                    {
                        string soapResult = rd.ReadToEnd();
                        Console.WriteLine(soapResult);
                        string outputFile = @"Docs/ResponseFile.txt";
                        string responseFilePath = Path.Combine(webRootPath, outputFile);
                        StreamWriter streamWriter = new StreamWriter(responseFilePath);
                        streamWriter.WriteLine(soapResult);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message + "Error occured in Service Consumed !");
            }

        }
        /// <summary>
        /// Create a soap webrequest to [Url]
        /// </summary>
        /// <returns></returns>
        public static HttpWebRequest CreateWebRequest()
        {
            string sWebServiceUrls = "https://alb.integration3.wealthint.awsnp.national.com.au/eProxy/service/ImagingInquiry";
            HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(sWebServiceUrls);
            webRequest.Headers.Add("SOAPAction", "/Webservices/Services/Imaging/Inquiry.serviceagent/HTTPSEndpoint/RetrieveImage");
            // webRequest.Headers.Add(@"SOAP:/Webservices/Services/Imaging/Inquiry.serviceagent/HTTPSEndpoint/RetrieveImage");
            webRequest.ContentType = "text/xml;charset=\"utf-8\"";
            webRequest.Accept = "text/xml";
            webRequest.Method = "POST";
            return webRequest;
        }

        public IActionResult DocTransport()
        {
            Execute();
            string contentType = string.Empty;
            byte[] FileBytes = null;
            string path = @"Docs/ResponseFile.txt";
            string webRootPath = _env.WebRootPath;
            string finaldocPath = Path.Combine(webRootPath, path);
            Console.WriteLine("Path of the document is " + finaldocPath);

            try
            {
                FileBytes = System.IO.File.ReadAllBytes(finaldocPath);
                FileInfo fileInfo = new FileInfo(finaldocPath);
                string extn = fileInfo.Extension;
                System.IO.File.SetAttributes(finaldocPath, FileAttributes.ReadOnly);
                new FileExtensionContentTypeProvider().TryGetContentType(finaldocPath, out contentType);
                return File(FileBytes, contentType);
            }
            catch (Exception ex)
            {
                connectionClass.CreateMessageLog(ex.Message);
                return null;
            }

        }

    }
}
