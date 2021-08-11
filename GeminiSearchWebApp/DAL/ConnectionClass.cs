using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Threading.Tasks;
using System.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using GeminiSearchWebApp.Models;
using Gemini.Models;


namespace GeminiSearchWebApp.DAL
{
    public class ConnectionClass
    {
        private IConfiguration Configuration;
        public UserInput userInput;
        public int filterInput;
        public int caseDateInput;
        List<Case> cases = new List<Case>();

        public ConnectionClass(IConfiguration _configuration)
        {
            Configuration = _configuration;
            userInput = new UserInput();
        }

        public DataTable GetCasesRecord(UserInput userInput)
        {
            string connString = Configuration.GetConnectionString("rdsArcConn");
            DataTable dtCases = new DataTable();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand dbCommand = new SqlCommand();
                dbCommand.Connection = conn;
                dbCommand.CommandType = CommandType.StoredProcedure;
                dbCommand.CommandText = "[dbo].[usp_GetCases]";
                conn.Open();
                try
                {
                    if (userInput.FilterLevel == "Account Level")
                    {
                        dbCommand.Parameters.Add("@FilterLevel", SqlDbType.Int, 20).Value = 1;
                        dbCommand.Parameters.Add("@UserInputtedID", SqlDbType.Char, 20).Value = userInput.UserId;

                    }
                    else if (userInput.FilterLevel == "Adviser Level")
                    {
                        dbCommand.Parameters.Add("@FilterLevel", SqlDbType.Int, 20).Value = 2;
                        dbCommand.Parameters.Add("@UserInputtedID", SqlDbType.Char, 20).Value = userInput.UserId;
                    }
                    else
                    {
                        dbCommand.Parameters.Add("@FilterLevel", SqlDbType.Int, 20).Value = 3;
                        dbCommand.Parameters.Add("@UserInputtedID", SqlDbType.Char, 20).Value = userInput.UserId;
                    }

                    if (userInput.FromDate == DateTime.MinValue)
                    {
                        dbCommand.Parameters.Add("@FromDate", SqlDbType.Date).Value = DBNull.Value;
                    }
                    else
                    {
                        dbCommand.Parameters.Add("@FromDate", SqlDbType.Date).Value = userInput.FromDate;
                    }

                    if (userInput.ToDate == DateTime.MinValue)
                    {
                        dbCommand.Parameters.Add("@ToDate", SqlDbType.Date).Value = DBNull.Value;
                    }
                    else
                    {
                        dbCommand.Parameters.Add("@ToDate", SqlDbType.Date).Value = userInput.ToDate;
                    }

                    if (userInput.CaseTypeDate == "Case Creation Date")
                    {
                        dbCommand.Parameters.Add("@CaseDate", SqlDbType.Int, 20).Value = 1;
                    }
                    else
                    {
                        dbCommand.Parameters.Add("@CaseDate", SqlDbType.Int, 20).Value = 2;
                    }


                    SqlDataAdapter da = new SqlDataAdapter(dbCommand);
                    da.Fill(dtCases);

                }
                catch (Exception ex)
                {

                    Console.WriteLine(ex);
                }
                finally
                {
                    conn.Close();
                }
            }
            return dtCases;
        }




        public DataTable Getrecord(UserInput userInput)
        {
            string connString = Configuration.GetConnectionString("rdsArcConn");
           
            DataSet dsResult = new DataSet();
            DataTable dtResult = new DataTable();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand dbCommand = new SqlCommand();
                dbCommand.Connection = conn;
                dbCommand.CommandType = CommandType.StoredProcedure;
                dbCommand.CommandText = "[dbo].[usp_GeminiArcSp]";
                conn.Open();
                try
                {
                    if (userInput.FilterLevel == "Account Level")
                    {
                        dbCommand.Parameters.Add("@FilterLevel", SqlDbType.Int, 20).Value = 1;
                        dbCommand.Parameters.Add("@UserInputtedID", SqlDbType.Char, 20).Value = userInput.UserId; 

                    }
                    else if (userInput.FilterLevel == "Adviser Level")
                    {
                        dbCommand.Parameters.Add("@FilterLevel", SqlDbType.Int, 20).Value = 2;
                        dbCommand.Parameters.Add("@UserInputtedID", SqlDbType.Char, 20).Value = userInput.UserId;
                    }
                    else
                    {
                        dbCommand.Parameters.Add("@FilterLevel", SqlDbType.Int, 20).Value = 3;
                        dbCommand.Parameters.Add("@UserInputtedID", SqlDbType.Char, 20).Value = userInput.UserId;
                    }

                    if (userInput.FromDate == DateTime.MinValue)
                    {
                        dbCommand.Parameters.Add("@FromDate", SqlDbType.Date).Value = DBNull.Value;
                    }
                    else
                    {
                        dbCommand.Parameters.Add("@FromDate", SqlDbType.Date).Value = userInput.FromDate;
                    }

                    if (userInput.ToDate == DateTime.MinValue)
                    {
                        dbCommand.Parameters.Add("@ToDate", SqlDbType.Date).Value = DBNull.Value;
                    }
                    else
                    {
                        dbCommand.Parameters.Add("@ToDate", SqlDbType.Date).Value = userInput.ToDate;
                    }

                    if (userInput.CaseTypeDate == "Case Creation Date")
                    {
                        dbCommand.Parameters.Add("@CaseDate", SqlDbType.Int, 20).Value = 1;
                    }
                    else
                    {
                        dbCommand.Parameters.Add("@CaseDate", SqlDbType.Int, 20).Value = 2;
                    }


                    SqlDataAdapter da = new SqlDataAdapter(dbCommand);
                    da.Fill(dtResult);

                }
                catch (Exception ex)
                {

                    Console.WriteLine(ex);
                }
                finally
                {
                    conn.Close();
                }
            }
           
            return dtResult;
        }
    }
}
