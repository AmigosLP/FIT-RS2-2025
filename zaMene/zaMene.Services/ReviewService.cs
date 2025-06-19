using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using zaMene.Model;
using zaMene.Model.SearchObjects;

namespace zaMene.Services
{
    public class ReviewService : BaseCRUDService<Review, ReviewSearchObject, Review, ReviewDto, ReviewUpdateDto >, IReviewService
    {
        public ReviewService(AppDbContext context, IMapper mapper) : base(context, mapper) { }

        public override IQueryable<Review> AddFilter(ReviewSearchObject searchObject, IQueryable<Review> query)
        {
            if (searchObject.PropertyID.HasValue)
                query = query.Where(r => r.PropertyID == searchObject.PropertyID);

            if (searchObject.UserID.HasValue)
                query = query.Where(r => r.UserID == searchObject.UserID);

            return base.AddFilter(searchObject, query);
        }

        public async Task<ReviewDto> CreateReview(ReviewCreateDto request)
        {
            var review = _mapper.Map<Review>(request);
            review.ReviewDate = DateTime.UtcNow;

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync();

            return _mapper.Map<ReviewDto>(review);
        }

        public async Task<List<ReviewDto>> GetReviewsByPropertyId(int propertyId)
        {
            var reviews = await _context.Reviews
                .Include(r => r.User)
                .Where(r => r.PropertyID == propertyId)
                .OrderByDescending(r => r.ReviewID)
                .ToListAsync();

            var reviewsListDto = reviews.Select(r => new ReviewDto
            {
                ReviewID = r.ReviewID,
                UserID = r.UserID,
                PropertyID = r.PropertyID,
                Rating = r.Rating,
                Comment = r.Comment,
                ReviewDate = r.ReviewDate,
                UserFullName = r.User != null ? $"{r.User.FirstName} {r.User.LastName}" : "Nepoznat korisnik",
                UserProfileImageUrl = r.User?.ProfileImagePath
            }).ToList();

            return reviewsListDto;
        }
    }
}
