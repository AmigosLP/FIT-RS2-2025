using System.Security;
using Microsoft.AspNetCore.Http;

public class UpdateUserProfileDto
{
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Username { get; set; }
    public string? Email { get; set; }
    public string? Password { get; set; }
    public IFormFile? ProfileImagePath { get; set; }
}
