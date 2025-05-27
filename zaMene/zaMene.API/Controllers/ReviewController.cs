using Microsoft.AspNetCore.Mvc;
using zaMene.API.Controllers;
using zaMene.Model.SearchObjects;
using zaMene.Model;
using zaMene.Services;
using RabbitMQ.Client;

[ApiController]
[Route("api/[controller]")]
public class ReviewController : BaseCRUDController<Review, ReviewSearchObject, ReviewDto, ReviewUpdateDto>
{
    public ReviewController(IReviewService reviewService) : base(reviewService)
    {

    }
}
