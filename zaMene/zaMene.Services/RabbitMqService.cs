using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using RabbitMQ.Client;
using System.Text;

public class RabbitMqService
{
    private readonly IConfiguration _configuration;

    public RabbitMqService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public void PublishRegistrationEmail(string userEmail)
    {
        var factory = new ConnectionFactory()
        {
            //HostName = _configuration["RabbitMQ:Host"],
            HostName = "localhost",
            //UserName = _configuration["RabbitMQ:Username"],
            UserName = "guest",
            //Password = _configuration["RabbitMQ:Password"],
            Password = "guest",
            //VirtualHost = _configuration["RabbitMQ:VirtualHost"] ?? "/"
            VirtualHost = "/"
        };

        using var connection = factory.CreateConnection();
        using var channel = connection.CreateModel();

        var queueName = _configuration["RabbitMQ:QueueName"] ?? "registration_emails";

        channel.QueueDeclare(queue: "registrationQueue", durable: false, exclusive: false, autoDelete: false, arguments: null);

        var message = new
        {
            Email = userEmail,
            Subject = "Dobrodošli na zaMene stanove",
            Message = @"Uspješno ste registrovani na zaMene stanove. 
            Hvala na povjerenju!
            
            Ova aplikacaja vam omogućava pretragu, pregled i rezervaciju stanova.
            Ako imate bilo kakvih pitanja ili trebate pomoc, slobodno nas kontaktirajte.

            Srdačno,
            #zaMene tim"
        };

        var messageBody = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(message));

        channel.BasicPublish(exchange: "", routingKey: "registrationQueue", basicProperties: null, body: messageBody);
    }
}
