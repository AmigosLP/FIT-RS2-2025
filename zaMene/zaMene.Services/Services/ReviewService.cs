using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using zaMene.Model;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModel;
using zaMene.Services.Interface;

namespace zaMene.Services.Service
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

        public async Task<List<ReviewDto>> GetAllReview()
        {
            var reviews = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Property)
                .OrderByDescending(r => r.ReviewDate)
                .ToListAsync();

            return reviews.Select(r => new ReviewDto
            {
                ReviewID = r.ReviewID,
                UserID = r.UserID,
                PropertyID = r.PropertyID,
                Rating = r.Rating,
                Comment = r.Comment,
                ReviewDate = r.ReviewDate,
                UserFullName = r.User != null ? $"{r.User.FirstName} {r.User.LastName}" : "Nepoznat korisnik",
                UserProfileImageUrl = r.User?.ProfileImagePath,
                PropertyName = r.Property.Title != null ? r.Property.Title : "Nepoznata nekretnina",
                Description = r.Property.Description !=null ? r.Property.Description : "Nema opisa za nekretninu",
                Address = r.Property.Address !=null ? r.Property.Address : "Nema adrese za nekretninu",
                Price = r.Property.Price
            }).ToList();
        }

        public async Task<ReviewDto> UpdateReview(int id, ReviewUpdateDto request)
        {
            var entity = await _context.Reviews.FindAsync(id);
            if (entity == null)
                throw new Exception("Recenzija nije pronađena");

            entity.Rating = request.Rating;
            entity.Comment = request.Comment;
            entity.ReviewDate = DateTime.UtcNow;

            _context.Reviews.Update(entity);
            await _context.SaveChangesAsync();

            var user = await _context.Users.FindAsync(entity.UserID);

            return new ReviewDto
            {
                ReviewID = entity.ReviewID,
                UserID = entity.UserID,
                PropertyID = entity.PropertyID,
                Rating = entity.Rating,
                Comment = entity.Comment,
                ReviewDate = entity.ReviewDate,
                UserFullName = user != null ? $"{user.FirstName} {user.LastName}" : "Nepoznat korisnik",
                UserProfileImageUrl = user?.ProfileImagePath
            };
        }

        public async Task<bool> DeleteReview(int id)
        {
            var entity = await _context.Reviews.FindAsync(id);
            if (entity == null)
                return false;

            _context.Reviews.Remove(entity);
            await _context.SaveChangesAsync();
            return true;
        }

    }
}
