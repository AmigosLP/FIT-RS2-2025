using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using zaMene.API.Controllers;
using zaMene.Model.SearchObjects;
using zaMene.Model;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using zaMene.Model.Entity;
using zaMene.Model.ViewModel;
using zaMene.Services.Interface;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class NotificationController : BaseCRUDController<Notification, NotificationSearchObject, NotificationDto, NotificationUpdateDto>
{
    private readonly INotificationService _service;
    private readonly AppDbContext _context;

    public NotificationController(INotificationService service, AppDbContext context) : base(service)
    {
        _service = service;
        _context = context;
    }

    [Authorize(AuthenticationSchemes = "Bearer")]
    [HttpPost("mark-as-read/{id}")]
    public async Task<IActionResult> MarkAsRead(int id)
    {
        var result = await _service.MarkAsRead(id);
        if (!result)
            return NotFound();

        return Ok(new { message = "Notifikacija označena kao pročitana" });
    }

    [Authorize(AuthenticationSchemes = "Bearer")]
    [HttpPost("send")]
    public async Task<IActionResult> SendNotification(NotificationDto dto)
    {
        await _service.SendNotificationAsync(dto);
        return Ok(new { message = "Notifikacija poslana" });
    }

    [Authorize(AuthenticationSchemes = "Bearer")]
    [HttpGet("all")]
    public async Task<IActionResult> GetAllForCurrentUser()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
        if (userIdClaim == null)
            return Unauthorized();

        if (!int.TryParse(userIdClaim.Value, out int userId))
            return Unauthorized();

        var notifications = await _context.Notification
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync();

        return Ok(notifications);
    }

    [Authorize(AuthenticationSchemes = "Bearer")]
    [HttpGet("unread-count")]
    public async Task<IActionResult> GetUnreadCount()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
        if (userIdClaim == null)
            return Unauthorized();

        if (!int.TryParse(userIdClaim.Value, out int userId))
            return Unauthorized();

        var count = await _context.Notification
            .Where(n => n.UserId == userId && !n.IsRead)
            .CountAsync();

        return Ok(new { count });
    }

    [Authorize(AuthenticationSchemes = "Bearer")]
    [HttpGet("unread-count/{userId}")]
    public async Task<IActionResult> GetUnreadCount(int userId)
    {
        var count = await _service.GetUnreadNotificationCount(userId);
        return Ok(new { count });
    }
}
