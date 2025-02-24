using zaMene.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Services
{
    public interface IProductService
    {
        List<Product> GetList();
    }
}
