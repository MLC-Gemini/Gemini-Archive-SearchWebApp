using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gemini.Models
{
    public class ActionHistory
    {
        public string Action { get; set; }
        public string DateTime { get; set; }
        public string Employee { get; set; }
        public string Message { get; set; }
    }
}
