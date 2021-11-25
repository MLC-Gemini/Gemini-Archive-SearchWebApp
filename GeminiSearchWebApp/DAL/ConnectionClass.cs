﻿using GeminiSearchWebApp.Controllers;
using GeminiSearchWebApp.Models;
using Microsoft.Extensions.Configuration;
using System;
using System.Data;
using System.Data.SqlClient;

namespace GeminiSearchWebApp.DAL
{
    public class ConnectionClass 
    {
        public IConfiguration Configuration;
        public UserInput userInput;
        public HomeController homeController;
        public string userName;
        public DateTime loginDateTime;
        public static string getUserName = string.Empty;

        public ConnectionClass(IConfiguration _configuration)
        {
            Configuration = _configuration;
            userInput = new UserInput();
        }

        public DataTable GetCasesRecord(UserInput userInput)
        {
            string connString = Configuration.GetConnectionString("rdsArcConn");
            DataTable dtCases = new DataTable();
            if (connString != null && userInput!=null)
            {
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
                        da.Dispose();

                    }
                    catch (Exception ex)
                    {
                        CreateMessageLog(ex.Message);
                        Console.WriteLine(ex);
                    }
                    finally
                    {                        
                        conn.Close();
                    }
                }
            }
            else
            {
                CreateMessageLog("Connection String variable or User Input is null");
            }
            return dtCases;
        }


        public DataTable Getrecord(UserInput userInput)
        {
            string connString = Configuration.GetConnectionString("rdsArcConn");
            DataTable dtResult = new DataTable();
            if (connString != null && userInput!=null)
            {
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
                        da.Dispose();

                    }
                    catch (Exception ex)
                    {
                        CreateMessageLog(ex.Message);
                        Console.WriteLine(ex);
                    }
                    finally
                    {
                        conn.Close();
                    }
                }
            }
            else
            {
                CreateMessageLog("Connection String variable or User Input is null");
            }
            return dtResult;
        }


        public DataTable GetActionRecord(int selectedCaseId)
        {
            string connString = Configuration.GetConnectionString("rdsArcConn");
            DataTable dtAction = new DataTable();
            if (selectedCaseId.ToString() != null)
            {
                Convert.ToInt32(selectedCaseId);
            }
            else
            {
                CreateMessageLog("CaseId is empty");
            }
            if (connString != null)
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    SqlCommand dbCommand = new SqlCommand();
                    dbCommand.Connection = conn;
                    dbCommand.CommandType = CommandType.StoredProcedure;
                    dbCommand.CommandText = "[dbo].[usp_GetAction]";
                    conn.Open();
                    try
                    {
                        dbCommand.Parameters.Add("@SelectedCaseID", SqlDbType.Int, 20).Value = selectedCaseId;

                        SqlDataAdapter da = new SqlDataAdapter(dbCommand);
                        da.Fill(dtAction);
                        da.Dispose();

                    }
                    catch (Exception ex)
                    {
                        CreateMessageLog(ex.Message);
                        Console.WriteLine(ex);
                    }
                    finally
                    {
                        conn.Close();
                    }
                }
            }
            else
            {
                CreateMessageLog("Connection String variable is null");
            }
            return dtAction;
        }

        public DataTable GetDocumentId(int selectedCaseId)
        {
            string connString = Configuration.GetConnectionString("rdsArcConn");
            DataTable dtDocId = new DataTable();
            if (selectedCaseId.ToString() != null)
            {
                Convert.ToInt32(selectedCaseId);
            }
            else
            {
                CreateMessageLog("CaseId is empty");
            }
            if (connString != null)
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    SqlCommand dbCommand = new SqlCommand();
                    dbCommand.Connection = conn;
                    dbCommand.CommandType = CommandType.StoredProcedure;
                    dbCommand.CommandText = "[dbo].[usp_GetDocID]";
                    conn.Open();
                    try
                    {
                        dbCommand.Parameters.Add("@SelectedCaseID", SqlDbType.Int, 20).Value = selectedCaseId;

                        SqlDataAdapter da = new SqlDataAdapter(dbCommand);
                        da.Fill(dtDocId);
                        da.Dispose();

                    }
                    catch (Exception ex)
                    {
                        CreateMessageLog(ex.Message);
                        Console.WriteLine(ex);
                    }
                    finally
                    {
                        conn.Close();
                    }
                }
            }
            else
            {
                CreateMessageLog("Connection String variable is null");
            }
            return dtDocId;
        }

        public void CreateLog(string userName)
        {
            getUserName = userName;
            loginDateTime = DateTime.Now;
            userName = "LDCYS12";

            string connString = Configuration.GetConnectionString("rdsArcConn");
            if (connString != null)
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    SqlCommand dbCommand = new SqlCommand();
                    dbCommand.Connection = conn;
                    dbCommand.CommandType = CommandType.StoredProcedure;
                    dbCommand.CommandText = "[dbo].[usp_GetUserLog]";
                    conn.Open();
                    try
                    {
                        if (userName!=null && loginDateTime!=DateTime.MinValue)
                        {
                            dbCommand.Parameters.Add("@UserName", SqlDbType.VarChar, 20).Value = userName;
                            dbCommand.Parameters.Add("@TimeStamp", SqlDbType.DateTime2).Value = loginDateTime;
                        }
                        else
                        {
                            CreateMessageLog("UserName and Login date/time is null");
                        }
                        

                        dbCommand.ExecuteNonQuery();

                    }
                    catch (Exception ex)
                    {
                        CreateMessageLog(ex.Message);
                        Console.WriteLine(ex);
                    }
                    finally
                    {
                        conn.Close();
                        dbCommand.Dispose();
                    }
                }
            }
            else
            {
                CreateMessageLog("Connection String variable is null");
            }
        }

        public void CreateMessageLog(string exDb)
        {
            var exceptionDateTime = DateTime.Now;
            var uName = getUserName;
            uName = "LDCYS12";

            string connString = Configuration.GetConnectionString("rdsArcConn");
            if (connString != null)
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    SqlCommand dbCommand = new SqlCommand();
                    dbCommand.Connection = conn;
                    dbCommand.CommandType = CommandType.StoredProcedure;
                    dbCommand.CommandText = "[dbo].[usp_GetMessageLog]";
                    conn.Open();
                    try
                    {
                        if (uName != null && exceptionDateTime!=DateTime.MinValue && exDb!=null)
                        {
                            dbCommand.Parameters.Add("@UserName", SqlDbType.VarChar, 20).Value = uName;
                            dbCommand.Parameters.Add("@TimeStamp", SqlDbType.DateTime2).Value = exceptionDateTime;
                            dbCommand.Parameters.Add("@MessageText", SqlDbType.Text).Value = exDb;
                        }
                        else
                        {
                            Console.WriteLine("Message Log variables are null");
                        }

                        dbCommand.ExecuteNonQuery();
                        
                    }
                    catch (Exception ex)
                    {

                        Console.WriteLine(ex);
                    }
                    finally
                    {
                        conn.Close();
                        dbCommand.Dispose();
                    }
                }
            }
            else
            {
                Console.WriteLine("Connection String variable is null");
            }
        }

    }
}
