using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.DirectoryServices.Protocols;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using GeminiSearchWebApp.UtilityFolder;

namespace GeminiSearchWebApp.DAL
{
    public class LdapConnect
    {
        public string loggedInUserName { get; set; }
        string name;
        string userID;
        bool resultDta = false;
        public SearchResponse GetLdapConnection(string username, string password, string domain)
        {
            var ldapServer = "ldap.aurdev.national.com.au";
            var baseDn = "OU=Staff Accounts,OU=Restricted Accounts,DC=aurdev,DC=national,DC=com,DC=au";

            try
            {
                LdapDirectoryIdentifier ldi = new LdapDirectoryIdentifier(ldapServer, 389);
                LdapConnection ldapConnection = new LdapConnection(ldi);
                // Console.WriteLine("LdapConnection is created successfully.");
                ldapConnection.AuthType = AuthType.Basic;
                ldapConnection.SessionOptions.ProtocolVersion = 3;
                NetworkCredential nc = new NetworkCredential(username, password, domain); //password
                ldapConnection.Bind(nc);
                Console.WriteLine("LdapConnection authentication success");

                //  string filter = string.Format(CultureInfo.InvariantCulture, "(&(objectClass=user)(objectCategory=user) (sAMAccountName={0}))",(username));

                string filter = "(sAMAccountName=" + username + ")";
                // var attributes = new[] { "sAMAccountName", "displayName", "mail" };
                var attributes = new[] { "sAMAccountName", "memberOf", "cn" };
                // log.DebugFormat("SearchRequest,distinguishedName{0},filter{1}", SearchUserPath, "uid=" + username);

                SearchRequest searchRequest = new SearchRequest(baseDn, filter, System.DirectoryServices.Protocols.SearchScope.Subtree, attributes);

                SearchResponse searchResponse = (SearchResponse)ldapConnection.SendRequest(searchRequest);
                
                return searchResponse;
            }
            catch (Exception)
            {
                return null;
            }
        }
        public string ValidateUsernameAndPassword(string username, string password, string domain)
        {
            SearchResponse searchResponse=null;
            
            try
            {
                searchResponse = GetLdapConnection(username, password, domain);
                if (searchResponse?.ResultCode == ResultCode.Success)
                {
                    loggedInUserName = GetLoginName(searchResponse);
                    if (loggedInUserName!=string.Empty)
                    {
                        resultDta = true;
                    }
                    else
                    {
                        resultDta = false;
                    }
                }
                else
                {
                    resultDta = false;
                }
            }
            catch (Exception)
            {
                resultDta = false;
            }

            return loggedInUserName;
        }

        public static List<KeyValuePair<string, string>> ParseDistinguishedName(string input)
        {
            int i = 0;
            int a = 0;
            int v = 0;
            var attribute = new char[50];
            var value = new char[200];
            var inAttribute = true;
            string attributeString, valueString;
            var names = new List<KeyValuePair<string, string>>();



            while (i < input.Length)
            {
                char ch = input[i++];
                switch (ch)
                {
                    case '\\':
                        value[v++] = ch;
                        value[v++] = input[i++];
                        break;
                    case '=':
                        inAttribute = false;
                        break;
                    case ',':
                        inAttribute = true;
                        attributeString = new string(attribute).Substring(0, a);
                        valueString = new string(value).Substring(0, v);
                        names.Add(new KeyValuePair<string, string>(attributeString, valueString));
                        a = v = 0;
                        break;
                    default:
                        if (inAttribute)
                        {
                            attribute[a++] = ch;
                        }
                        else
                        {
                            value[v++] = ch;
                        }
                        break;
                }
            }
            attributeString = new string(attribute).Substring(0, a);
            valueString = new string(value).Substring(0, v);
            names.Add(new KeyValuePair<string, string>(attributeString, valueString));
            return names;
        }

        public string GetLoginName(SearchResponse searchResponse)
        {
            string loginUserName = string.Empty;
            var builder = new ConfigurationBuilder().SetBasePath(Directory.GetCurrentDirectory()).AddJsonFile("appsettings.json");
            var config = builder.Build();
            var adGroupVal = config["SecuritySettings:ADGroup"];
            var trimDev = config["AppSettings:leftToTrimForDev"];
            var trimProd = config["AppSettings:leftToTrimForProd"];
            try
            {
                if (searchResponse?.ResultCode == ResultCode.Success)
                {
                    var entry = searchResponse.Entries[0];
                    Console.WriteLine(entry.DistinguishedName);
                    var names = ParseDistinguishedName(entry.DistinguishedName);
                    foreach (var pair in names)
                    {
                        Console.WriteLine("{0} = {1}", pair.Key, pair.Value);
                        if (pair.Key.ToLower() == "cn")
                        {
                            userID = pair.Value.Substring(pair.Value.Length - Convert.ToInt32(trimDev));
                            loginUserName = pair.Value.Replace(userID, " ").TrimEnd();
                            Console.WriteLine(loginUserName);
                        }
                    }

                    for (int index = 0; index < entry.Attributes["memberOf"].Count; index++)
                    {
                        // get the group name, for example:
                        String groupName = entry.Attributes["memberOf"][index].ToString();
                        Console.WriteLine(groupName);
                        var groups = ParseDistinguishedName(groupName);
                        foreach (var pair in groups)
                        {
                            Console.WriteLine("{0} = {1}", pair.Key, pair.Value);
                            if (pair.Key.ToLower() == "cn")
                            {
                                name = pair.Value;
                                if (name.ToLower() == adGroupVal.ToLower())
                                {
                                    //resultDta = true;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {

            }
            return loginUserName;
        }

        
    }
}
