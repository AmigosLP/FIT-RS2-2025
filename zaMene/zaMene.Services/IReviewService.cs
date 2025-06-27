using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using zaMene.Model;
using zaMene.Model.SearchObjects;

namespace zaMene.Services
{
    public interface IReviewService : ICRUDService<Review, ReviewSearchObject, ReviewDto, ReviewUpdateDto>
    {
        Task<ReviewDto> CreateReview(ReviewCreateDto request);
        Task<List<ReviewDto>> GetReviewsByPropertyId(int propertyId);
        Task<List<ReviewDto>> GetAllReview();
        Task<ReviewDto> UpdateReview(int id, ReviewUpdateDto request);
        Task<bool> DeleteReview(int id);
    }
}
