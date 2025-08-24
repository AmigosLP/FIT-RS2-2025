using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using zaMene.API.Controllers;
using zaMene.Model.SearchObjects;
using MapsterMapper;
using zaMene.API.Helpers;
using zaMene.Model.Entity;
using zaMene.Model.ViewModel;
using zaMene.Services.Interface;
using Microsoft.AspNetCore.Authorization;

namespace zaMene.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ReservationController : BaseCRUDController<Reservation, ReservationSearchObject, ReservationDto, ReservationUpdateDto>
    {
        private readonly IReservationService _reservationService;
        private readonly IMapper _mapper;

        public ReservationController(IReservationService reservationService, IMapper mapper) : base(reservationService)
        {
            _reservationService = reservationService;
            _mapper = mapper;
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpGet("check-availability")]
        public async Task<IActionResult> CheckAvailability(int propertyId, DateTime startDate, DateTime endDate)
        {
            if (startDate >= endDate)
                return BadRequest("Startni datum mora biti prije završnog.");

            var isAvailable = await _reservationService.IsPropertyAvailable(propertyId, startDate, endDate);

            return Ok(new { propertyId, startDate, endDate, isAvailable });
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpPost("Create-custom")]
        public async Task<IActionResult> CreateReservation([FromBody] ReservationDto reservationDto)
        {

            try {
                if (reservationDto == null)
                    return BadRequest("Invalid reservation data.");

                if (reservationDto.StartDate >= reservationDto.EndDate)
                    return BadRequest("Startni datum mora biti prije završnog.");

                var available = await _reservationService.IsPropertyAvailable(
                    reservationDto.PropertyID,
                    reservationDto.StartDate,
                    reservationDto.EndDate);

                if (!available)
                    return Conflict("Nekretnina je već zauzeta u datom periodu.");

                var reservation = _mapper.Map<Reservation>(reservationDto);
                var createdReservation = await _reservationService.CreateReservation(reservation);

                return CreatedAtAction(nameof(GetReservationById), new { id = createdReservation.ReservationID }, createdReservation);
            } catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
          
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpGet("by-id/{id}")]
        public async Task<IActionResult> GetReservationById(int id)
        {
            var reservation = _reservationService.GetById(id);
            if (reservation == null)
                return NotFound();

            return Ok(reservation);
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpGet("active-reservations/{propertyId}")]
        public async Task<IActionResult> GetActiveReservations(int propertyId)
        {
            var reservations = await _reservationService.GetActiveReservationsByPropertyId(propertyId);
            return Ok(reservations);
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpGet("my-reservations")]
        public async Task<IActionResult> GetMyReservations()
        {
            var userId = AuthHelper.GetUserIdFromClaimsPrincipal(User);
            if (userId == null)
                return Unauthorized("Korisnik nije autentificiran.");

            var myReservations = await _reservationService.GetMyReservations(userId.Value);
            return Ok(myReservations);
        }

        [Authorize(AuthenticationSchemes = "Bearer")]
        [HttpGet("all-detailed")]
        public async Task<IActionResult> GetAllDetailed([FromQuery] ReservationSearchObject search)
        {
            var data = await _reservationService.GetAllDetailedAsync(search);
            return Ok(data);
        }
    }
}
