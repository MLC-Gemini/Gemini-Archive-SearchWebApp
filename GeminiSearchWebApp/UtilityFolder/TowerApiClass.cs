using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

namespace GeminiSearchWebApp.UtilityFolder
{
    public class TowerApiClass
    {
        public void ConsumeService()
        {
            try
            {
                // string sWebServiceUrl = "https://mlc-dev60-am.wm.thenational.com/eProxy/service/ImagingInquiry";
                string sWebServiceUrl = "https://alb.integration3.wealthint.awsnp.national.com.au/eProxy/service/ImagingInquiry";
                // string sWebServiceUrl = "http://forwardproxy:3128";
                //string sWebServiceUrl = "http://forwardproxy:3128";
                // Create a Web service Request for the URL.           
                WebRequest objWebRequest = WebRequest.Create(sWebServiceUrl);

                //Create a proxy for the service request  
                objWebRequest.Proxy = new WebProxy();

                // set the credentials to authenticate request, if required by the server  
                objWebRequest.Credentials = new NetworkCredential("srv-aft-dgemitrans", "3z+4SX?p#OPZ");
                objWebRequest.Proxy.Credentials = new NetworkCredential("srv-aft-dgemitrans", "3z+4SX?p#OPZ");

                //Get the web service response.  
                HttpWebResponse objWebResponse = (HttpWebResponse)objWebRequest.GetResponse();
                Console.WriteLine(objWebResponse.StatusDescription);
                Console.WriteLine(objWebResponse.StatusCode);

                //get the contents return by the server in a stream and open the stream using a                                                                   -            StreamReader for easy access.  
                StreamReader objStreamReader = new StreamReader(objWebResponse.GetResponseStream());
                Console.WriteLine(objStreamReader);

                // Read the contents.  
                string sResponse = objStreamReader.ReadToEnd();
                Console.WriteLine(sResponse);

                // Cleanup the streams and the response.  
                objStreamReader.Close();
                objWebResponse.Close();
                Console.WriteLine("Service Consumed !");
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message + "Error occured in Service Consumed !");
            }
        }
    }
}
