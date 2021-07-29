using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace Gemini.UtilityFolder
{
    public class SearchMaster
    {
        public string DataRange { get; set; }
        public string ToRange { get; set; }
        public string DataCase { get; set; }
        public string PolicyId { get; set; }
        public string AdvisorId { get; set; }
        public string FilterLevel { get; set; }
    }
}
