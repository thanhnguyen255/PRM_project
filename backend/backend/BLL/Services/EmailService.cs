using backend.BLL.Interfaces;
using Microsoft.Extensions.Configuration;
using System.Net;
using System.Net.Mail;

namespace backend.BLL.Services;

public class EmailService : IEmailService
{
    private readonly IConfiguration _config;

    public EmailService(IConfiguration config)
    {
        _config = config;
    }

    public async Task SendEmailAsync(string toEmail, string subject, string body)
    {
        var smtpSettings = _config.GetSection("SmtpSettings");
        var host = smtpSettings["Host"];
        var portStr = smtpSettings["Port"];
        var user = smtpSettings["User"];
        var pass = smtpSettings["Pass"];
        var senderName = smtpSettings["SenderName"] ?? "LMS App";

        if (string.IsNullOrEmpty(host) || string.IsNullOrEmpty(user) || string.IsNullOrEmpty(pass) || user == "your-email@gmail.com")
        {
            // Fallback for dev if not configured properly, just print to console.
            Console.WriteLine($"\n===========================================");
            Console.WriteLine($"[EmailService] MÔ PHỎNG GỬI EMAIL (CHƯA CẤU HÌNH SMTP)");
            Console.WriteLine($"Gửi tới: {toEmail}");
            Console.WriteLine($"Tiêu đề: {subject}");
            Console.WriteLine($"Nội dung: {body}");
            Console.WriteLine($"===========================================\n");
            return;
        }

        if (!int.TryParse(portStr, out int port)) port = 587;

        using var client = new SmtpClient(host, port)
        {
            Credentials = new NetworkCredential(user, pass),
            EnableSsl = true
        };

        var mailMessage = new MailMessage
        {
            From = new MailAddress(user, senderName),
            Subject = subject,
            Body = body,
            IsBodyHtml = true
        };
        mailMessage.To.Add(toEmail);

        try
        {
            await client.SendMailAsync(mailMessage);
            Console.WriteLine($"[EmailService] Đã gửi email thành công tới {toEmail}");
        }
        catch (SmtpException ex)
        {
            Console.WriteLine($"\n===========================================");
            Console.WriteLine($"[EmailService] LỖI GỬI EMAIL THẬT, CHUYỂN SANG MÔ PHỎNG");
            Console.WriteLine($"Lý do: {ex.Message}");
            Console.WriteLine($"Nội dung gửi: {body}");
            Console.WriteLine($"===========================================\n");
            // Do not throw to allow the flow to continue for testing purposes
        }
    }
}
