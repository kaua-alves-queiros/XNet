using System.ComponentModel.DataAnnotations;

namespace XNet.Web.Models;

public class Device
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    [Required]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    public string Host { get; set; } = string.Empty;
    
    public string Port { get; set; } = "22";
    
    public string ConnectionType { get; set; } = "SSH";
    
    public string? Username { get; set; }
    
    public string? Notes { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public List<LogEntry> Logs { get; set; } = new();
}
