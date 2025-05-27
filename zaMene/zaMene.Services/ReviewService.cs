using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MapsterMapper;
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
    }
}
