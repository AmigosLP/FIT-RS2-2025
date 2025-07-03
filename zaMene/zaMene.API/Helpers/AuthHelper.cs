using System.Security.Claims;

namespace zaMene.API.Helpers
{
    public static class AuthHelper
    {
        public static int? GetUserIdFromClaimsPrincipal(ClaimsPrincipal user)
        {
            var userIdClaim = user.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null)
                return null;

            if (int.TryParse(userIdClaim.Value, out int userId))
                return userId;

            return null;
        }
    }
}
