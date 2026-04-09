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
    
    func fetchContributors() async {
        guard let url = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/contributors") else { return }
        
        await MainActor.run { isFetching = true }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let basicContributors = try JSONDecoder().decode([GitHubContributor].self, from: data)
            
            // Limit to top 5 out of API safety
            var detailed: [GitHubUserDetails] = []
            for contributor in basicContributors.prefix(5) {
                if let details = try? await fetchUserDetails(username: contributor.login) {
                    var finalDetails = details
                    finalDetails.contributions = contributor.contributions
                    detailed.append(finalDetails)
                }
            }
            
            await MainActor.run {
                self.contributors = detailed
                self.isFetching = false
            }
        } catch {
            print("Failed to fetch GitHub contributors: \(error)")
            await MainActor.run { isFetching = false }
        }
    }
    
    private func fetchUserDetails(username: String) async throws -> GitHubUserDetails {
        guard let url = URL(string: "https://api.github.com/users/\(username)") else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(GitHubUserDetails.self, from: data)
    }
}
