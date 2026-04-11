using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using XNet.Shared.Models;

namespace XNet.SelfHosted.Data;

public class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : IdentityDbContext<ApplicationUser>(options)
{
    public DbSet<Organization> Organizations { get; set; }
    public DbSet<Device> Devices { get; set; }
    public DbSet<LogEntry> Logs { get; set; }
    
    // Terminal
    public DbSet<TerminalSnippet> TerminalSnippets { get; set; }
    public DbSet<TerminalLog> TerminalLogs { get; set; }
    
    // NetBox
    public DbSet<NetBoxSite> NetBoxSites { get; set; }
    public DbSet<NetBoxVLANGroup> NetBoxVLANDroups { get; set; }
    public DbSet<NetBoxVLAN> NetBoxVLANs { get; set; }
    public DbSet<NetBoxPrefix> NetBoxPrefixes { get; set; }
    public DbSet<NetBoxDevice> NetBoxDevices { get; set; }
    public DbSet<NetBoxIP> NetBoxIPs { get; set; }
}
