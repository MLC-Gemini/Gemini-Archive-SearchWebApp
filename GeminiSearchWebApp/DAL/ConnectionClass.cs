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
        //string connString = Configuration.GetConnectionString("MyConn");
        // SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["rdsConn"].ConnectionString);


        public DataSet Getrecord(UserInput userInput)
        {
            string connString = Configuration.GetConnectionString("rdsArcConn");
           
            DataSet dsResult = new DataSet();
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand dbCommand = new SqlCommand();
                dbCommand.Connection = conn;
                dbCommand.CommandType = CommandType.StoredProcedure;
                dbCommand.CommandText = "[dbo].[usp_CaseGrid]";
                //dbCommand.Parameters.Add("@FilterLevel", SqlDbType.Int, 20).Value = 1;
                //dbCommand.Parameters.Add("@UserInputtedID", SqlDbType.Char, 20).Value = "17241705";
                //dbCommand.Parameters.Add("@FromDate", SqlDbType.DateTime).Value = DBNull.Value;
                //dbCommand.Parameters.Add("@ToDate", SqlDbType.DateTime).Value = DBNull.Value;
                //dbCommand.Parameters.Add("@CaseDate", SqlDbType.Int, 20).Value = 1;
                conn.Open();



                try
                {
                    if (userInput.FilterLevel == "Account Level")
                    {
                        dbCommand.Parameters.Add("@FilterLevel", SqlDbType.Int, 20).Value = 1;
                        dbCommand.Parameters.Add("@UserInputtedID", SqlDbType.Char, 20).Value = userInput.UserId; //@UserInputtedID

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
                        dbCommand.Parameters.Add("@FromDate", SqlDbType.DateTime).Value = DBNull.Value;
                    }
                    else
                    {
                        dbCommand.Parameters.Add("@FromDate", SqlDbType.DateTime).Value = userInput.FromDate;
                    }

                    if (userInput.ToDate == DateTime.MinValue)
                    {
                        dbCommand.Parameters.Add("@ToDate", SqlDbType.DateTime).Value = DBNull.Value;
                    }
                    else
                    {
                        dbCommand.Parameters.Add("@ToDate", SqlDbType.DateTime).Value = userInput.ToDate;
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
                    da.Fill(dsResult);

                    //SqlDataReader dr = dbCommand.ExecuteReader();
                    //if (dr.HasRows)
                    //{

                    //    while (dr.Read())
                    //    {
                    //        cases.Add(new Case()
                    //        {
                    //            Account = dr["Account"].ToString(),
                    //            Status = Convert.ToInt32(dr["Status"].ToString()),
                    //            CaseType = dr["Case Type"].ToString(),
                    //            Created = dr["Created"].ToString(),
                    //            Completed = dr["Completed"].ToString(),
                    //            Priority = Convert.ToInt32(dr["Priority"].ToString()),
                    //            Adviser = dr["Adviser"].ToString(),
                    //            Flag = dr["Flag"].ToString(),
                    //            CustomerId = dr["Customer Id"].ToString(),
                    //            Requestor = Convert.ToInt32(dr["Requestor"].ToString()),
                    //            CaseID = dr["Case ID"].ToString(),
                    //            WorkpackID = Convert.ToInt32(dr["Workpack ID"].ToString()),
                    //            Team = dr["Team"].ToString(),
                    //            InPFC = Convert.ToInt32(dr["InPFC"].ToString()),
                    //            Employees = Convert.ToInt32(dr["Employee"].ToString())
                    //        });
                    //    }
                    //}
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
            

            return dsResult;
        }
    }
}
