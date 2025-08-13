using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion.Internal;

namespace zaMene.Model.SearchObjects
{
    public class CountrySearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
    }
}
