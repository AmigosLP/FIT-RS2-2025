using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using zaMene.Model.Entity;

public class JwtService
{
    private readonly IConfiguration _config;

    public JwtService(IConfiguration config)
    {
        _config = config;
    }
        public static string JWTTokenGenerate(User user, string role)
        {
            var claims = new[]
            {
              new Claim(ClaimTypes.NameIdentifier, user.UserID.ToString()),
              new Claim(JwtRegisteredClaimNames.Email,user.Email),
              new Claim("FirstName",user.FirstName),
              new Claim("LastName",user.LastName),
              new Claim("Username", user.Username),
              new Claim("role", role),
              new Claim(JwtRegisteredClaimNames.Jti,Guid.NewGuid().ToString())
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("my_super_secret_key_za_mene_test_test_admin_test"));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: "zamene.com",
                audience: "zamene.com",
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(20),
                signingCredentials: creds
             );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
}
