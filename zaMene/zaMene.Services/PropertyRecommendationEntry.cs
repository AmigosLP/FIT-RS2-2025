using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.ML.Data;

namespace zaMene.Services
{
    public class PropertyRecommendationEntry
    {
        [KeyType(count: 10000)]
        public uint UserID { get; set; }

        [KeyType(count: 10000)]
        public uint PropertyID { get; set; }
        public float Label { get; set; } = 1;
    }

    public class PropertyRecommendationPrediction
    {
        public float Score { get; set; }
    }
}
