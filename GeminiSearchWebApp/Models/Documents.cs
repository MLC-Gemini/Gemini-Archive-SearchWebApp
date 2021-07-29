using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;

using System.Threading.Tasks;

namespace Gemini.Models
{
    public class Documents
    {
        public string DocumentType { get; set; }
        public string Created { get; set; }
        public string Id { get; set; }
        public string Source { get; set; }
        public string BoxBatch { get; set; }
        public string BundleId { get; set; }
        public string DateTimeReceived { get; set; }
        public string IdLetterDescription { get; set; }
    }
}
