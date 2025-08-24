using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Services.Interface;

namespace zaMene.Services.Interfaces
{
    public interface IPaymentService : ICRUDService<Payment, PaymentSearchObject, PaymentDto, UpdatePaymentDto>
    {
    }
}
