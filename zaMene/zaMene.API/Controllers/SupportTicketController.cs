using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using zaMene.API.Controllers;
using zaMene.API.Helpers;
using zaMene.Model.Entity;
using zaMene.Model.SearchObjects;
using zaMene.Model.ViewModels;
using zaMene.Services.Interfaces;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class SupportTicketController : BaseCRUDController<SupportTicket, SupportTicketSearchObject, SupportTicketDto, SupportTicketUpdateDto>
{
    private readonly ISupportTicketService _service;

    public SupportTicketController(ISupportTicketService service) : base(service)
        => _service = service;

    // Ako želiš da UserID uvijek dođe iz tokena:
    [HttpPost("create")]
    public IActionResult CreateForCurrentUser([FromBody] SupportTicketDto dto)
    {
        var uid = AuthHelper.GetUserIdFromClaimsPrincipal(User);
        if (uid == null) return Unauthorized();

        dto.UserID = uid.Value;
        var created = _service.Insert(dto);
        return Ok(created);
    }

    [HttpGet("mine")]
    public async Task<IActionResult> Mine([FromQuery] bool? resolved)
    {
        var uid = AuthHelper.GetUserIdFromClaimsPrincipal(User);
        if (uid == null) return Unauthorized();

        var list = await _service.GetMineAsync(uid.Value, resolved);
        return Ok(list);
    }

    [HttpPost("{id}/respond")]
    public async Task<IActionResult> Respond(int id, [FromBody] RespondRequest body)
    {
        if (string.IsNullOrWhiteSpace(body?.Response))
            return BadRequest("Response je obavezan.");

        var updated = await _service.RespondAsync(id, body.Response, body.Resolve);
        return Ok(updated);
    }

    [HttpPost("{id}/resolve")]
    public async Task<IActionResult> Resolve(int id)
    {
        var updated = await _service.ResolveAsync(id, true);
        return Ok(updated);
    }

    [HttpPost("{id}/reopen")]
    public async Task<IActionResult> Reopen(int id)
    {
        var updated = await _service.ResolveAsync(id, false);
        return Ok(updated);
    }

    public class RespondRequest
    {
        public string Response { get; set; } = string.Empty;
        public bool Resolve { get; set; } = false;
    }
}
