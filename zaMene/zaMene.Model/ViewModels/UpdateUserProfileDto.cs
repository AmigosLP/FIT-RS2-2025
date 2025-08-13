using System.Security;
using Microsoft.AspNetCore.Http;

public class UpdateUserProfileDto
{
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Username { get; set; }
    public string? Email { get; set; }
    public string? OldPassword { get; set; }  // STARA LOZINKA
    public string? NewPassword { get; set; }  // NOVA LOZINKA

    public IFormFile? ProfileImagePath { get; set; }
}
