using Microsoft.AspNetCore.Identity;

namespace XNet.Shared.Models;

public class ApplicationUser : IdentityUser
{
    public string? FullName { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public class Organization
{
    public int Id { get; set; }
    public string Name { get; set; } = "My Organization";
    public string? Email { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public bool IsConfigured { get; set; } = false;
}
