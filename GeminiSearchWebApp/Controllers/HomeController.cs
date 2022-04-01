﻿using GeminiSearchWebApp.DAL;
using GeminiSearchWebApp.Models;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Net;
using System.Text;
using System.Xml;

namespace GeminiSearchWebApp.Controllers
{

    public class HomeController : Controller
    {
        private IConfiguration configuration;
        private ConnectionClass connectionClass;
        public LdapConnect ldapConnect;
        public static string loggedInUserName { get; set; }
        public static bool loginResult = false;
        private readonly IWebHostEnvironment _env;
        public string createdFile;
        public string createdFileName;
        public HomeController(IConfiguration _configuration, IWebHostEnvironment env)
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
            string logInName = string.Empty;

            try
            {
                var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
                var config = builder.Build();
                var domain = config["SecuritySettings:domain"];
                if (userName != null && password != null)
                {
                    logInName = ldapConnect.ValidateUsernameAndPassword(userName, password, domain);
                    if (!string.IsNullOrEmpty(logInName))
                    {
                        result = JsonConvert.SerializeObject(logInName);
                        loggedInUserName = logInName;

                        return result;
                    }
                    else
                    {
                        result = null;
                        connectionClass.CreateMessageLog(string.Format("Login Username&Password is null or invalid"));
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


        public bool LoginCheck(string userName, string loginStatus)
        {
            //string result = string.Empty;
            string inputToValidate = GetStringFromBase64(loginStatus);

            try
            {
                if (inputToValidate.ToLower() == "True".ToLower())
                {
                    loginResult = Convert.ToBoolean(inputToValidate);
                    connectionClass.CreateLog(userName, HttpContext.Session.Id);
                }
                else
                {
                    loginResult = false;
                }
            }
            catch (Exception ex)
            {
                connectionClass.CreateMessageLog(ex.Message);
            }

            HttpContext.Session.SetString("isAuth", loginResult.ToString()); // adding session variable for holding value

            return loginResult;
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
            ViewBag.sessionUserName = loggedInUserName;
            return View();
        }


        public string GetSearchDoc(string fLevel, string uId, string fDate, string tDate, string caseType)
        {
            DataTable dt = new DataTable();
            string format;
            format = "dd/MM/yyyy";
            CultureInfo provider = CultureInfo.InvariantCulture;

            if (HttpContext.Session.GetString("isAuth") == true.ToString())
            {
                try
                {
                    UserInput userInput = new UserInput();
                    if (fLevel != null && uId != null && caseType != null)
                    {
                        userInput.FilterLevel = fLevel;
                        userInput.UserId = uId;
                        userInput.CaseTypeDate = caseType;
                    }
                    else
                    {
                        connectionClass.CreateSessionMessageLog("HomeController GetSearchDoc method variables are null", HttpContext.Session.Id);
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
                    connectionClass.CreateSessionMessageLog(ex.Message, HttpContext.Session.Id);
                }
            }
            else
            {
                connectionClass.CreateMessageLog("Unauthorised behaviour");
            }

            return TableToJson(dt);

        }

        public string GetCasesRecord(string filterLevel, string userId, string fromDate, string toDate, string caseDateType)

        {
            DataTable dt = new DataTable();
            string format;
            format = "dd/MM/yyyy";
            CultureInfo provider = CultureInfo.InvariantCulture;

            if (HttpContext.Session.GetString("isAuth") == true.ToString())
            {
                try
                {
                    UserInput userInput = new UserInput();
                    if (filterLevel != null && User != null && caseDateType != null)
                    {
                        userInput.FilterLevel = filterLevel;
                        userInput.UserId = userId;
                        userInput.CaseTypeDate = caseDateType;
                    }
                    else
                    {
                        connectionClass.CreateSessionMessageLog("HomeController GetSearchDoc method variables are null", HttpContext.Session.Id);
                    }

                    if (fromDate == null || toDate == null)
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
                    connectionClass.CreateSessionMessageLog(ex.Message, HttpContext.Session.Id);
                }
            }
            else
            {
                connectionClass.CreateMessageLog("Unauthorised behaviour");
            }

            return TableToJson(dt);

        }


        public string GetActionRecord(int selectedCaseId)
        {
            DataTable dt = new DataTable();
            if (HttpContext.Session.GetString("isAuth") == true.ToString())
            {
                if (selectedCaseId != 0)
                {
                    try
                    {
                        dt = connectionClass.GetActionRecord(selectedCaseId);

                    }
                    catch (Exception ex)
                    {
                        connectionClass.CreateSessionMessageLog(ex.Message, HttpContext.Session.Id);
                    }
                }
                else
                {
                    connectionClass.CreateSessionMessageLog("CaseId passed to GetActionRecord method in HomeController is null", HttpContext.Session.Id);
                }
            }
            else
            {
                connectionClass.CreateMessageLog("Unauthorised behaviour");
            }

            return TableToJson(dt);

        }


        public string TableToJson(DataTable table)
        {
            string JSONString = string.Empty;
            if (HttpContext.Session.GetString("isAuth") == true.ToString())
            {
                try
                {
                    JSONString = JsonConvert.SerializeObject(table);
                }
                catch (Exception ex)
                {
                    connectionClass.CreateSessionMessageLog(ex.Message, HttpContext.Session.Id);
                }
            }
            else
            {
                connectionClass.CreateMessageLog("Unauthorised behaviour");
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
            if (HttpContext.Session.GetString("isAuth") == true.ToString())
            {
                try
                {
                    DataTable documentId = connectionClass.GetDocumentId(caseId);
                    docId = JsonConvert.SerializeObject(documentId);
                }
                catch (Exception ex)
                {
                    connectionClass.CreateSessionMessageLog(ex.Message, HttpContext.Session.Id);
                }
            }
            else
            {
                connectionClass.CreateMessageLog("Unauthorised behaviour");
            }
            return docId;
        }

        public string Execute(string docId)
        {
            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
            var config = builder.Build();
            string towerAPIusr = config["SecuritySettings:towerAPIsrvUser"];
            string towerAPIpass = new string(config["SecuritySettings:towerAPIsrvPass"].ToCharArray());
            string path = config["AppSettings:geminiDocRequest"];
            string requestpath = config["AppSettings:geminiDocTemplate"];
            string outputFile = config["AppSettings:geminiDocResponse"];
            string requestLogging = config["AppSettings:geminiDocReqlogging"];
            string requestUnescape = config["AppSettings:geminiMsgUnescape"];
            string deleteDownloading = config["AppSettings:geminiDeleteDownload"];
            string finaldocPath = string.Empty;
            if (HttpContext.Session.GetString("isAuth") == true.ToString() && !(string.IsNullOrEmpty(docId)))
            {
                if (docId.Contains("/") == true)
                {
                    try
                    {
                        string docName = string.Empty;
                        string docType = string.Empty;
                        string respStatus = string.Empty;
                        string binaryResponse = string.Empty;
                        string responseFilePath = string.Empty;
                        string OpeningDocPath = string.Empty;
                        // path = @(path);
                        // requestpath = "@" + requestpath;
                        string webRootPath = _env.WebRootPath;
                        string reqdocPath = Path.Combine(webRootPath, requestpath);
                        finaldocPath = Path.Combine(webRootPath, path);
                        var text = System.IO.File.ReadAllText(reqdocPath);
                        text = text.Replace("{usr}", towerAPIusr);
                        text = text.Replace("{pwdd}", towerAPIpass);
                        text = text.Replace("{docsID}", docId.Trim());
                        System.IO.File.WriteAllText(finaldocPath, text);
                        docName = docId.Replace("/", "-").Trim();

                        HttpWebRequest request = CreateWebRequest();

                        if (request != null)
                        {
                            XmlDocument soapEnvelopeXml = new XmlDocument();
                            soapEnvelopeXml.Load(finaldocPath);

                            if (requestUnescape == "N")
                            {
                                if (requestLogging == "Y")
                                {
                                    System.IO.File.WriteAllText(Path.Combine(webRootPath, "Docs/lastRequestWithEscape.xml"), soapEnvelopeXml.InnerXml);
                                }

                                using (Stream stream = request.GetRequestStream())
                                {
                                    soapEnvelopeXml.Save(stream);
                                }
                            }
                            else
                            {
                                string result = UnEscapeXml(soapEnvelopeXml.InnerXml);
                                if (requestLogging == "Y")
                                {
                                    System.IO.File.WriteAllText(Path.Combine(webRootPath, "Docs/lastRequestWithoutEscape.xml"), result);
                                }
                                byte[] postData = Encoding.ASCII.GetBytes(result);
                                request.ContentLength = postData.Length;
                                using (Stream stream = request.GetRequestStream())
                                {
                                    stream.Write(postData, 0, postData.Length); // Send the data.
                                }
                            }

                            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                            Console.WriteLine("Response description is  " + response.StatusDescription);
                            Console.WriteLine("Response status  is  " + response.StatusCode);
                            string ver = response.ProtocolVersion.ToString();
                            StreamReader reader = new StreamReader(response.GetResponseStream());
                            string soapResult = reader.ReadToEnd();
                            //  string outputFile = @"Docs/XML_Response.xml";
                            reader.Dispose();
                            responseFilePath = Path.Combine(webRootPath, outputFile);
                            System.IO.File.WriteAllText(responseFilePath, soapResult);
                            if (System.IO.File.Exists(responseFilePath))
                            {
                                List<string> lstResponse = GetResponseDetails(responseFilePath);

                                if (lstResponse != null)
                                {
                                    docType = lstResponse[0].ToString();
                                    respStatus = lstResponse[1].ToString();
                                    binaryResponse = lstResponse[2].ToString();
                                }
                                if (respStatus.ToLower() == "success" && !string.IsNullOrEmpty(binaryResponse))
                                {
                                    createdFile = @"Docs/" + docName + "." + docType.ToLower();
                                    createdFileName = docName + "." + docType.ToLower();
                                    OpeningDocPath = Path.Combine(webRootPath, createdFile);
                                    LoadBase64(binaryResponse, OpeningDocPath);
                                }
                            }
                        }
                        else
                        {
                            return null;
                        }

                    }
                    catch (Exception ex)
                    {
                        connectionClass.CreateSessionMessageLog(ex.Message + "Error occured in Service Consumed !", HttpContext.Session.Id);
                        return null;
                    }
                    finally
                    {
                        if (System.IO.File.Exists(finaldocPath))
                        {
                            if (deleteDownloading == "Y")
                            {
                                System.IO.File.Delete(finaldocPath);
                            }
                        }
                    }
                }
                else
                {
                    string OpeningDocPath = string.Empty;
                    string webRootPath = _env.WebRootPath;
                    string docName = string.Empty;
                    docName = docId.Trim();

                    DataTable dt = new DataTable();
                    var docType = docId.Trim().Substring(0, 2);

                    switch (docType)
                    {
                        case "CR":
                        case "SW":
                        case "TL":
                            try
                            {
                                dt = connectionClass.GetCustomerRequestText(docName);
                                if (dt.Rows.Count > 0)
                                {
                                    createdFile = @"Docs/" + docName + ".txt";
                                    createdFileName = docName + ".txt";
                                    OpeningDocPath = Path.Combine(webRootPath, createdFile);
                                    string Text = dt.Rows[0]["Text"].ToString();
                                    LoadTxtFile(Text, OpeningDocPath);
                                }
                            }
                            catch (Exception ex)
                            {
                                connectionClass.CreateMessageLog(ex.Message);
                            }

                            break;

                        default:
                            try
                            {
                                dt = connectionClass.GetDocumentContent(docName);
                                if (dt.Rows.Count > 0)
                                {
                                    string originalFileName = dt.Rows[0]["OriginalFileName"].ToString();
                                    string originalExtension = string.Empty;
                                    if (originalFileName.IndexOf('.') > 0)
                                    {
                                        originalExtension = originalFileName.Substring(originalFileName.IndexOf('.'));
                                    }

                                    createdFile = @"Docs/" + docName + originalExtension;
                                    createdFileName = docName + originalExtension;
                                    OpeningDocPath = Path.Combine(webRootPath, createdFile);
                                    string Text = dt.Rows[0]["DocumentText"].ToString();
                                    LoadTxtFile(Text, OpeningDocPath);
                                }
                            }
                            catch (Exception ex)
                            {
                                connectionClass.CreateSessionMessageLog(ex.Message, HttpContext.Session.Id);
                            }

                            break;
                    }
                }
            }
            else
            {
                connectionClass.CreateMessageLog("Unauthorised behaviour");
            }

            return createdFileName;

        }
        /// <summary>
        /// Create a soap webrequest to [Url]
        /// </summary>
        /// <returns></returns>
        public static HttpWebRequest CreateWebRequest()
        {
            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
            var config = builder.Build();
            string towerAPIurl = config["SecuritySettings:towerAPIurl"];
            string serviceUrl = config["SecuritySettings:serviceUrl"];
            string sWebServiceUrls = string.Concat(towerAPIurl, serviceUrl);
            HttpWebRequest webRequest = null;
            if (loginResult == true)
            {
                try
                {
                    webRequest = (HttpWebRequest)WebRequest.Create(sWebServiceUrls);
                    webRequest.Headers.Add("SOAPAction", "/Webservices/Services/Imaging/Inquiry.serviceagent/HTTPSEndpoint/RetrieveImage");
                    // webRequest.Headers.Add(@"SOAP:/Webservices/Services/Imaging/Inquiry.serviceagent/HTTPSEndpoint/RetrieveImage");
                    webRequest.ContentType = "text/xml;charset=\"utf-8\"";
                    webRequest.Accept = "text/xml";
                    webRequest.Method = "POST";
                }
                catch (Exception)
                {
                    return null;
                }
            }
            else
            {
                Console.WriteLine("Unauthorised behaviour");
            }

            return webRequest;
        }

        public static void LoadBase64(string base64, string path)
        {
            try
            {
                byte[] bytes = Convert.FromBase64String(base64);
                using (FileStream fs = System.IO.File.Open(path, FileMode.OpenOrCreate, FileAccess.Write, FileShare.None))
                {
                    fs.Write(bytes, 0, bytes.Length);
                    fs.Flush();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in LoadBase64 Method" + ex.Message);
            }
        }

        public static void LoadTxtFile(string txtContent, string path)
        {
            try
            {
                byte[] bytes = Encoding.ASCII.GetBytes(txtContent);
                using (FileStream fs = System.IO.File.Open(path, FileMode.OpenOrCreate, FileAccess.Write, FileShare.None))
                {
                    fs.Write(bytes, 0, bytes.Length);
                    fs.Flush();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in LoadTxtFile Method" + ex.Message);
            }
        }


        public static string EscapeXml(string s)
        {
            string toxml = s;
            if (!string.IsNullOrEmpty(toxml))
            {
                // replace literal values with entities
                toxml = toxml.Replace("&", "&amp;");
                toxml = toxml.Replace("'", "&apos;");
                toxml = toxml.Replace("\"", "&quot;");
                toxml = toxml.Replace(">", "&gt;");
                toxml = toxml.Replace("<", "&lt;");
            }
            return toxml;
        }

        public static string UnEscapeXml(string s)
        {
            string toxml = s;
            if (!string.IsNullOrEmpty(toxml))
            {
                // replace literal values with entities
                toxml = toxml.Replace("&amp;", "&");
                toxml = toxml.Replace("&apos;", "'");
                toxml = toxml.Replace("&quot;", "\"");
                toxml = toxml.Replace("&gt;", ">");
                toxml = toxml.Replace("&lt;", "<");
            }
            return toxml;
        }

        public List<string> GetResponseDetails(string pathofRespFile)
        {
            List<string> lstResult = new List<string>();
            var name = " ";
            IDictionary<string, string> mydict = new Dictionary<string, string>();
            try
            {
                using (XmlReader reader = XmlReader.Create(pathofRespFile))
                {
                    while (reader.Read())
                    {
                        switch (reader.NodeType)
                        {
                            case XmlNodeType.Element:
                                name = reader.Name;
                                break;
                            case XmlNodeType.Text:
                                mydict.Add(name, reader.Value);
                                break;
                        }
                    }
                    if (mydict.ContainsKey("ns0:ImageType"))
                    {
                        string imageType = mydict["ns0:ImageType"];
                        lstResult.Add(imageType.Trim());
                        Console.WriteLine(imageType.Trim());
                    }
                    if (mydict.ContainsKey("ns1:StatusDesc"))
                    {
                        string statusDesc = mydict["ns1:StatusDesc"];
                        lstResult.Add(statusDesc.Trim());
                        Console.WriteLine(statusDesc);
                    }
                    if (mydict.ContainsKey("ns1:binaryContent"))
                    {
                        string binaryContent = mydict["ns1:binaryContent"];
                        lstResult.Add(binaryContent.Trim());
                        Console.WriteLine(binaryContent.Trim());
                    }
                }
                return lstResult;
            }
            catch (Exception)
            {
                return null;
            }

        }


        public string GetStringFromBase64(string inputVal)
        {
            try
            {
                if (!string.IsNullOrEmpty(inputVal))
                {
                    byte[] data = Convert.FromBase64String(inputVal);
                    Console.WriteLine(Encoding.UTF8.GetString(data));
                    return Encoding.UTF8.GetString(data);
                }
                else
                {
                    return null;
                }

            }
            catch
            {
                Console.WriteLine("Error occured while decoding doc name");
                return null;
            }
        }

        public IActionResult DocTransport(string toBeOpendocName)
        {
            Console.WriteLine("value before decoding is  " + toBeOpendocName);
            toBeOpendocName = GetStringFromBase64(toBeOpendocName);
            Console.WriteLine("value after decoding is  " + toBeOpendocName);

            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
            var config = builder.Build();
            string deleteDownloading = config["AppSettings:geminiDeleteDownload"];

            if (HttpContext.Session.GetString("isAuth") == true.ToString() && IsDirectoryTraversing(toBeOpendocName) == false)
            {
                if (!string.IsNullOrEmpty(toBeOpendocName) && toBeOpendocName.ToLower() != "undefined")
                {
                    toBeOpendocName = toBeOpendocName.Trim();
                    string contentType = string.Empty;
                    byte[] FileBytes = null;
                    string path = @"Docs/" + toBeOpendocName;
                    string webRootPath = _env.WebRootPath;
                    string finaldocPath = Path.Combine(webRootPath, path);
                    try
                    {
                        FileBytes = System.IO.File.ReadAllBytes(finaldocPath);
                        System.IO.File.SetAttributes(finaldocPath, FileAttributes.ReadOnly);
                        new FileExtensionContentTypeProvider().TryGetContentType(finaldocPath, out contentType);
                        if (contentType.Contains("application/pdf") || contentType.Contains("text/plain"))
                        {
                            return File(FileBytes, contentType);
                        }
                        else
                        {
                            return File(FileBytes, contentType, toBeOpendocName);
                        }
                    }
                    catch (Exception ex)
                    {
                        connectionClass.CreateSessionMessageLog(ex.Message, HttpContext.Session.Id);

                    }
                    finally
                    {
                        if (System.IO.File.Exists(finaldocPath))
                        {
                            if (deleteDownloading == "Y")
                            {
                                System.IO.File.Delete(finaldocPath);
                            }

                        }

                    }
                }
                else
                {
                    ViewBag.DocError = toBeOpendocName;
                }
            }
            else
            {
                ViewBag.DocError = toBeOpendocName;
                connectionClass.CreateMessageLog("Unauthorised behaviour");
            }
            return View();
        }

        public bool IsDirectoryTraversing(string fileName)
        {
            bool isTraversing = false;

            if (String.IsNullOrWhiteSpace(fileName))
            {
                return isTraversing;
            }

            var decodedFileName = System.Web.HttpUtility.UrlDecode(fileName);

            if (decodedFileName.Contains("/") ||
                decodedFileName.Contains(@"\") ||
                decodedFileName.Contains("$") ||
                decodedFileName.Contains("..") ||
                decodedFileName.Contains("?"))
            {
                isTraversing = true;
            }

            return isTraversing;
        }

    }
}
