import Foundation
import Combine

struct GitHubContributor: Codable, Identifiable {
    let id: Int
    let login: String
    let avatarUrl: String
    let htmlUrl: String
    let contributions: Int
    
    enum CodingKeys: String, CodingKey {
        case id, login, contributions
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
    }
}

struct GitHubUserDetails: Codable, Identifiable {
    let id: Int
    let login: String
    let name: String?
    let bio: String?
    let company: String?
    let blog: String?
    let avatarUrl: String
    let htmlUrl: String
    var contributions: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case id, login, name, bio, company, blog
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
    }
}

class GitHubService: ObservableObject {
    @Published var contributors: [GitHubUserDetails] = []
    @Published var isFetching = false
    
    private let repoOwner = "kaua-alves-queiros"
    private let repoName = "XNet"
    
    private let cacheKey = "github.contributors.cache.v2"
    private let lastFetchKey = "github.contributors.lastFetchDate"
    private let cacheDuration: TimeInterval = 7 * 24 * 60 * 60 // 1 week
    
    init() {
        // Synchronous initial load to prevent flickering
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode([GitHubUserDetails].self, from: data) {
            self.contributors = cached
            print("GitHub Service: Initialized with \(cached.count) contributors from cache.")
        }
    }
    
    func fetchContributors() async {
        // 1. Initial check
        let lastFetch = UserDefaults.standard.object(forKey: lastFetchKey) as? Date
        let now = Date()
        
        // Prevent concurrent fetches
        if isFetching { return }
        
        // 2. Determine if we need to hit the API
        // We only fetch if cache is expired OR if it's empty
        let isCacheExpired = lastFetch == nil || now.timeIntervalSince(lastFetch!) > cacheDuration
        
        if !isCacheExpired && !contributors.isEmpty {
            let hoursRemaining = Int((cacheDuration - now.timeIntervalSince(lastFetch!)) / 3600)
            print("GitHub Service: Cache is active and valid. TTL: \(hoursRemaining)h.")
            return
        }
        
        print("GitHub Service: Cache expired or empty. Initiating refresh from GitHub API...")
        
        guard let url = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/contributors") else { return }
        
        await MainActor.run { isFetching = true }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let basicContributors = try JSONDecoder().decode([GitHubContributor].self, from: data)
            
            // Limit to top 8 contributions for team overview
            var detailed: [GitHubUserDetails] = []
            for contributor in basicContributors.prefix(8) {
                // Fetch each detail in parallel for speed if needed, but sequential is safer for rate limits
                if let details = try? await fetchUserDetails(username: contributor.login) {
                    var finalDetails = details
                    finalDetails.contributions = contributor.contributions
                    detailed.append(finalDetails)
                }
            }
            
            if !detailed.isEmpty {
                await MainActor.run {
                    self.contributors = detailed
                    self.isFetching = false
                    self.saveToCache(detailed)
                }
                print("GitHub Service: Successfully refreshed and cached \(detailed.count) contributors.")
            } else {
                await MainActor.run { isFetching = false }
            }
        } catch {
            print("GitHub Service: Failed to fetch: \(error.localizedDescription)")
            await MainActor.run { isFetching = false }
        }
    }
    
    private func fetchUserDetails(username: String) async throws -> GitHubUserDetails {
        guard let url = URL(string: "https://api.github.com/users/\(username)") else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.addValue("XNet-Professional-App", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GitHubUserDetails.self, from: data)
    }
    
    private func saveToCache(_ contributors: [GitHubUserDetails]) {
        if let data = try? JSONEncoder().encode(contributors) {
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: lastFetchKey)
            print("GitHub Service: Data persisted to UserDefaults.")
        }
    }
}
