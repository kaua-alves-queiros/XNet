using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using XNet.SelfHosted.Data;
using XNet.Shared.DTOs;

namespace XNet.SelfHosted.Controllers;

[Route("api/devices")]
public class DeviceController : ApiControllerBase
{
    private readonly ApplicationDbContext _db;

    public DeviceController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<DeviceDto>>> GetDevices()
    {
        var devices = await _db.Devices
            .Select(d => new DeviceDto
            {
                Id = d.Id,
                Name = d.Name,
                Host = d.Host,
                Port = d.Port,
                ConnectionType = d.ConnectionType,
                Status = "Online", // Mocked for now
                LastSeen = DateTime.UtcNow
            })
            .ToListAsync();

        return Ok(devices);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<DeviceDetailDto>> GetDevice(Guid id)
    {
        var device = await _db.Devices
            .Include(d => d.Logs.OrderByDescending(l => l.Timestamp).Take(20))
            .FirstOrDefaultAsync(d => d.Id == id);

        if (device == null) return NotFound();

        var dto = new DeviceDetailDto
        {
            Id = device.Id,
            Name = device.Name,
            Host = device.Host,
            Port = device.Port,
            ConnectionType = device.ConnectionType,
            Username = device.Username,
            Notes = device.Notes,
            RecentLogs = device.Logs.Select(l => new LogEntryDto
            {
                Id = l.Id,
                Content = l.Content,
                Level = l.Level,
                Timestamp = l.Timestamp
            }).ToList()
        };

        return Ok(dto);
    }
}
