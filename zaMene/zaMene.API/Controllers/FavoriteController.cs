using Microsoft.AspNetCore.Mvc;
using zaMene.API.Controllers;
using zaMene.API.Helpers;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Services.Interfaces;
using System.Linq;
using Microsoft.AspNetCore.Authorization;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class FavoriteController : BaseCRUDController<Favorite, FavoriteSearchObject, FavoriteDto, FavoriteUpdateDto>
{
    private readonly IFavoriteService _service;

    public FavoriteController(IFavoriteService service): base(service)
    {
        _service = service;
    }


    [HttpGet("mine")]
    public IActionResult GetMyFavorites()
    {
        var userId = AuthHelper.GetUserIdFromClaimsPrincipal(User);
        if (userId == null) return Unauthorized();

        var search = new FavoriteSearchObject { UserID = userId.Value };
        var list = _service.Search(search);
        return Ok(list);
    }

    [HttpPost("toggle")]
    public async Task<IActionResult> Toggle([FromBody] FavoriteDto dto)
    {
        if (dto == null) return BadRequest("Prazan zahtjev.");

        // Ako želiš koristiti userId iz tokena umjesto iz body-ja:
        var userId = AuthHelper.GetUserIdFromClaimsPrincipal(User);
        if (userId == null) return Unauthorized();
        dto.UserID = userId.Value;

        // provjeri postoji li
        var existing = _service.Search(new FavoriteSearchObject
        {
            UserID = dto.UserID,
            PropertyID = dto.PropertyID
        }).FirstOrDefault();

        if (existing == null)
        {
            var created = _service.Insert(dto);
            return Ok(new { isFavorite = true, favoriteId = created.FavoriteID });
        }
        else
        {
            await _service.Delete(existing.FavoriteID);
            return Ok(new { isFavorite = false });
        }
    }

    [HttpDelete("by")]
    public async Task<IActionResult> DeleteByUserProperty([FromQuery] int userId, [FromQuery] int propertyId)
    {
        var existing = _service.Search(new FavoriteSearchObject
        {
            UserID = userId,
            PropertyID = propertyId
        }).FirstOrDefault();

        if (existing == null) return NotFound();

        await _service.Delete(existing.FavoriteID);
        return NoContent();
    }
}