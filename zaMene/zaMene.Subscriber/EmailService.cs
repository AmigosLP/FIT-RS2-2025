using MimeKit;
using MailKit.Net.Smtp;
using Microsoft.Extensions.Configuration;

namespace EmailConsumer
{
    public class EmailService
    {
        private readonly IConfiguration _configuration;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public void SendEmailForRegistration(string userEmail, string message, string subject)
        {
            var emailConfig = _configuration.GetSection("Email");
            var emailMessage = new MimeMessage();

            var fromEmail = Environment.GetEnvironmentVariable("Email");
            emailMessage.From.Add(new MailboxAddress("ZaMene Registration Email", fromEmail));
            emailMessage.To.Add(new MailboxAddress("Customer", userEmail));
            emailMessage.Subject = subject;
            emailMessage.Body = new TextPart("plain")
            {
                Text = message
            };
            using var client = new SmtpClient();
            var port = Environment.GetEnvironmentVariable("Port");
            var host = Environment.GetEnvironmentVariable("Host");
            try
            {
                client.Connect(host, int.Parse(port), false);
                var pass = Environment.GetEnvironmentVariable("Password");
                var user = Environment.GetEnvironmentVariable("EmailUsername");

                client.Authenticate(user, pass);
                client.Send(emailMessage);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred while sending email to {userEmail}: {ex.Message}");
            }
            finally
            {
                client.Disconnect(true);
                client.Dispose();
            }
        }
    }
}
