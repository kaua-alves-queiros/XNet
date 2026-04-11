using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using XNet.SelfHosted.Data;
using XNet.Shared.Models;
using XNet.Shared.DTOs;

namespace XNet.SelfHosted.Controllers;

[Authorize]
[Route("api/sync")]
public class SyncController : ApiControllerBase
{
    private readonly ApplicationDbContext _db;

    public SyncController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet("export")]
    public async Task<ActionResult<SyncPayloadDto>> Export()
    {
        return Ok(new SyncPayloadDto
        {
            Devices = await _db.Devices.ToListAsync(),
            Snippets = await _db.TerminalSnippets.ToListAsync(),
            Logs = await _db.TerminalLogs.ToListAsync(),
            Sites = await _db.NetBoxSites.ToListAsync(),
            Vlans = await _db.NetBoxVLANs.ToListAsync(),
            Prefixes = await _db.NetBoxPrefixes.ToListAsync(),
            NetBoxDevices = await _db.NetBoxDevices.ToListAsync(),
            Ips = await _db.NetBoxIPs.ToListAsync()
        });
    }

    [HttpPost("import")]
    public async Task<ActionResult> Import([FromBody] SyncPayloadDto request)
    {
        if (request.Strategy == "PUSH")
        {
            // Full reset and restore
            _db.Devices.RemoveRange(_db.Devices);
            _db.TerminalSnippets.RemoveRange(_db.TerminalSnippets);
            _db.TerminalLogs.RemoveRange(_db.TerminalLogs);
            _db.NetBoxSites.RemoveRange(_db.NetBoxSites);
            _db.NetBoxVLANs.RemoveRange(_db.NetBoxVLANs);
            _db.NetBoxPrefixes.RemoveRange(_db.NetBoxPrefixes);
            _db.NetBoxDevices.RemoveRange(_db.NetBoxDevices);
            _db.NetBoxIPs.RemoveRange(_db.NetBoxIPs);

            if (request.Devices?.Any() == true) _db.Devices.AddRange(request.Devices);
            if (request.Snippets?.Any() == true) _db.TerminalSnippets.AddRange(request.Snippets);
            if (request.Logs?.Any() == true) _db.TerminalLogs.AddRange(request.Logs);
            if (request.Sites?.Any() == true) _db.NetBoxSites.AddRange(request.Sites);
            if (request.Vlans?.Any() == true) _db.NetBoxVLANs.AddRange(request.Vlans);
            if (request.Prefixes?.Any() == true) _db.NetBoxPrefixes.AddRange(request.Prefixes);
            if (request.NetBoxDevices?.Any() == true) _db.NetBoxDevices.AddRange(request.NetBoxDevices);
            if (request.Ips?.Any() == true) _db.NetBoxIPs.AddRange(request.Ips);

            await _db.SaveChangesAsync();
            return Ok();
        }

        // Add MERGE logic for other types if needed, for now focusing on PUSH/PULL
        return Ok();
    }
}

public class SyncPayloadDto
{
    public string Strategy { get; set; } = "MERGE";
    public List<Device>? Devices { get; set; }
    public List<TerminalSnippet>? Snippets { get; set; }
    public List<TerminalLog>? Logs { get; set; }
    public List<NetBoxSite>? Sites { get; set; }
    public List<NetBoxVLAN>? Vlans { get; set; }
    public List<NetBoxPrefix>? Prefixes { get; set; }
    public List<NetBoxDevice>? NetBoxDevices { get; set; }
    public List<NetBoxIP>? Ips { get; set; }
}
