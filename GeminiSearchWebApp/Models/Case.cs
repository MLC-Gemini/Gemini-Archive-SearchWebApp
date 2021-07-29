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
        public string status { get; set; }
        public string CaseType { get; set; }
        public string Created { get; set; }
        public string Completed { get; set; }
        public string Priority { get; set; }
        public string Advisor { get; set; }
        public string Flag { get; set; }
        public string CustomerId { get; set; }
        public string Requestor { get; set; }
        public string CaseId { get; set; }
        public string WorkpackId { get; set; }
        public string Team { get; set; }
        public string InPFC { get; set; }
        public string Employees { get; set; }
    }
}
