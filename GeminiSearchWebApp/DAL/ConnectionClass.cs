using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using System.Data.SqlClient;
using Microsoft.Extensions.Configuration;


namespace GeminiSearchWebApp.DAL
{
    public class ConnectionClass
    {
        private IConfiguration Configuration;

        public ConnectionClass(IConfiguration _configuration)
        {
            Configuration = _configuration;
        }
        //string connString = Configuration.GetConnectionString("MyConn");
        // SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["rdsConn"].ConnectionString);

        public DataSet Getrecord(string webGrid, string spName)
        {
            string connString = Configuration.GetConnectionString("rdsConn");
           
            SqlConnection conn = new SqlConnection(connString);
            DataSet dsResult = new DataSet();
            SqlCommand dbCommand = new SqlCommand();
            dbCommand.Connection = conn;
            dbCommand.CommandType = CommandType.StoredProcedure;
            dbCommand.CommandText = spName;
            conn.Open();
            try
            {
                switch (webGrid)
                {
                    case "CASES":
                        dbCommand.Parameters.Add("@Account", SqlDbType.NVarChar, 20).Value = "account";
                        dbCommand.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = "status";
                        dbCommand.Parameters.Add("@CaseType", SqlDbType.NVarChar, 20).Value = "casetype";
                        dbCommand.Parameters.Add("@Created", SqlDbType.NVarChar, 20).Value = "created";
                        dbCommand.Parameters.Add("@Completed", SqlDbType.NVarChar, 20).Value = "completed";
                        dbCommand.Parameters.Add("@Priority", SqlDbType.NVarChar, 20).Value = "priority";
                        dbCommand.Parameters.Add("@Adviser", SqlDbType.NVarChar, 20).Value = "adviser";
                        dbCommand.Parameters.Add("@Flag", SqlDbType.NVarChar, 20).Value = "flag";
                        dbCommand.Parameters.Add("@CustomerId", SqlDbType.NVarChar, 20).Value = "customerid";
                        dbCommand.Parameters.Add("@Requestor", SqlDbType.NVarChar, 20).Value = "requestor";
                        dbCommand.Parameters.Add("@CaseId", SqlDbType.NVarChar, 20).Value = "caseid";
                        dbCommand.Parameters.Add("@WorkpackId", SqlDbType.NVarChar, 20).Value = "workpackid";
                        dbCommand.Parameters.Add("@Team", SqlDbType.NVarChar, 20).Value = "team";
                        dbCommand.Parameters.Add("@InPFC", SqlDbType.NVarChar, 20).Value = "inpfc";
                        dbCommand.Parameters.Add("@Employee", SqlDbType.NVarChar, 20).Value = "employee";
                        break;
                    case "DOCUMENT":
                        dbCommand.Parameters.Add("@Created", SqlDbType.NVarChar, 20).Value = "documenttype";
                        dbCommand.Parameters.Add("@Id", SqlDbType.NVarChar, 20).Value = "id";
                        dbCommand.Parameters.Add("@Source", SqlDbType.NVarChar, 20).Value = "source";
                        dbCommand.Parameters.Add("@BoxBatch", SqlDbType.NVarChar, 20).Value = "boxbatch";
                        dbCommand.Parameters.Add("@BundleId", SqlDbType.NVarChar, 20).Value = "Bundlebd";
                        dbCommand.Parameters.Add("@DateTimeReceived", SqlDbType.NVarChar, 20).Value = "datetimereceived";
                        dbCommand.Parameters.Add("@IdLetterDescription", SqlDbType.NVarChar, 20).Value = "idletterdescription";
                        break;
                    case "ACTIONHISTORY":
                        dbCommand.Parameters.Add("@Action", SqlDbType.NVarChar, 20).Value = "action";
                        dbCommand.Parameters.Add("@DateTime", SqlDbType.NVarChar, 20).Value = "datetime";
                        dbCommand.Parameters.Add("@Employee", SqlDbType.NVarChar, 20).Value = "employee";
                        dbCommand.Parameters.Add("@Message", SqlDbType.VarChar, 255).Value = "message";
                        break;
                    default:
                        break;
                }
                SqlDataAdapter da = new SqlDataAdapter(dbCommand);
                da.Fill(dsResult);
            }
            catch
            {

                return null;
            }
            finally
            {
                conn.Close();
            }

            return dsResult;
        }
    }
}
