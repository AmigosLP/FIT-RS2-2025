using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using zaMene.Model;
using zaMene.Model.SearchObjects;

namespace zaMene.Services
{
    public interface IPropertyService : ICRUDService<
        Model.Property,
        PropertySearchObject,
        PropertyDto,
        PropertyUpdateDto>
    {
        Task<double> GetAverageRating(int propertyId);
        Task<List<PropertyDto>> GetAllWithImagesAsync();


    }
}
