using System.ComponentModel.DataAnnotations;

namespace XNet.Web.Models;

public class LogEntry
{
    public Guid Id { get; set; } = Guid.NewGuid();
    
    public Guid DeviceId { get; set; }
    public Device? Device { get; set; }
    
    [Required]
    public string Content { get; set; } = string.Empty;
    
    public string Level { get; set; } = "Info"; // Info, Warning, Error
    
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}
