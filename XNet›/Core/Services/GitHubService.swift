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

class GitHubService: ObservableObject {
    @Published var contributors: [GitHubContributor] = []
    @Published var isFetching = false
    
    private let repoOwner = "kaua-alves-queiros"
    private let repoName = "XNet"
    
    func fetchContributors() async {
        guard let url = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/contributors") else { return }
        
        await MainActor.run { isFetching = true }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([GitHubContributor].self, from: data)
            
            await MainActor.run {
                self.contributors = decoded
                self.isFetching = false
            }
        } catch {
            print("Failed to fetch GitHub contributors: \(error)")
            await MainActor.run { isFetching = false }
        }
    }
}
