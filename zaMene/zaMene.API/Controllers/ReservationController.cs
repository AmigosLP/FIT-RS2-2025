using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using zaMene.Model;
using zaMene.Services;
using zaMene.API.Controllers;
using zaMene.Model.SearchObjects;
using MapsterMapper;

namespace zaMene.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReservationController : BaseCRUDController<Reservation, ReservationSearchObject, ReservationDto, ReservationUpdateDto>
    {
        private readonly IReservationService _reservationService;
        private readonly IMapper _mapper;

        public ReservationController(IReservationService reservationService, IMapper mapper) : base(reservationService)
        {
            _reservationService = reservationService;
            _mapper = mapper;
        }

        // Provjeri dostupnost nekretnine na period
        // GET api/reservation/check-availability?propertyId=1&startDate=2025-07-01&endDate=2025-07-05
        [HttpGet("check-availability")]
        public async Task<IActionResult> CheckAvailability(int propertyId, DateTime startDate, DateTime endDate)
        {
            if (startDate >= endDate)
                return BadRequest("Startni datum mora biti prije završnog.");

            var isAvailable = await _reservationService.IsPropertyAvailable(propertyId, startDate, endDate);

            return Ok(new { propertyId, startDate, endDate, isAvailable });
        }

        [HttpPost("Create-custom")]
        public async Task<IActionResult> CreateReservation([FromBody] ReservationDto reservationDto)
        {
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
        }

        // Dohvati rezervaciju po ID-u (za povratni odgovor)
        [HttpGet("by-id/{id}")]
        public async Task<IActionResult> GetReservationById(int id)
        {
            var reservation = _reservationService.GetById(id);
            if (reservation == null)
                return NotFound();

            return Ok(reservation);
        }

        // (Opcionalno) Dohvati aktivne rezervacije za nekretninu
        [HttpGet("active-reservations/{propertyId}")]
        public async Task<IActionResult> GetActiveReservations(int propertyId)
        {
            var reservations = await _reservationService.GetActiveReservationsByPropertyId(propertyId);
            return Ok(reservations);
        }
    }
}
