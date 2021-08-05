using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gemini.Models
{
    public class Case
    {
        public string Account { get; set; }
        public Int32 Status { get; set; }
        public string CaseType { get; set; }
        public string Created { get; set; }
        public string Completed { get; set; }
        public Int32 Priority { get; set; }
        public string Adviser { get; set; }
        public string Flag { get; set; }
        public string CustomerId { get; set; }
        public Int32 Requestor { get; set; }
        public string CaseID { get; set; }
        public Int64 WorkpackID { get; set; }
        public string Team { get; set; }
        public Int32 InPFC { get; set; }
        public Int32 Employees { get; set; }
    }
}
