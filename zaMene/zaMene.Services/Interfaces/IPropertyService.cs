using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Mapster.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using zaMene.Model;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModel;

namespace zaMene.Services.Interface
{
    public interface IPropertyService : ICRUDService<
        Model.Entity.Property,
        PropertySearchObject,
        PropertyDto,
        PropertyUpdateDto> {
    
        Task<double> GetAverageRating(int propertyId);
        Task<object> CreatePropertyWithImagesAsync(PropertyCreateRequest request);
        Task<object> AddImagesToPropertyAsync(int propertyId, List<IFormFile> images);
        Task<IEnumerable<object>> GetAllWithImagesAsync();
        Task<bool> DeletePropertyAsync(int propertyId);
        Task<object> GetPropertyDetails(int propertyId);
        Task<object> UpdatePropertyAsync(int propertyId, UpdatePropertyRequestDto request);
        Task<List<PropertyStatisticsDto>> GetPropertyStatistics();

        List<PropertyDto> GetRecommendedProperties(int propertyId);
        List<PropertyDto> GetContentBasedRecommendations(int userId);

        Task<(string message, List<PropertyDto> properties)> GetHomepageRecommendations(int userId);

    }
}
