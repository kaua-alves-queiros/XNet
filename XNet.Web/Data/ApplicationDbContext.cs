using Microsoft.EntityFrameworkCore;
using XNet.Shared.Models;

namespace XNet.Web.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Device> Devices => Set<Device>();
    public DbSet<LogEntry> Logs => Set<LogEntry>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        modelBuilder.Entity<Device>()
            .HasMany(d => d.Logs)
            .WithOne(l => l.Device)
            .HasForeignKey(l => l.DeviceId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
