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
            HostName = _configuration["RabbitMQ_Host"],
            UserName = _configuration["RabbitMQ_Username"],
            Password = _configuration["RabbitMQ_Password"],
            VirtualHost = _configuration["RabbitMQ_Virtualhost"] ?? "/"
        };

        using var connection = factory.CreateConnection();
        using var channel = connection.CreateModel();

        var queueName = _configuration["RabbitMQ:QueueName"] ?? "registration_emails";

        channel.QueueDeclare(queue: "registrationQueue", durable: false, exclusive: false, autoDelete: false, arguments: null);

        var message = new
        {
            Email = userEmail,
            Subject = "Uspješno ste registrovani na zaMene stanove." +
            "Hvala na povjerenju!" +
            " Ova aplikacaja vam omogućava pretragu, pregled i rezervaciju stanova po cijelom BiH. Imate gradove kao što su Tuzla, Sarajevo, Mostar i drugi." +
            " Ako imate bilo kakvih pitanja ili trebate pomoc, slobodno nas kontaktirajte." +
            "Pronađite najeftinije i najbolje apartmane po Vašoj želji!" +
            " Srdačno, #zaMene tim.",
            Message = "Uspješno ste registrovani na zaMene stanove. Dobro dosli!"
        };

        var messageBody = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(message));

        channel.BasicPublish(exchange: "", routingKey: "registrationQueue", basicProperties: null, body: messageBody);
    }
}
