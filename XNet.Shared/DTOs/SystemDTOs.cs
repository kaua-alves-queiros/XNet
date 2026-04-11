using System.Text.Json.Serialization;

namespace XNet.Shared.DTOs;

public class SystemConfigDto
{
    [JsonPropertyName("version")]
    public string Version { get; set; } = "1.0.0";

    [JsonPropertyName("serverName")]
    public string ServerName { get; set; } = "XNet Self-Hosted Node";

    [JsonPropertyName("instanceId")]
    public string InstanceId { get; set; } = Guid.NewGuid().ToString();

    [JsonPropertyName("capabilities")]
    public List<string> Capabilities { get; set; } = new();

    [JsonPropertyName("connectionModes")]
    public List<ConnectionModeDto> ConnectionModes { get; set; } = new();
}

public class ConnectionModeDto
{
    [JsonPropertyName("type")]
    public string Type { get; set; } = string.Empty; // "Cloud" or "SelfHosted"

    [JsonPropertyName("isAvailable")]
    public bool IsAvailable { get; set; }

    [JsonPropertyName("statusMessage")]
    public string? StatusMessage { get; set; }
}
