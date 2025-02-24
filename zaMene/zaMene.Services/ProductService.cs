using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model;

namespace zaMene.Services
{
    public class ProductService : IProductService
    {
        public List<Product> List = new List<Product>()
        {
            new Product()
            {
                ProductID = 1,
                Name = "Test",
                Price = 999
            },
            new Product()
            {
                ProductID = 1,
                Name = "Test2",
                Price = 450
            }
        };
        public virtual List<Product> GetList()
        {
            return List;
        }

    }
}
