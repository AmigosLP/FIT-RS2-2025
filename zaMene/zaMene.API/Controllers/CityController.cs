using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using zaMene.Model;
using zaMene.Model.Entity;

[ApiController]
[Route("api/[controller]")]
[Authorize(AuthenticationSchemes = "Bearer")]
public class CityController : ControllerBase
{
    private readonly AppDbContext _context;

    public CityController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<List<City>>> GetCities()
    {
        var cities = await _context.City.ToListAsync();
        return Ok(cities);
    }
}
