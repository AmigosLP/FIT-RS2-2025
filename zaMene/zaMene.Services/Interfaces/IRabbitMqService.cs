using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace zaMene.Services.Interface
{
    public interface IRabbitMqService
    {
        void PublishRegistrationEmail(string email);
    }
}
