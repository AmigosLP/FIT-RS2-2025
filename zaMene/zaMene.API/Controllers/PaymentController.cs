using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Services.Interfaces;

namespace zaMene.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PaymentController : BaseCRUDController<Payment, PaymentSearchObject, PaymentDto, UpdatePaymentDto>
    {
        public PaymentController(IPaymentService service) : base(service)
        {
        }
    }
}
