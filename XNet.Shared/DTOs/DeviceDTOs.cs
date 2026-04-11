using System.Text.Json.Serialization;

namespace XNet.Shared.DTOs;

public class DeviceDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("host")]
    public string Host { get; set; } = string.Empty;

    [JsonPropertyName("port")]
    public string Port { get; set; } = "22";

    [JsonPropertyName("connectionType")]
    public string ConnectionType { get; set; } = "SSH";

    [JsonPropertyName("status")]
    public string Status { get; set; } = "Offline";

    [JsonPropertyName("lastSeen")]
    public DateTime? LastSeen { get; set; }
}

public class DeviceDetailDto : DeviceDto
{
    [JsonPropertyName("username")]
    public string? Username { get; set; }

    [JsonPropertyName("notes")]
    public string? Notes { get; set; }

    [JsonPropertyName("recentLogs")]
    public List<LogEntryDto> RecentLogs { get; set; } = new();
}

public class LogEntryDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("content")]
    public string Content { get; set; } = string.Empty;

    [JsonPropertyName("level")]
    public string Level { get; set; } = "Info";

    [JsonPropertyName("timestamp")]
    public DateTime Timestamp { get; set; }
}
