using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using XNet.Shared.DTOs;

namespace XNet.SelfHosted.Controllers;

[ApiController]
[Route("api/[controller]")]
[AllowAnonymous] // O App precisa saber os modos de conexão antes do login
public class SystemController : ControllerBase
{
    [HttpGet("config")]
    public ActionResult<SystemConfigDto> GetConfig()
    {
        return Ok(new SystemConfigDto
        {
            Version = "1.0.2-pro",
            ServerName = "Private XNet Node",
            InstanceId = "XN-8822-PRO",
            Capabilities = new List<string> { "telemetry", "devices", "terminal", "logs" },
            ConnectionModes = new List<ConnectionModeDto>
            {
                new ConnectionModeDto 
                { 
                    Type = "Cloud", 
                    IsAvailable = false, 
                    StatusMessage = "In Development - Coming Soon" 
                },
                new ConnectionModeDto 
                { 
                    Type = "SelfHosted", 
                    IsAvailable = true, 
                    StatusMessage = "Available for direct link" 
                }
            }
        });
    }

    [HttpGet("handshake")]
    public ActionResult Handshake()
    {
        return Ok(new { 
            Status = "Connected", 
            Timestamp = DateTime.UtcNow,
            Message = "XNet Node Handshake Successful"
        });
    }
}
