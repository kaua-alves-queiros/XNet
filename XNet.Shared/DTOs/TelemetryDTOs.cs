using System.Text.Json.Serialization;

namespace XNet.Shared.DTOs;

public class TelemetryDto
{
    [JsonPropertyName("deviceId")]
    public Guid DeviceId { get; set; }

    [JsonPropertyName("cpuUsage")]
    public double CpuUsage { get; set; }

    [JsonPropertyName("ramUsage")]
    public double RamUsage { get; set; }

    [JsonPropertyName("storageUsage")]
    public double StorageUsage { get; set; }

    [JsonPropertyName("latencyMs")]
    public double LatencyMs { get; set; }

    [JsonPropertyName("uplinkSpeed")]
    public double UplinkSpeed { get; set; }

    [JsonPropertyName("downlinkSpeed")]
    public double DownlinkSpeed { get; set; }

    [JsonPropertyName("timestamp")]
    public DateTime Timestamp { get; set; }
}

public class NetworkHealthDto
{
    [JsonPropertyName("overallStatus")]
    public string OverallStatus { get; set; } = "Normal";

    [JsonPropertyName("onlineNodes")]
    public int OnlineNodes { get; set; }

    [JsonPropertyName("totalNodes")]
    public int TotalNodes { get; set; }

    [JsonPropertyName("activeAlerts")]
    public int ActiveAlerts { get; set; }
}
