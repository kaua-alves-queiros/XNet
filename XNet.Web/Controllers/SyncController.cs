using Microsoft.AspNetCore.Mvc;
using XNet.Shared.Models;

namespace XNet.Web.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SyncController : ControllerBase
{
    [HttpPost("push")]
    public IActionResult PushData([FromBody] SyncPayload payload)
    {
        // Placeholder for future sync logic
        return Ok(new { Message = "Sync received", Timestamp = DateTime.UtcNow });
    }

    [HttpGet("pull")]
    public IActionResult PullData()
    {
        // Placeholder for future pull logic
        return Ok(new List<Device>());
    }
}

public class SyncPayload
{
    public List<Device> Devices { get; set; } = new();
    public DateTime LastSync { get; set; }
}
