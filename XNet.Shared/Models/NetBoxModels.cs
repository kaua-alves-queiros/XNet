using System.ComponentModel.DataAnnotations;

namespace XNet.Shared.Models;

public class TerminalSnippet
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Title { get; set; } = string.Empty;
    public string Command { get; set; } = string.Empty;
    public string? Notes { get; set; }
    public bool SendReturn { get; set; } = true;
}

public class TerminalLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Title { get; set; } = string.Empty;
    public string ConnectionType { get; set; } = "SSH";
    public string Host { get; set; } = string.Empty;
    public string Port { get; set; } = "22";
    public string? Username { get; set; }
    public DateTime StartedAt { get; set; }
    public DateTime EndedAt { get; set; }
    public string Content { get; set; } = string.Empty;
}

// NetBox Sync Models
public class NetBoxSite
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
}

public class NetBoxVLANGroup
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int MinVID { get; set; } = 1;
    public int MaxVID { get; set; } = 4094;
}

public class NetBoxVLAN
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public int Vid { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string Status { get; set; } = "Active";
    public Guid? SiteId { get; set; }
    public Guid? GroupId { get; set; }
}

public class NetBoxPrefix
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Cidr { get; set; } = string.Empty;
    public string? Description { get; set; }
    public Guid? SiteId { get; set; }
    public Guid? VlanId { get; set; }
}

public class NetBoxDevice
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string? DeviceType { get; set; }
    public string? AssetTag { get; set; }
    public string? Notes { get; set; }
    public Guid? SiteId { get; set; }
}

public class NetBoxIP
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Address { get; set; } = string.Empty;
    public string? InterfaceLabel { get; set; }
    public string? UsageDescription { get; set; }
    public string Status { get; set; } = "Active";
    public Guid? PrefixId { get; set; }
    public Guid? DeviceId { get; set; }
}
