using Microsoft.AspNetCore.Mvc;
using XNet.Shared.DTOs;

namespace XNet.SelfHosted.Controllers;

public class TelemetryController : ApiControllerBase
{
    [HttpGet("{deviceId}")]
    public ActionResult<TelemetryDto> GetTelemetry(Guid deviceId)
    {
        // Mock data for Swift app development
        var rand = new Random();
        return Ok(new TelemetryDto
        {
            DeviceId = deviceId,
            CpuUsage = rand.NextDouble() * 100,
            RamUsage = 2.4 + rand.NextDouble() * 4,
            StorageUsage = 89.0,
            LatencyMs = 12 + rand.Next(1, 40),
            UplinkSpeed = 150 + rand.Next(1, 50),
            DownlinkSpeed = 800 + rand.Next(1, 200),
            Timestamp = DateTime.UtcNow
        });
    }

    [HttpGet("health")]
    public ActionResult<NetworkHealthDto> GetNetworkHealth()
    {
        return Ok(new NetworkHealthDto
        {
            OverallStatus = "Optimal",
            OnlineNodes = 12,
            TotalNodes = 14,
            ActiveAlerts = 2
        });
    }
}
