using Microsoft.Extensions.Configuration;
using zaMene.Subscriber;
using DotNetEnv;
using EmailConsumer;

class Program
{
    static void Main(string[] args)
    {
        Env.Load();

        var config = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json")
            .AddEnvironmentVariables()
            .Build();

        var emailService = new EmailService(config);
        var consumer = new RegistrationEmailConsumer(config, emailService);
        consumer.StartConsuming();

        Console.WriteLine("Email consumer started...");
        Thread.Sleep(Timeout.Infinite);
    }
}
