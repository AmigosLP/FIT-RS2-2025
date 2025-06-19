using Microsoft.Extensions.Configuration;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using Newtonsoft.Json;
using EmailConsumer;

namespace zaMene.Subscriber
{
    public class RegistrationEmailConsumer
    {
        private readonly IModel _channel;
        private readonly IConfiguration _configuration;
        private readonly EmailService _emailService;

        private readonly string _host = Environment.GetEnvironmentVariable("RabbitMQ_Host") ?? "localhost";
        private readonly string _username = Environment.GetEnvironmentVariable("RabbitMQ_Username") ?? "guest";
        private readonly string _password = Environment.GetEnvironmentVariable("RabbitMQ_Password") ?? "guest";
        private readonly string _virtualhost = Environment.GetEnvironmentVariable("RabbitMQ_Virtualhost") ?? "/";


        public RegistrationEmailConsumer(IConfiguration configuration, EmailService emailService)
        {
            _configuration = configuration;
            _emailService = emailService;

            var factory = new ConnectionFactory()
            {
                HostName = _host,
                UserName = _username,
                Password = _password,
                VirtualHost = _virtualhost
            };

            var connection = factory.CreateConnection();
            _channel = connection.CreateModel();
        }

        public void StartConsuming()
        {
            var queueName = _configuration["RabbitMQ:QueueName"] ?? "registration_emails";

            _channel.QueueDeclare(queue: queueName,
                durable: false,
                exclusive: false,
                autoDelete: false,
                arguments: null);

            var consumer = new EventingBasicConsumer(_channel);
            consumer.Received += (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var messageJson = Encoding.UTF8.GetString(body);
                var message = JsonConvert.DeserializeObject<RegistrationEmailMessage>(messageJson);

                if (!string.IsNullOrEmpty(message.Email) && !string.IsNullOrEmpty(message.Message))
                {
                    _emailService.SendEmailForRegistration(message.Email, message.Subject ?? "zaMene registracija", message.Message);
                }
            };

            _channel.BasicConsume(queue: queueName,
                autoAck: true,
                consumer: consumer);

            Console.WriteLine(" [*] Started consuming registration emails.");
        }
    }
}
