using System.Security;
using Microsoft.AspNetCore.Http;

public class UpdateUserProfileDto
{
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Username { get; set; }
    public string? Email { get; set; }
    public string? OldPassword { get; set; } 
    public string? NewPassword { get; set; } 

    public string? Phone { get; set; }

    public IFormFile? ProfileImagePath { get; set; }
}
