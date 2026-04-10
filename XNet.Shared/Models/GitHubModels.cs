using System.Text.Json.Serialization;

namespace XNet.Shared.Models;

public class GitHubUserProfile
{
    [JsonPropertyName("name")] public string? Name { get; set; }
    [JsonPropertyName("bio")] public string? Bio { get; set; }
    [JsonPropertyName("company")] public string? Company { get; set; }
}

public class GitHubContributor
{
    [JsonPropertyName("login")] public string Login { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public string? Company { get; set; }
    [JsonPropertyName("avatar_url")] public string AvatarUrl { get; set; } = string.Empty;
    [JsonPropertyName("html_url")] public string HtmlUrl { get; set; } = string.Empty;
    [JsonPropertyName("contributions")] public int Contributions { get; set; }
}
